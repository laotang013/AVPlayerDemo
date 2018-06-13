/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloaderOperation.h"
#import "SDWebImageManager.h"
#import "NSImage+WebCache.h"
#import "SDWebImageCodersManager.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

// iOS 8 Foundation.framework extern these symbol but the define is in CFNetwork.framework. We just fix this without import CFNetwork.framework
#if (__IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0)
const float NSURLSessionTaskPriorityHigh = 0.75;
const float NSURLSessionTaskPriorityDefault = 0.5;
const float NSURLSessionTaskPriorityLow = 0.25;
#endif

NSString *const SDWebImageDownloadStartNotification = @"SDWebImageDownloadStartNotification";
NSString *const SDWebImageDownloadReceiveResponseNotification = @"SDWebImageDownloadReceiveResponseNotification";
NSString *const SDWebImageDownloadStopNotification = @"SDWebImageDownloadStopNotification";
NSString *const SDWebImageDownloadFinishNotification = @"SDWebImageDownloadFinishNotification";

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> SDCallbacksDictionary;

@interface SDWebImageDownloaderOperation ()

@property (strong, nonatomic, nonnull) NSMutableArray<SDCallbacksDictionary *> *callbackBlocks;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic, nullable) NSMutableData *imageData;
@property (copy, nonatomic, nullable) NSData *cachedData; // for `SDWebImageDownloaderIgnoreCachedResponse`

// This is weak because it is injected by whoever manages this session. If this gets nil-ed out, we won't be able to run
// the task associated with this operation
@property (weak, nonatomic, nullable) NSURLSession *unownedSession;
// This is set if we're using not using an injected NSURLSession. We're responsible of invalidating this one
@property (strong, nonatomic, nullable) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTask *dataTask;

@property (strong, nonatomic, nonnull) dispatch_semaphore_t callbacksLock; // a lock to keep the access to `callbackBlocks` thread-safe

@property (strong, nonatomic, nonnull) dispatch_queue_t coderQueue; // the queue to do image decoding
#if SD_UIKIT
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@property (strong, nonatomic, nullable) id<SDWebImageProgressiveCoder> progressiveCoder;

@end

@implementation SDWebImageDownloaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)init {
    return [self initWithRequest:nil inSession:nil options:0];
}

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(SDWebImageDownloaderOptions)options {
    if ((self = [super init])) {
        _request = [request copy];
        _shouldDecompressImages = YES;
        _options = options;
        _callbackBlocks = [NSMutableArray new];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        _unownedSession = session;
        _callbacksLock = dispatch_semaphore_create(1);
        _coderQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderOperationCoderQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (nullable id)addHandlersForProgress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable SDWebImageDownloaderCompletedBlock)completedBlock {
    //url不能为空，是因为每个url要作为NSDictionry变量的key值。而这个字典的value是callbackBlocks。
    
    SDCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
    LOCK(self.callbacksLock);
    [self.callbackBlocks addObject:callbacks];
    UNLOCK(self.callbacksLock);
    return callbacks;
}

- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    LOCK(self.callbacksLock);
    NSMutableArray<id> *callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
    UNLOCK(self.callbacksLock);
    // We need to remove [NSNull null] because there might not always be a progress block for each callback
    [callbacks removeObjectIdenticalTo:[NSNull null]];
    return [callbacks copy]; // strip mutability here
}

- (BOOL)cancel:(nullable id)token {
    BOOL shouldCancel = NO;
    LOCK(self.callbacksLock);
    [self.callbackBlocks removeObjectIdenticalTo:token];
    if (self.callbackBlocks.count == 0) {
        shouldCancel = YES;
    }
    UNLOCK(self.callbacksLock);
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}
/*
  让一个NSOperation操作开始，你可以直接调用start 或者将它添加到NSOperationQueue中，添加之后，它会在队列排到他以后自动执行。
 */
//重写NSOperation的start方法 在里面做处理
//isExecuting 代表任务正在执行中
//isFinished 代表任务已经执行完成
//isCancelled 代表任务已经取消执行
- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }

#if SD_UIKIT
        //进行后台任务的处理
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        //这里需要提及的就是shouldContinueWhenAppEntersBackground，也就是说下载选项中需要设置SDWebImageDownloaderContinueInBackground。
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak __typeof__ (self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            //注意beginBackgroundTaskWithExpirationHandler并不是意味着立即执行后台任务，它只是相当于注册了一个后台任务，函数后面的handler block表示程序在后台运行时间到了后，要运行的代码
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself;

                if (sself) {
                    [sself cancel];

                    [app endBackgroundTask:sself.backgroundTaskId];
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
#endif
        //初始化session
        NSURLSession *session = self.unownedSession;
        if (!session) {
            //如果Downloader没有传入session(self对unowedSession弱引用因为默认该变量为downloader强引用)
             //使用defaultSessionConfiguration初始化session
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            /**
             *  Create the session for this task
             *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
             *  method calls and completion handler calls.
             */
            /*
             初始化自己管理的session
             delegate 设置self 即需要自动实现代理方法对任务进行管理
             delegateQueue设置nil，因此session会创建一个串行的任务队列处理代理方法和回调。
             */
            session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                    delegate:self
                                               delegateQueue:nil];
            self.ownedSession = session;
        }
        
        if (self.options & SDWebImageDownloaderIgnoreCachedResponse) {
            // Grab the cached data for later check
            NSURLCache *URLCache = session.configuration.URLCache;
            if (!URLCache) {
                URLCache = [NSURLCache sharedURLCache];
            }
            //发送的request,服务器会返回一个response，就像获取服务器端的图片一样，如果图片没有改变，第二次获取的时候，最好直接从缓存中获取，
            NSCachedURLResponse *cachedResponse;
            // NSURLCache's `cachedResponseForRequest:` is not thread-safe, see https://developer.apple.com/documentation/foundation/nsurlcache#2317483
            @synchronized (URLCache) {
                cachedResponse = [URLCache cachedResponseForRequest:self.request];
            }
            if (cachedResponse) {
                self.cachedData = cachedResponse.data;
            }
        }
        //使用request初始化dataTask
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.executing = YES;
    }

    if (self.dataTask) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if ([self.dataTask respondsToSelector:@selector(setPriority:)]) {
            if (self.options & SDWebImageDownloaderHighPriority) {
                self.dataTask.priority = NSURLSessionTaskPriorityHigh;
            } else if (self.options & SDWebImageDownloaderLowPriority) {
                self.dataTask.priority = NSURLSessionTaskPriorityLow;
            }
        }
#pragma clang diagnostic pop
        //开始执行网络请求
        [self.dataTask resume];
        //对callbacks中的每个progressBlock进行调用，并传入进度参数
        //#define NSURLResponseUnknownLength ((long long)-1)
        for (SDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
        }
        __weak typeof(self) weakSelf = self;
        //主队列通知SDWebImageDownloadStartNotification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:weakSelf];
        });
    } else {
        ////连接不成功
        //执行回调输出错误信息
        [self callCompletionBlocksWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]];
        [self done];
        return;
    }

#if SD_UIKIT
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
}
/**
 * 重写NSOperation的cancel方法
 */
- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}
/**
 * 内部方法cancel
  1.调用自定义的cancelBlock
  2.任务取消
  3.回收资源
 */
- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];

    if (self.dataTask) {
        [self.dataTask cancel];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:weakSelf];
        });

        // As we cancelled the task, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }

    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}
/**
 * 重设operation
 */
- (void)reset {
    LOCK(self.callbacksLock);
    [self.callbackBlocks removeAllObjects];
    UNLOCK(self.callbacksLock);
    self.dataTask = nil;
    
    if (self.ownedSession) {
        [self.ownedSession invalidateAndCancel];
        self.ownedSession = nil;
    }
}
//如果我们在声明属性的时候使用了getter=的语义 则需要自己手动写getter 并实现了KVO.
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark NSURLSessionDataDelegate
//接收到服务器的响应
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    //根据response中的expectedContentLength来给self.expectedSize进行赋值
    NSInteger expected = (NSInteger)response.expectedContentLength;
    expected = expected > 0 ? expected : 0;
    //self.expectedSize此处表示响应的数据体（此处为imageData）期望大小 也就是说imageData最后下载完成大概会这么大
    self.expectedSize = expected;
    self.response = response;
    NSInteger statusCode = [response respondsToSelector:@selector(statusCode)] ? ((NSHTTPURLResponse *)response).statusCode : 200;
    BOOL valid = statusCode < 400;
    //'304 Not Modified' is an exceptional one. It should be treated as cancelled if no cache data
    //URLSession current behavior will return 200 status code when the server respond 304 and URLCache hit. But this is not a standard behavior and we just add a check
    if (statusCode == 304 && !self.cachedData) {
        //当服务端返回statusCode为“304 Not Modified”，意味着服务器端的image并没有改变
        valid = NO;
    }
    
    if (valid) {
        for (SDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, expected, self.request.URL);
        }
    } else {
        // Status code invalid and marked as cancelled. Do not call `[self.dataTask cancel]` which may mass up URLSession life cycle
        disposition = NSURLSessionResponseCancel;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadReceiveResponseNotification object:weakSelf];
    });
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}
//获取到数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.imageData) {
        self.imageData = [[NSMutableData alloc] initWithCapacity:self.expectedSize];
    }
    [self.imageData appendData:data];

    if ((self.options & SDWebImageDownloaderProgressiveDownload) && self.expectedSize > 0) {
        // Get the image data
        __block NSData *imageData = [self.imageData copy];
        // Get the total bytes downloaded
        const NSInteger totalSize = imageData.length;
        // Get the finish status
        BOOL finished = (totalSize >= self.expectedSize);
        
        if (!self.progressiveCoder) {
            // We need to create a new instance for progressive decoding to avoid conflicts
            for (id<SDWebImageCoder>coder in [SDWebImageCodersManager sharedInstance].coders) {
                if ([coder conformsToProtocol:@protocol(SDWebImageProgressiveCoder)] &&
                    [((id<SDWebImageProgressiveCoder>)coder) canIncrementallyDecodeFromData:imageData]) {
                    self.progressiveCoder = [[[coder class] alloc] init];
                    break;
                }
            }
        }
        
        // progressive decode the image in coder queue
        dispatch_async(self.coderQueue, ^{
            UIImage *image = [self.progressiveCoder incrementallyDecodedImageWithData:imageData finished:finished];
            if (image) {
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
                //获取图片
                image = [self scaledImageForKey:key image:image];
                if (self.shouldDecompressImages) {
                    image = [[SDWebImageCodersManager sharedInstance] decompressedImageWithImage:image data:&imageData options:@{SDWebImageCoderScaleDownLargeImagesKey: @(NO)}];
                }
                
                // We do not keep the progressive decoding image even when `finished`=YES. Because they are for view rendering but not take full function from downloader options. And some coders implementation may not keep consistent between progressive decoding and normal decoding.
                
                [self callCompletionBlocksWithImage:image imageData:nil error:nil finished:NO];
            }
        });
    }

    for (SDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
        progressBlock(self.imageData.length, self.expectedSize, self.request.URL);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    NSCachedURLResponse *cachedResponse = proposedResponse;

    if (!(self.options & SDWebImageDownloaderUseNSURLCache)) {
        // Prevents caching of responses
        cachedResponse = nil;
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    @synchronized(self) {
        self.dataTask = nil;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:weakSelf];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadFinishNotification object:weakSelf];
            }
        });
    }
    
    // make sure to call `[self done]` to mark operation as finished
    if (error) {
        [self callCompletionBlocksWithError:error];
        [self done];
    } else {
        if ([self callbacksForKey:kCompletedCallbackKey].count > 0) {
            /**
             *  If you specified to use `NSURLCache`, then the response you get here is what you need.
             */
            __block NSData *imageData = [self.imageData copy];
            if (imageData) {
                /**  if you specified to only use cached data via `SDWebImageDownloaderIgnoreCachedResponse`,
                 *  then we should check if the cached data is equal to image data
                 */
                if (self.options & SDWebImageDownloaderIgnoreCachedResponse && [self.cachedData isEqualToData:imageData]) {
                    // call completion block with nil
                    [self callCompletionBlocksWithImage:nil imageData:nil error:nil finished:YES];
                    [self done];
                } else {
                    // decode the image in coder queue
                    dispatch_async(self.coderQueue, ^{
                        UIImage *image = [[SDWebImageCodersManager sharedInstance] decodedImageWithData:imageData];
                        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
                        image = [self scaledImageForKey:key image:image];
                        
                        BOOL shouldDecode = YES;
                        // Do not force decoding animated GIFs and WebPs
                        if (image.images) {
                            shouldDecode = NO;
                        } else {
#ifdef SD_WEBP
                            SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
                            if (imageFormat == SDImageFormatWebP) {
                                shouldDecode = NO;
                            }
#endif
                        }
                        
                        if (shouldDecode) {
                            if (self.shouldDecompressImages) {
                                BOOL shouldScaleDown = self.options & SDWebImageDownloaderScaleDownLargeImages;
                                image = [[SDWebImageCodersManager sharedInstance] decompressedImageWithImage:image data:&imageData options:@{SDWebImageCoderScaleDownLargeImagesKey: @(shouldScaleDown)}];
                            }
                        }
                        CGSize imageSize = image.size;
                        if (imageSize.width == 0 || imageSize.height == 0) {
                            [self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}]];
                        } else {
                            [self callCompletionBlocksWithImage:image imageData:imageData error:nil finished:YES];
                        }
                        [self done];
                    });
                }
            } else {
                [self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
                [self done];
            }
        } else {
            [self done];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & SDWebImageDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        } else {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark Helper methods
- (nullable UIImage *)scaledImageForKey:(nullable NSString *)key image:(nullable UIImage *)image {
    return SDScaledImageForKey(key, image);
}

- (BOOL)shouldContinueWhenAppEntersBackground {
    return self.options & SDWebImageDownloaderContinueInBackground;
}

- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    [self callCompletionBlocksWithImage:nil imageData:nil error:error finished:YES];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbacksForKey:kCompletedCallbackKey];
    dispatch_main_async_safe(^{
        for (SDWebImageDownloaderCompletedBlock completedBlock in completionBlocks) {
            completedBlock(image, imageData, error, finished);
        }
    });
}

@end

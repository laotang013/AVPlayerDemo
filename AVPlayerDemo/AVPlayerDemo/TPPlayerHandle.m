//
//  TPPlayerHandle.m
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
//

#import "TPPlayerHandle.h"
#import <AVFoundation/AVFoundation.h>
#import "TPPlayerView.h"
@interface TPPlayerHandle()<TPTransportDelegate>
@property(nonatomic,strong)AVAsset *asset;
@property(nonatomic,strong)AVPlayerItem *playerItem;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)TPPlayerView *playerView;

@end
@implementation TPPlayerHandle
-(id)initWithUrl:(NSURL *)assetURL
{
    self = [super init];
    if (self) {
        _asset = [AVAsset assetWithURL:assetURL];
        [self prepareForPlay];
        
    }
    return self;
}
-(void)prepareForPlay
{
    NSArray *keys = @[
                      @"tracks",
                      @"duration",
                      @"commonMetadata",
                      @"availableMediaCharacteristicsWithMediaSelectionOptions"
                      ];
    self.playerItem = [AVPlayerItem playerItemWithAsset:_asset automaticallyLoadedAssetKeys:keys];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView = [[TPPlayerView alloc]initWithPlayer:self.player];
    self.playerView.delegate = self;
}
-(UIView *)view
{
    return self.playerView;
}
-(void)play
{
    NSLog(@"工具类中控制播放");
    [self.playerView setTitle:@"playerView"];
}
@end

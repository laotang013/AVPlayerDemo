//
//  HETCycleScrollView.m
//  RunLoopDemo
//
//  Created by Start on 2018/6/14.
//  Copyright © 2018年 Start. All rights reserved.
//
//获取设备的物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//获取设备的物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#import "HETCycleScrollView.h"
#import "HETContentImageView.h"
@interface HETCycleScrollView()<UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)HETContentImageView *leftImageView;
@property(nonatomic,strong)HETContentImageView *centerImageView;
@property(nonatomic,strong)HETContentImageView *rightImageView;

@property(nonatomic,assign)NSInteger centerPage;

@end
@implementation HETCycleScrollView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
    }
    return self;
}
#pragma mark - 初始化
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setupSubViews];
}

-(void)setupSubViews
{
    NSLog(@"初始化");
    if (self.imageArray.count<=1) {
        NSLog(@"返回");
        return;
    }
    [self addSubview:self.scrollView];
    
    //布局三张图片
    CGRect frame = self.bounds;
    self.leftImageView = [self createImageView:frame];
    self.leftImageView.contentView.backgroundColor = [UIColor redColor];
    frame.origin.x += ScreenWidth;
    self.centerImageView = [self createImageView:frame];
    self.centerImageView.contentView.backgroundColor = [UIColor blueColor];
    frame.origin.x+=ScreenWidth;
    self.rightImageView = [self createImageView:frame];
    self.rightImageView.contentView.backgroundColor = [UIColor greenColor];
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.centerImageView];
    [self.scrollView addSubview:self.rightImageView];
    self.centerPage = 0;
}


#pragma mark - method
-(HETContentImageView *)createImageView:(CGRect)frame
{
    HETContentImageView *itemView = [[HETContentImageView alloc]initWithFrame:frame];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    itemView.contentView = imageView;
    itemView.contentView.frame = itemView.bounds;
    return itemView;
}

-(void)setCenterPage:(NSInteger)centerPage
{
    _centerPage = centerPage;
    //1.右画显示左边图片 值与0比较
    if (_centerPage<0) {
        _centerPage = self.imageArray.count-1;
    }
    //2.左滑显示右边图片 值与count-1 比较
    if (_centerPage >self.imageArray.count-1) {
        _centerPage = 0;
    }
    NSInteger leftPage = _centerPage-1<0?self.imageArray.count-1:_centerPage-1;
    NSInteger rightPage = _centerPage+1 > self.imageArray.count - 1?0:_centerPage+1;
    
    //设置图片
    ((UIImageView *)self.leftImageView.contentView).image= [UIImage imageNamed:self.imageArray[leftPage]];
    ((UIImageView *)self.centerImageView.contentView).image =[UIImage imageNamed:self.imageArray[_centerPage]];
   ((UIImageView *)self.rightImageView.contentView).image =[UIImage imageNamed:self.imageArray[rightPage]];
    [self.scrollView setContentOffset: CGPointMake(self.scrollView.frame.size.width, 0)];
}

#pragma mark - Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll");
    CGFloat offset = (_scrollView.contentOffset.x-CGRectGetWidth(_scrollView.bounds))/CGRectGetWidth(_scrollView.bounds);
    [self.centerImageView updateWithProgress:[self rectificationProgress:offset]];
}
//让scrollView滚动结束时才会调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.centerPage++;
   NSLog(@"scrollViewDidEndScrollingAnimation");
 
}

//当手动(使用手指)滚动结束后，该代理方法会被调用
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    // 判断contentOffsest.x
    if (scrollView.contentOffset.x > scrollView.frame.size.width) { // 下一张
        self.centerPage++;
    } else if (scrollView.contentOffset.x < scrollView.frame.size.width){ // 上一张
        self.centerPage--;
    }
}

#pragma mark - getter
//1.定义一个容器 2.装三个ScrollView 3.每次切换的时候都让他回到中间
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(3*ScreenWidth, ScreenHeight);
    }
    return _scrollView;
}
- (CGFloat)rectificationProgress:(CGFloat)progress {
    CGFloat newProgress = ((NSInteger)(progress * 10000) % (3 * 10000))/10000.0;
    return newProgress;
}
@end

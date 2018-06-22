



//
//  HETScrollViewMoreView.m
//  RunLoopDemo
//
//  Created by Start on 2018/6/14.
//  Copyright © 2018年 Start. All rights reserved.
//
//获取设备的物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//获取设备的物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#import "HETScrollViewMoreView.h"
#import "HETCycleScrollView.h"
#import <MJRefresh/MJRefresh.h>
@interface HETScrollViewMoreView()<UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)HETCycleScrollView *cycleView;
@property(nonatomic,strong)UIView *lastView;
@end
@implementation HETScrollViewMoreView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}
-(void)setupSubViews
{
    //
    [self addSubview:self.scrollView];
    self.cycleView = [[HETCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.cycleView.imageArray = @[@"大海.jpg",@"天空.jpg",@"森林.jpg"];
    self.lastView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    self.lastView.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:self.cycleView];
    [self.scrollView addSubview:self.lastView];
    //添加下拉刷新
    MJRefreshFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"下拉刷新");
    }];
    self.scrollView.mj_footer = footer;
    
    
}
#pragma mark - getter
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight*2);
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}
@end

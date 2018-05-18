//
//  TPPlayerView.m
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
/*
 通过协议来控制及更新界面
 */

#import "TPPlayerView.h"
#import "PrefixHeader.pch"
@interface TPPlayerView()

@end
@implementation TPPlayerView

+(Class)layerClass
{
    //重写layerClass类方法返回一个AVPlayerLayer类每当创建View的时候急剧回使用AVPlayerLayer作为他的支持层。
    return [AVPlayerLayer class];
}

-(void)setupSubViews
{
    [self addSubview:self.navigationBar];
    [self addSubview:self.toolBar];
}

-(UIView *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0,ScreenWidth, 64)];
        _navigationBar.backgroundColor = [UIColor redColor];
    }
    return _navigationBar;
}
-(UIView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight-44, ScreenWidth, 44)];
        _playItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 8, 44, 30)];
        [_playItem setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
        [_playItem addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_playItem];
    }
    return _toolBar;
}
-(id)initWithPlayer:(AVPlayer *)player
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //希望获得传入初始化方法的AVPlayerLayer并在AVPlayerLayer上对其进行设置
        [(AVPlayerLayer *)[self layer] setPlayer:player];
        [self setupSubViews];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = self.bounds;
}
//MARK THTransport
-(void)play
{
    NSLog(@"PlayView 播放");
    if ([self.delegate respondsToSelector:@selector(play)]) {
        [self.delegate play];
    }
}

- (void)setDelegate:(id<TPTransportDelegate>)delegate{
    _delegate = delegate;
}


-(void)setTitle:(NSString *)title{
    NSLog(@"PlayView名字 title: %@",title);
}

@end

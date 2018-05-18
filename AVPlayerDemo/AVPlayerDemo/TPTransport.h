//
//  TPTransport.h
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
/*
 思路
    1.View 刷新界面 以及控制界面的点击
    2.创建一个工具类 该工具类用来处理View层的事件以及刷新UI需要的数据
      2.1 工具类为View层的代理  实现代理方法
      2.2 View层产生触发事件
      2.3 工具类形成View层所要的数据
      2.4 View层实现协议中的方法 协议层中方法的调用通过在工具类中包括一个View层的属性。
 3.总结:工具类 起到发送数据的作用 让UI层的实现方法进行View层的界面刷新 UI层的响应事件通过代理方法 让工具类进行相应。
 */
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/* 1.delegate  2.刷新UI*/
@protocol TPTransportDelegate<NSObject>

-(void)play;
-(void)pause;
-(void)stop;

-(void)jumpedToTime:(NSTimeInterval)time;
@end

@protocol TPTransport<NSObject>
/**Delegate*/
@property(nonatomic,weak)id <TPTransportDelegate> delegate;
-(void)setTitle:(NSString *)title;
@end

//
//  ImageControl.h
//  RunLoopDemo
//
//  Created by Start on 2018/5/31.
//  Copyright © 2018年 Start. All rights reserved.
/*
 通过继承自UIControl来进行自定义控件
 target-action 即当事件发生时，事件会被发送到控件对象中，然后再由这个控件对象去触发target对象中的actio行为来最终处理事件。目标对象 指定最终处理事件的对象 而行为selector则是处理事件的方法。
 UIControl 是UIView的子类它又是所有UIKit控件的父类。UIControl的主要作用是创建相应的逻辑将action分发到对应的target，另外90%的情况下，它会根据自身的状态(例如Highlighted, Selected和Disabled等)来绘制用户界面。
 */

#import <UIKit/UIKit.h>

@interface ImageControl : UIControl
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image;
@end

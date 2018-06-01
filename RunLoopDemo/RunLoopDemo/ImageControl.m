//
//  ImageControl.m
//  RunLoopDemo
//
//  Created by Start on 2018/5/31.
//  Copyright © 2018年 Start. All rights reserved.
/*
 http://www.cocoachina.com/ios/20160111/14932.html
 如果是想提供自定义的跟踪行为，则可以重写以下几个方法：
 - (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
 - (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
 - (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
 - (void)cancelTrackingWithEvent:(UIEvent *)event
 这四个方法分别对应的时跟踪开始、移动、结束、取消四种状态
 */

/*
 观察或修改分发target的行为消息对于一个给定事件 UIControl会调用sendAction:to:froEvent:来将行为转发到UIApplication对象 再由UIApplication对象调用其sendAction:to:fromSender:forEvent:方法来将消息分发到指定的target上,而如果我们没有指定target，则会将事件分发到响应链上第一个想处理消息的对象上。而如果子类想监控或修改这种行为的话，则可以重写这个方法。
 */
#import "ImageControl.h"

@implementation ImageControl
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
       // self.backgroundColor = [UIColor blueColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.image = image;
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, frame.size.height-44, frame.size.width, 44);
        label.text = title;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        [self addSubview:imageView];
        [self addSubview:label];
    }
    return self;
}

-(void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    // 将事件传递到对象本身来处理
    [super sendAction:@selector(handleAction:) to:self forEvent:event];
}
-(void)handleAction:(id)sender
{
    NSLog(@"handle Action");
}
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}
@end

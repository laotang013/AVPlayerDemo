//
//  DrawCircel.h
//  RunLoopDemo
//
//  Created by Start on 2018/6/1.
//  Copyright © 2018年 Start. All rights reserved.
/*
 
 */

#import <UIKit/UIKit.h>
typedef NSString *(^DrawCirleRetureString)(NSString *str);
@interface DrawCircel : UIView
/**测试返回值*/
@property(nonatomic,copy)DrawCirleRetureString drawCircleBlock;
@end

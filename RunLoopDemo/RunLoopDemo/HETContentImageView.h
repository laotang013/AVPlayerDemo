//
//  HETContentImageView.h
//  RunLoopDemo
//
//  Created by Start on 2018/6/14.
//  Copyright © 2018年 Start. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HETContentImageView : UIView
@property (nonatomic, strong) UIView *contentView;
- (void)updateWithProgress:(CGFloat)progress;
@end

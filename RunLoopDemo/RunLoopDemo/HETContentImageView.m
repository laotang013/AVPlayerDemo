//
//  HETContentImageView.m
//  RunLoopDemo
//
//  Created by Start on 2018/6/14.
//  Copyright © 2018年 Start. All rights reserved.
//

#import "HETContentImageView.h"

@implementation HETContentImageView
-(void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    self.clipsToBounds = YES;
    if (![self.subviews containsObject:_contentView]) {
        [self addSubview:_contentView];
    }
}
//更新frame
- (void)updateWithProgress:(CGFloat)progress
{
   self.contentView.frame = CGRectMake(CGRectGetWidth(self.bounds) * progress * 0.50, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}
@end

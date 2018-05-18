//
//  TPPlayerHandle.h
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPPlayerHandle : NSObject

-(id)initWithUrl:(NSURL *)assetURL;

@property(nonatomic,strong,readonly) UIView *view;
@end

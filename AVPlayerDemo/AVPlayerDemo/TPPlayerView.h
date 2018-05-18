//
//  TPPlayerView.h
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPTransport.h"
@class AVPlaer;
@interface TPPlayerView : UIView<TPTransport>
@property(nonatomic,strong)UIView *navigationBar;
@property(nonatomic,strong)UIView *toolBar;
@property(nonatomic,strong)UIButton *playItem;
/**delegate*/
@property (weak, nonatomic) id <TPTransportDelegate> delegate;;


-(id)initWithPlayer:(AVPlayer *)player;
@end

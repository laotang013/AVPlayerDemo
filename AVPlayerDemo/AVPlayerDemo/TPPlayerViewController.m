//
//  TPPlayerViewController.m
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
//

#import "TPPlayerViewController.h"
#import "TPPlayerHandle.h"
@interface TPPlayerViewController ()
@property (nonatomic,strong) TPPlayerHandle *playerHandle;
@end

@implementation TPPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playerHandle = [[TPPlayerHandle alloc]initWithUrl:self.assetURL];
    UIView *playerView = self.playerHandle.view;
    playerView.frame = self.view.frame;
    [self.view addSubview:playerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

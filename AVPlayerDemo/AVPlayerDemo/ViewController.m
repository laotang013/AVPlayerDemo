//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by Start on 2018/5/17.
//  Copyright © 2018年 Start. All rights reserved.
//

#import "ViewController.h"
#import "TPPlayerViewController.h"
@interface ViewController ()
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSURL *streamingURL;
@end
#define LOCAL_SEGUE        @"localSegue"
#define STREAMING_SEGUE @"streamingSegue"
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.localURL = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:LOCAL_SEGUE] && !self.localURL) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSURL *url = [segue.identifier isEqualToString:LOCAL_SEGUE] ? self.localURL : self.streamingURL;
    TPPlayerViewController *controller = [segue destinationViewController];
    controller.assetURL = url;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

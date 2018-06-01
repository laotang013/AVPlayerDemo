//
//  ViewController.m
//  RunLoopDemo
//
//  Created by Start on 2018/5/29.
//  Copyright © 2018年 Start. All rights reserved.
//
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry/Masonry.h>
#import "ViewController.h"
#import "ImageControl.h"
#import "CircurlarSlider.h"
#import "DrawCircel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test4];
}

-(void)test1
{
    
    
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 2;
    [self.view addSubview:label];
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.view).offset(100);
        //        make.size.equalTo(CGSizeMake(100, 44));
    }];
    label.text = @"今天是个好天气今天是个好天气今天是个好天气今天是个好天气今天是个好天气今天是个好天气今天是个好天气";
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = [UIColor redColor];
}

-(void)test2
{
    
    //[self performSelector:@selector(doIt)];
    ImageControl *imageControl = [[ImageControl alloc]initWithFrame:CGRectMake(50, 100, 100, 120) title:@"今天天气不错" image:[UIImage imageNamed:@"integral_icon_shoppingMall"]];
    [self.view addSubview:imageControl];
    [imageControl addTarget:self action:@selector(imageControl:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)test3
{
    CircurlarSlider *cirCurSlider = [[CircurlarSlider alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-150, [UIScreen mainScreen].bounds.size.height/2-150, 300, 300)];
    cirCurSlider.backgroundColor = [UIColor grayColor];
    [self.view addSubview:cirCurSlider];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)test4
{
    DrawCircel *drawCircel = [[DrawCircel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    //drawCircel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:drawCircel];
}
-(void)imageControl:(id)sender
{
    NSLog(@"sender:%@",sender);
}


@end

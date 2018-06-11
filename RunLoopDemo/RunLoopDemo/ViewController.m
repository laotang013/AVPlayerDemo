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
#import <SDWebImage/UIImageView+WebCache.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self imageViewDemo];
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
    drawCircel.drawCircleBlock = ^NSString *(NSString *str) {
        NSLog(@"draw--:%@",str);
        return @"你好";
    };
}
-(void)imageControl:(id)sender
{
    NSLog(@"sender:%@",sender);
}
-(void)testGCD
{
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 任务1
        NSLog(@"任务1");
    });
    dispatch_async(queue, ^{
        // 任务2
        NSLog(@"任务2");
    });
    dispatch_async(queue, ^{
        // 任务3
        NSLog(@"任务3");
    });
    dispatch_barrier_async(queue, ^{
        // 任务4
        NSLog(@"任务4");
    });
    dispatch_async(queue, ^{
        // 任务5
        NSLog(@"任务5");
    });
    dispatch_async(queue, ^{
        // 任务6
        NSLog(@"任务6");
    });
}


-(void)testGCDApplay
{
    // dispatch_apply替换（当且仅当处理顺序对处理结果无影响环境），输出顺序不定，比如1098673452
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*! dispatch_apply函数说明
     *
     *  @brief  dispatch_apply函数是dispatch_sync函数和Dispatch Group的关联API
     *         该函数按指定的次数将指定的Block追加到指定的Dispatch Queue中,并等到全部的处理执行结束
     *
     *  @param 10    指定重复次数  指定10次
     *  @param queue 追加对象的Dispatch Queue
     *  @param index 带有参数的Block, index的作用是为了按执行的顺序区分各个Block
     *
     */
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zd",index);
        if (index == 5) {
            dispatch_suspend(queue);
            
        }
        
    });
}

/*
 死锁
 在主线程中，往主队列同步提交了任务一，因为往queue中提交block，总是追加到队列尾部。而queue执行block的顺序为先进先出。
 而任务二因为任务一的sync，被阻塞了，他需要等任务一执行完才能被执行。两者互相等待
 
 如果同步sync提交了一个block到一个串行队列，而提交Block这个动作所处的线程也是当前队列，就会引起死锁。
 */

-(void)testSyncMainGCD
{
    /*
     sync提交block，首先阻塞的当前提交的Block的线程(简单理解下就是阻塞sync之后的代码)
     而在队列中轮到sync提交的block仅仅阻塞串行队列queue而不会阻塞并行queue。
     */
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务一");
    });

//    sleep(3);
    NSLog(@"任务二");
    
    /*
     唯一的区别就是：dispatch_barrier_sync有GCD的sync共有特性，会阻塞提交Block的当前线程，而dispatch_barrier_async是异步提交，不会阻塞。
     */

}

-(void)imageViewDemo
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 150, 200, 150)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://200.200.200.58:8981/group2/M01/10/D4/yMjIOlsaOeqACwkDAAPPEkhUZfE899.jpg"] placeholderImage:[UIImage imageNamed:@"integral_icon_shoppingMall"]];
    [self.view addSubview:imageView];
    
}

@end

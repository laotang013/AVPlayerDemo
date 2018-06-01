//
//  main.m
//  RunLoopDemo
//
//  Created by Start on 2018/5/29.
//  Copyright © 2018年 Start. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"开始");
        int number = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
       // return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        NSLog(@"结束");
        //#【验证结果】：只会打印开始，并不会打印结束。
        /*
          说明在UIApplicationMain函数内部开启了一个和主线程相关的runloop(保证主线程不会被销毁)导致UIApplication不会返回。一直在运行中。也保证了程序的持续运行。
         */
        return number;
    }
}

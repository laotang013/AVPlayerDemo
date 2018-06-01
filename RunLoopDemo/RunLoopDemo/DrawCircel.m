
//
//  DrawCircel.m
//  RunLoopDemo
//
//  Created by Start on 2018/6/1.
//  Copyright © 2018年 Start. All rights reserved.
//http://www.cocoachina.com/ios/20170809/20187.html

#import "DrawCircel.h"

@implementation DrawCircel

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 80, 80)];
    [[UIColor redColor]setFill];
    [bezierPath fill];
    UIImage *setImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *iconImageView = [[UIImageView alloc]initWithImage:setImage];
    iconImageView.frame = CGRectMake(0, 0, 100, 100);
    [self addSubview:iconImageView];
}


- (void)drawRect:(CGRect)rect {
    /*
     1.获取上下文
     2.绘制图形
     3.渲染图形
     */
    [self test1:rect];
    NSLog(@"drawRect");
    
}

-(void)test1:(CGRect)rect
{
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, 80, 0, M_PI*2, 0);
    CGContextClip(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, 40, 0, M_PI*2, 0);
    CGContextClip(ctx);
    [[UIColor redColor]set];
    CGContextSetLineWidth(ctx, 40);
    CGContextDrawPath(ctx, kCGPathStroke);
    UIImage *image = [UIImage imageNamed:@"integral_icon_shoppingMall"];
    //    CGContextClipToMask(ctx, self.bounds, image.CGImage);
    //
    [image drawInRect:rect];
}


-(void)test2:(CGRect)rect
{
    //push UIGraphicsPushContext(context)把context压入栈中，并把context设置为当前绘图上下文
    [[UIColor redColor] setFill];
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [[UIColor blackColor] setFill];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    UIRectFill(CGRectMake(90, 200, 100, 100)); // red color
    
}

-(void)test3:(CGRect)rect
{
  /*
   iOS的绘图必须在一个上下文中绘制，所以在绘图之前要获取一个上下文。如果是绘制图片就需要获取一个图片上下文；如果是绘制其他的图视图，就需要一个非图片上下文。对于上下文的理解，可以认为就是一张画布，然后在上面进行绘图操作。
   context：图形上下文，可以通过UIGraphicsGetCurrentContext:获取当前视图的上下文
   
   imageContext：图片上下文，可以通过UIGraphicsBeginImageContextWithOptions:获取一个图片上下文，然后绘制完成后，调用UIGraphicsGetImageFromCurrentImageContext获取绘制的图片，最后要记得关闭图片上下文UIGraphicsEndImageContext
   
  图形的绘制需要绘制一个路径，然后再把路径渲染出来，而CGPathRef就是CoreGraphics框架中的路径绘制类，UIBezierPath是封装CGPathRef的面向OC的类，使用更加方便，但是一些高级特性还是不及CGPathRef
   
   drawLayer:inContext:
   
   */
}

/*
test4. 在drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx也可以实现绘图任务
 而为了调用该方法需要给图层的delegate设置代理对象其中代理对象不能是UIView对象。因为UIView对象已经是他内部根层的隐式代理
 */
/*
 当UIView需要显示时，它内部的层会准备好一个CGContextRef(图形上下文)，然后调用delegate(这里就是UIView)的drawLayer:inContext:方法，并且传入已经准备好的CGContextRef对象。而UIView在drawLayer:inContext:方法中又会调用自己的drawRect:方法。平时在drawRect:中通过UIGraphicsGetCurrentContext()获取的就是由层传入的CGContextRef对象，在drawRect:中完成的所有绘图都会填入层的CGContextRef中，然后被拷贝至屏幕。
 */
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    NSLog(@"drawLayer");
    //[super drawLayer:layer inContext:ctx]会让系统自动调用此view的drawRect:方法，至此self.layer画出来了
    [super drawLayer:layer inContext:ctx];
}

- (void)drawSomething{
    CGContextRef context = UIGraphicsGetCurrentContext();//获取上下文
    CGMutablePathRef path = CGPathCreateMutable();//创建路径
    CGPathMoveToPoint(path, nil, 20, 50);//移动到指定位置（设置路径起点）
    CGPathAddLineToPoint(path, nil, 20, 100);//绘制直线（从起始位置开始）
    CGContextAddPath(context, path);//把路径添加到上下文（画布）中
    
    //设置图形上下文状态属性
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);//设置笔触颜色
    CGContextSetRGBFillColor(context, 0, 1.0, 0, 1);//设置填充色
    CGContextSetLineWidth(context, 2.0);//设置线条宽度
    CGContextSetLineCap(context, kCGLineCapRound);//设置顶点样式
    CGContextSetLineJoin(context, kCGLineJoinRound);//设置连接点样式
    CGFloat lengths[2] = { 18, 9 };
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetShadowWithColor(context, CGSizeMake(2, 2), 0, [UIColor blackColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);//最后一个参数是填充类型
}
@end

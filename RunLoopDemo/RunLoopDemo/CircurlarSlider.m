//
//  CircurlarSlider.m
//  RunLoopDemo
//
//  Created by Start on 2018/5/31.
//  Copyright © 2018年 Start. All rights reserved.
//

#import "CircurlarSlider.h"
#define ToRad(deg)         ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ( (180.0 * (rad)) / M_PI )
#define SQR(x)            ( (x) * (x) )
#define SLIDER_SIZE 320
#define BACKGROUND_WIDTH 60
#define LINE_WIDTH 40
#define SAFEAREA_PADDING 60
@implementation CircurlarSlider
{
    int radius;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews
{
    self.opaque = NO;
    radius = self.frame.size.width/2-SAFEAREA_PADDING;
    self.angle = 360;
    
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //获取当前图形的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //绘制背景
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI*2, 0);
    [[UIColor blackColor]setStroke];
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //线的宽度
    CGContextSetLineWidth(ctx, BACKGROUND_WIDTH);
    //kCGPathStroke 画线来标记路径的边界或边缘,使用选中的绘图色 kCGPathFillStroke 组合绘图和填充。用当前填充色填充路径,并用当前绘图色绘制路径边界。
    CGContextDrawPath(ctx, kCGPathStroke);
    //创建maskImage
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    CGContextAddArc(imageCtx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, ToRad(self.angle), 0);
    [[UIColor redColor]set];
    //创建shaow
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), self.angle/20, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(imageCtx, LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    CGFloat components[8] = {
        0.0, 0.0, 1.0, 1.0,     // 开始颜色(RGB)
        1.0, 0.0, 1.0, 1.0      //终止颜色(RGB)
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    /*
     *第一个参数：颜色空间
     *第二个参数：CGFloat数组，指定渐变的开始颜色，终止颜色，以及过度色（如果有的话）
     *第三个参数：指定每个颜色在渐变色中的位置，值介于0.0-1.0之间
     *                      0.0表示最开始的位置，1.0表示渐变结束的位置
     *第四个参数：渐变中使用的颜色数
     */
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    (void)(CGColorSpaceRelease(baseSpace)), baseSpace = NULL;
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    (void)(CGGradientRelease(gradient)), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    //绘制手柄
    /*
     绘制手柄的位置  --> 需要将一个标量值转换为CGPoint
     */
    [self drawTheHandle:ctx];
}
-(void) drawTheHandle:(CGContextRef)ctx{
     CGContextSaveGState(ctx);
     CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
     CGPoint handleCenter =  [self pointFromAngle:self.angle];
    [[UIColor colorWithWhite:1.0 alpha:0.7]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, LINE_WIDTH, LINE_WIDTH));
    CGContextRestoreGState(ctx);
}
-(CGPoint)pointFromAngle:(int)angleInt
{
    //指定一个角度值，然后计算出在圆周上面的位置，当然需要圆周的中心点和半径
    //使用sin函数在使用sin函数时,需要一个Y坐标值 而cos函数则需要一个X坐标值.
    /*
     point.y = center.y + (radius * sin(angle));
     point.x = center.x + (radius * cos(angle));
     */
    //中心点
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2-LINE_WIDTH/2, self.frame.size.height/2-LINE_WIDTH/2);
    CGPoint result;
    result.x = round(centerPoint.x+radius*cos(ToRad(-angleInt)));
    result.y = round(centerPoint.y+radius*sin(ToRad(-angleInt)));
    return result;
    
}

//跟踪用户的操作
//当在控件的bound内发生了一个触摸事件，首先会调用控件的beginTrackingWithTouch方法。
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}
//该方法返回的BOOL值标示是否继续跟踪touch事件。
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint = [touch locationInView:self];
    NSLog(@"lastPoint :%@",NSStringFromCGPoint(lastPoint));
    //获取手柄的位置
    CGPoint handlePoint = [self pointFromAngle:self.angle];
    NSLog(@"手柄的位置:%@", NSStringFromCGPoint(handlePoint));
    
    
    if (CGRectContainsPoint(CGRectMake(handlePoint.x-5, handlePoint.y+20, 20, 20), lastPoint)) {
      [self movehandle:lastPoint];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
}
-(void)movehandle:(CGPoint)lastPoint{
    //获取中心点
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2,
                                   self.frame.size.height/2);
    
   
    float currentAngle = AngleFromNorth(centerPoint, lastPoint,CGPointZero, NO);
    int angleInt = floor(currentAngle);
    self.angle = 360 - angleInt;
    [self setNeedsDisplay];
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2,CGPoint p3, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    
    
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}
@end

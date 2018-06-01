//
//  ViewController.h
//  RunLoopDemo
//
//  Created by Start on 2018/5/29.
//  Copyright © 2018年 Start. All rights reserved.
/*
 自定义控件
   1.选择正确的初始化方式
     1.1 如果你有多个自定义的designated Initializer 最终都应该指向一个全能的初始化构造器。
   2.调整布局的时机
     2.1 基于frame来布局 应该确保在初始化的时候只添加视图，而不去设置它们的frame，把设置子视图frame的过程全部放到layoutSubViews方法里.
     2.2 使用layoutSubViews有几点需要注意
         1.不要依赖前一次的计算结果，应该总是根据当前最新值来计算。
         2.由于 layoutSubviews 方法是在自身的 bounds 发生改变的时候调用， 因此 UIScrollView 会在滚动时不停地调用，当你只关心 Size 有没有变化的时候，可以把前一次的 Size 保存起来，通过与最新的 Size 比较来判断是否需要更新，在大多数情况下都能改善性能
     2.3 基于Auto Layout约束
         可以直接在initWithFrame中就把约束添加上去，不要重写layoutSubViews方法，因为这种情况下它的默认实现就是根据约束来计算frame。
    3.1 当执行viewDidLoad方法时不要依赖self.View的Size
        1.因为viewDidLoad方法被调用的时候，self.View才刚刚被初始化，此时它的容器还没有对他的frame进行设置当访问 ViewController 的 view 的时候，ViewController 会先执行 loadViewIfRequired 方法，如果 view 还没有加载，则调用 loadView，然后是 viewDidLoad 这个钩子方法，最后是返回 view，容器拿到 view 后，根据自身的属性（如 edgesForExtendedLayout、判断是否存在 tabBar、判断 navigationBar 是否透明等）添加约束或者设置 frame
  4. drawRect/CALayer与动画
        4.1 drawRect方法很适合做自定义的控件，当你需要更新UI的时候，只要用setNeedDisplay标记一下就行了。
        4.2 用CALayer代替UIView.CALayer节省内存，而且更适合去做一个图层，它不会接受事件也不会响应链中的一员。但是他能够响应父视图layer的尺寸变化。
 4.3 实际上UIView是CALayer的delegate,如果CALayer没有内容的话，会回调给UIView的displayLayer或者drawLayer:inContext方法。UIView 在其中调用 drawRect ，draw 完后的图会缓存起来，除非使用 setNeedsDisplay 或是一些必要情况，否则都是使用缓存的图。
 5. 当触摸屏幕的时候发生了什么。
     1.当屏幕收到一个touch的时候，iOS需要寻找一个合适的对象来处理事件(touch或者手势)要用到 - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
 2.该方法会首先在application的keyWindow上调用(UIWindow也是UIView的子类)，并且该方法的返回值将被用来处理事件。如果这个View(无论window还是普通的UIView)的userInteractionEnabled属性设置为NO,则它的hieTest:永远返回nil.这意味着它和它的子视图没有机会去接收和处理事件。如果 userInteractionEnabled 属性为 YES，则会先判断产生触摸的pointInside是否发生在自己的bounds内。如果没有则返回nil.如果没有也将返回 nil；如果 point 在自己的范围内，则会为自己的每个子视图调用 hitTest: 方法，只要有一个子视图通过这个方法返回一个 UIView 对象，那么整个方法就一层一层地往上返回；如果没有子视图返回 UIView 对象，则父视图将会把自己返回。
 了解了事件分发的这些特点后，还需要知道最后一件事：UIView 如何判断产生事件的 point 是否在自己的范围内? 答案是通过 pointInside 方法，这个方法的默认实现类似于这样：
 
     // point 被转化为对应视图的坐标系统
     - (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
     return CGRectContainsPoint(self.bounds, point);
     }
 
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end


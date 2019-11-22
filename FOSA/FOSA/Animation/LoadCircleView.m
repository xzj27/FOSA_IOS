//
//  LoadCircleView.m
//  FOSA
//
//  Created by hs on 2019/11/22.
//  Copyright © 2019 hs. All rights reserved.
//

#import "LoadCircleView.h"

@implementation LoadCircleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        UIView *circleView=[[UIView alloc]init];
        circleView.frame=CGRectMake(0, 0,frame.size.width,frame.size.height);
        circleView.backgroundColor=[UIColor blackColor];
        [self addSubview: circleView];
        
       CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)[UIColor blackColor].CGColor];
        gradientLayer.locations = @[@0.2,@1.0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1.0, 0);
        gradientLayer.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [circleView.layer insertSublayer:gradientLayer atIndex:0];
        
        CAShapeLayer *layer=[[CAShapeLayer alloc]init];
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathAddRelativeArc(pathRef, nil,frame.size.width/2.0,frame.size.height/2.0,frame.size.width<frame.size.height?frame.size.width/2.0-5:frame.size.height/2.0-5,0, 2*M_PI);
        layer.path=pathRef;
        layer.lineWidth=5;
        layer.fillColor=[UIColor clearColor].CGColor;
        layer.strokeColor=[UIColor blackColor].CGColor;
        CGPathRelease(pathRef);
        circleView.layer.mask=layer;
        
        CABasicAnimation *animation=[CABasicAnimation         animationWithKeyPath:@"transform.rotation.z"];  ;
        // 设定动画选项
        animation.duration = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.repeatCount =HUGE_VALF;
        // 设定旋转角度
        animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
        animation.toValue = [NSNumber numberWithFloat:2 * M_PI]; // 终止角度
        [circleView.layer addAnimation:animation forKey:@"rotate-layer"];
        
        UILabel *label=[[UILabel alloc]init];
         label.text=@"Loading";
         label.font=[UIFont systemFontOfSize:15];
         label.textAlignment=NSTextAlignmentCenter;
         label.frame=CGRectMake(0, 0,frame.size.width,frame.size.height);
         label.backgroundColor=[UIColor clearColor];
         [self addSubview:label];
        
    }
    return self;
}
@end

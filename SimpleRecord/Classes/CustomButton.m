//
//  CustomButton.m
//  ParticleButton
//
//  Created by FYZH on 14-2-22.
//  Copyright (c) 2014年 Liang HaiHu. All rights reserved.
//
#define AnimationDuration 2.0
#define AnimationDurationMax AnimationDuration

//#define RotateDuration 0

#import "CustomButton.h"
#import "EmitterView.h"
@implementation CustomButton
{
    CAEmitterLayer *fireEmitter; //1
    UIView *emitterView;
    CGFloat preRotateValue;
    NSInteger perimeter;
    NSInteger radius;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"CustomButton");
        
        self.backgroundColor = [UIColor blackColor];
        emitterView = [[EmitterView alloc] initWithFrame:CGRectZero];
        [self addSubview:emitterView];
        preRotateValue =(M_PI*4.2)/4;
        perimeter = frame.size.width/30 * M_PI*2;
        
        
        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:(AnimationDurationMax/perimeter) target:self selector:@selector(updataInterface) userInfo:nil repeats:YES];
        [timer fire];
        
        emitterView.layer.transform = CATransform3DRotate(CATransform3DIdentity, preRotateValue, 0, 0, 1);
        radius = frame.size.width/3.8;
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
}


-(void)updataInterface
{
    preRotateValue = (preRotateValue+ M_PI *AnimationDurationMax/perimeter);
    emitterView.layer.transform = CATransform3DRotate(CATransform3DIdentity, -preRotateValue, 0, 0, 1);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect
{
    //绘制路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, rect.size.width/2, rect.size.height/2, radius, 0, 2*M_PI, YES);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = AnimationDuration;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = MAXFLOAT;
    animation.path = path;

    
    [emitterView.layer addAnimation:animation forKey:@"test"];
}

@end

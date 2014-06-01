//
//  EmitterView.m
//  ParticleButton
//
//  Created by FYZH on 14-2-22.
//  Copyright (c) 2014年 Liang HaiHu. All rights reserved.
//

#import "EmitterView.h"

@implementation EmitterView
{
    CAEmitterLayer *fireEmitter; //1
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //set ref to the layer
        fireEmitter = (CAEmitterLayer *)self.layer;
        //fireEmitter.emitterPosition = CGPointMake(0, 0);  //坐标
        fireEmitter.emitterSize = CGSizeMake(1, 1);       //粒子大小
        fireEmitter.renderMode = kCAEmitterLayerPoints; //递增渲染模式
        fireEmitter.emitterShape = kCAEmitterLayerLine;

        
        CAEmitterCell *fire = [CAEmitterCell emitterCell];
        fire.birthRate  =50;     //粒子出生率
        fire.lifetime   = 1.0;    //粒子生命时间
        fire.lifetimeRange = 3;   //生命时间变化范围

        fire.color = [[UIColor colorWithRed:24/255.0 green:188/255.0 blue:131/255.0 alpha:0.4] CGColor];  //粒子颜色
        //fire.contents = (id)[[UIImage imageNamed:@"Particles_fire.png"] CGImage];
        fire.contents = (id)[[UIImage imageNamed:@"snow1.png"] CGImage]; //cell内容，一般是一个CGImage
        fire.scale = 0.1;
        fire.velocity = 10;     //速度
        fire.velocityRange = 1; //速度范围
        fire.emissionRange = M_PI/4; //发射角度
        fire.scaleSpeed = 0;  //变大速度
        fire.spin = 3;         //旋转
        [fire setName:@"fire"];  //cell名字，方便根据名字以后查找修改
        
        //add the cell to the layer and we're done
        fireEmitter.emitterCells = [NSArray arrayWithObject:fire];
    }
    return self;
}

+ (Class)layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

@end

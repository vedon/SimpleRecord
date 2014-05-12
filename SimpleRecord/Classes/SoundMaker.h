//
//  SoundMaker.h
//  SimpleRecord
//
//  Created by vedon on 2/3/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundTouch.h"



@interface SoundMaker : NSObject
-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange;

-(void)processingSample:(soundtouch::SAMPLETYPE *)inSamples
                 length:(NSUInteger)nSamples;
-(void)getProcessedSample:(soundtouch::SAMPLETYPE *)outSamples
                   length:(NSInteger)nSamples
           completedBlock:(void (^)(short * data))block;

-(void)save;
@end

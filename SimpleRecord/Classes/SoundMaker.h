//
//  SoundMaker.h
//  SimpleRecord
//
//  Created by vedon on 2/3/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundTouch.h"
#import <AudioToolbox/AudioToolbox.h>


@interface SoundMaker : NSObject
@property (assign ,nonatomic) AudioStreamBasicDescription audio_des;


-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange;
-(void)processingSample:(soundtouch::SAMPLETYPE *)inSamples
                 length:(NSUInteger)nSamples;
-(void)getProcessedSampleDataLength:(int)data_length
                     completedBlock:(void (^)(soundtouch::SAMPLETYPE * data,uint rev_sampLen))block;

-(void)save;
@end

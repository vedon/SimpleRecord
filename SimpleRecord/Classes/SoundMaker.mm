//
//  SoundMaker.m
//  SimpleRecord
//
//  Created by vedon on 2/3/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "SoundMaker.h"
#import "STTypes.h"
#import "FIFOSampleBuffer.h"
#import "WaveHeader.h"

@implementation SoundMaker
{
    soundtouch::SoundTouch mSoundTouch;
    NSMutableData *soundTouchDatas;
}

-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange    
{
    mSoundTouch.setSampleRate(sampleRate);
    mSoundTouch.setChannels(channel);
    mSoundTouch.setTempoChange(tempoChange);
    mSoundTouch.setPitchSemiTones(semiTones);
    mSoundTouch.setRateChange(rateChange);
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 16);
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 8);
    
    soundTouchDatas = [[NSMutableData alloc] init];
}

-(void)processingSample:(soundtouch::SAMPLETYPE *)inSamples
                 length:(NSUInteger)nSamples
{
    /*
     一般数据流都是字节流，也就是说，sample的大小和声道、位的声音参数
     
     有关，假如sampleBuffer指针指向一个 长度为64bytes的一个PCM数据缓冲区，16位2声道
     
     ，那么实际上这里只存放了(16*2)/8=4bytes,64/4=16;16个sample
     */
    mSoundTouch.putSamples(inSamples, nSamples/2);
}

-(void)getProcessedSample:(soundtouch::SAMPLETYPE *)outSamples
                   length:(NSInteger)nSamples
           completedBlock:(void (^)())block
{
    
    
    short *samples = (short *)malloc(sizeof(short)* nSamples);
    memset(samples, 0, nSamples);
//    [soundTouchDatas appendBytes:samples length:nSamples*2];
//    block();
    
    int numSamples = 0;
    do {
        numSamples = mSoundTouch.receiveSamples(samples, nSamples);
        if (numSamples <= 0) {
            free (samples);
            block();
            break;
        }else
        {
            [soundTouchDatas appendBytes:samples length:numSamples * 2];
        }
    } while (numSamples > 0);
    
}

-(void)save
{
    NSMutableData *wavDatas = [[NSMutableData alloc] init];
    
    int fileLength = soundTouchDatas.length;
    void *header = createWaveHeader(fileLength, 1, 16000, 16);
    [wavDatas appendBytes:header length:44];
    [wavDatas appendData:soundTouchDatas];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"soundtouch.wav"];
    [wavDatas writeToFile:filePath atomically:YES];
    
    wavDatas = nil;
    soundTouchDatas = nil;
}
@end

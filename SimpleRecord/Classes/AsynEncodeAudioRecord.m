//
//  AsynEncodeAudioRecord.m
//  SimpleRecord
//
//  Created by vedon on 26/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "AsynEncodeAudioRecord.h"


@implementation AsynEncodeAudioRecord
{
    NSString * audioFilePath;
}
+(id)shareAsynEncodeAudioRecord
{
    static AsynEncodeAudioRecord * shareInstance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AsynEncodeAudioRecord alloc]init];
    });
    return shareInstance;
}

#pragma mark - Public Method
-(void)startPlayer
{
    if (!self.isRecording ) {
        [self.microphone startFetchingAudio];
    }
    self.isRecording = YES;
}

-(void)stopPlayer
{
    if (self.isRecording) {
        [self.microphone stopFetchingAudio];
    }
    self.isRecording = NO;
}

-(void)initializationMicroPhone
{
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

-(void)playFile:(NSString *)filePath
{
    audioFilePath = filePath;
    [self startPlayer];
}


#pragma mark - EZMicrophoneDelegate
-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    [EZAudio printASBD:audioStreamBasicDescription];
    self.recorder = [EZRecorder recorderWithDestinationURL:[self testFilePathURL]
                                           andSourceFormat:audioStreamBasicDescription];
    
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    if( self.isRecording ){
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}

#pragma mark - Utility
-(NSArray*)applicationDocuments {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

-(NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSURL*)testFilePathURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory],audioFilePath]];
}
@end

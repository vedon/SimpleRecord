//
//  AudioFloatPointReader.m
//  SimpleRecord
//
//  Created by vedon on 27/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "AudioFloatPointReader.h"
#import "SoundMaker.h"
#import  <AudioToolbox/AudioToolbox.h>

@interface AudioFloatPointReader()
{
    NSURL * curentPlayFileURL;
    SoundMaker * soundMaker;
    CFURLRef  _destinationFileURL;
    ExtAudioFileRef   _destinationFile;
    NSMutableData * audioData;
}
@end
@implementation AudioFloatPointReader

+(id)shareAudioFloatPointReader
{
    static AudioFloatPointReader * shareReader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareReader = [[AudioFloatPointReader alloc]init];
    });
    return shareReader;
}

-(void)playAudioFile:(NSURL *)filePath
{
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    curentPlayFileURL      = filePath;
    self.audioFile         = [EZAudioFile audioFileWithURL:filePath];
    _audioDuration         = (float)_audioFile.totalDuration;
    _totalFrame            = (float)_audioFile.totalFrames;
    self.audioFile.audioFileDelegate = self;
}

#pragma mark - Public
-(void)seekToFilePostion:(SInt64)position
{
    [_audioFile seekToFrame:position];
}

-(void)startReader
{
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }
    audioData = [[NSMutableData alloc]init];
#if IsUserSoundMakeToPlayAudio
    if (!soundMaker) {
        soundMaker = [[SoundMaker alloc]init];
        [soundMaker initalizationSoundTouchWithSampleRate:441000 Channels:2 TempoChange:50 PitchSemiTones:12 RateChange:12];
        [soundMaker setAudio_des:self.audioFile.clientFormat];
        
    }
    [self getExtAudioFileWriterDefaultSettiong];
#endif
    
}

-(void)stopReader
{
    if ([[EZOutput sharedOutput] isPlaying]) {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];

    }
#if IsUserSoundMakeToPlayAudio
    [AudioFloatPointReader checkResult:ExtAudioFileDispose(_destinationFile)
                             operation:"Failed to dispose extended audio file in recorder"];
#endif
}

-(BOOL)isEof
{
    return _eof;
}

-(BOOL)isPlaying
{
    return  [EZOutput sharedOutput].isPlaying;
}

-(void)getExtAudioFileWriterDefaultSettiong
{
    AudioStreamBasicDescription destinationFormat;
    destinationFormat.mFormatID = kAudioFormatLinearPCM;
    destinationFormat.mChannelsPerFrame = 1;
    destinationFormat.mBitsPerChannel = sizeof(AudioUnitSampleType) * 8;
    destinationFormat.mBytesPerPacket = destinationFormat.mBytesPerFrame =sizeof(AudioUnitSampleType);
    destinationFormat.mFramesPerPacket = 1;
    destinationFormat.mFormatFlags = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
    destinationFormat.mSampleRate = 44100.0;
    
    // Create the extended audio file
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",documentsDirectoryPath,@"Test.caf"]];
    
    _destinationFileURL = _destinationFileURL = (__bridge CFURLRef)url;
    [AudioFloatPointReader checkResult:ExtAudioFileCreateWithURL(_destinationFileURL,
                                                   kAudioFileCAFType,
                                                   &destinationFormat,
                                                   NULL,
                                                   kAudioFileFlags_EraseFile,
                                                   &_destinationFile)
               operation:"Failed to create ExtendedAudioFile reference"];
    // Set the client format
    AudioStreamBasicDescription clientFormat = destinationFormat;
    if( destinationFormat.mFormatID != kAudioFormatLinearPCM ){
        [EZAudio setCanonicalAudioStreamBasicDescription:destinationFormat
                                        numberOfChannels:destinationFormat.mChannelsPerFrame
         
                                             interleaved:YES];
    }
    UInt32 propertySize = sizeof(clientFormat);
    [EZAudio checkResult:ExtAudioFileSetProperty(_destinationFile,
                                                 kExtAudioFileProperty_ClientDataFormat,
                                                 propertySize,
                                                 &destinationFormat)
               operation:"Failed to set client data format on destination file"];
    
    // Instantiate the writer
    [EZAudio checkResult:ExtAudioFileWriteAsync(_destinationFile, 0, NULL)
               operation:"Failed to initialize with ExtAudioFileWriteAsync"];
}

#pragma mark - Private
-(void)playNextSong
{
    for (int i =0 ;i < [_playlist count];++i) {
        NSURL * localPath  = [_playlist objectAtIndex:i];
        if ([localPath.path isEqualToString:curentPlayFileURL.path]) {
            [self stopReader];
            if (i == [_playlist count]-1) {
                [self playAudioFile:[_playlist objectAtIndex:0]];
            }else
            {
                [self playAudioFile:[_playlist objectAtIndex:i+1]];
            }
            [self startReader];
            break;
        }
    }
}


-(void)setPlaylist:(NSArray *)playlist
{
    if (_playlist) {
        _playlist = nil;
    }
    _playlist = playlist;
    _isShouldPlayPlaylist = YES;
}
#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
//    NSLog(@"%f",*buffer[0]);
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
        _currentPositionOfAudioFile = (float)framePosition;
    [[NSNotificationCenter defaultCenter]postNotificationName:CurrentPlayFilePostionInfo object:[NSNumber numberWithFloat:_currentPositionOfAudioFile]];

}

#pragma mark - EZOutputDataSource
-(AudioBufferList *)output:(EZOutput *)output
 needsBufferListWithFrames:(UInt32)frames
            withBufferSize:(UInt32 *)bufferSize {
    if( self.audioFile ){
        
        // Reached the end of the file
        if( self.eof ){
            // Here's what you do to loop the file
            if (_isShouldPlayPlaylist) {
                [self playNextSong];
            }else
            {
                [self.audioFile seekToFrame:0];
            }
            self.eof = NO;
        }
        
        // Allocate a buffer list to hold the file's data
        AudioBufferList *bufferList = [EZAudio audioBufferList];
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:bufferList
                        bufferSize:bufferSize
                               eof:&eof];
        self.eof = eof;

#if IsUserSoundMakeToPlayAudio

        int length = bufferList->mBuffers->mDataByteSize/bufferList->mBuffers->mNumberChannels;
        [soundMaker processingSample:(soundtouch::SAMPLETYPE  *)bufferList->mBuffers->mData length:length];
        
        [soundMaker getProcessedSampleDataLength:length
                                  completedBlock:^(soundtouch::SAMPLETYPE * data,uint rev_sampLen) {
            memcpy(bufferList->mBuffers[0].mData, data, rev_sampLen);
        
//            [AudioFloatPointReader checkResult:ExtAudioFileWriteAsync(_destinationFile,frames, bufferList)
//                       operation:"Failed to write audio data to file"];
        }];
#endif
        
        // Reached the end of the file on the last read
        if( eof ){
            [EZAudio freeBufferList:bufferList];
            return nil;
        }
        return bufferList;
        
    }
    return nil;
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    
    
   
    return self.audioFile.clientFormat;
    
}
+(void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

@end

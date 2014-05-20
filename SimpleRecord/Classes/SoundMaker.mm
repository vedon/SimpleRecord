//
//  SoundMaker.m
//  SimpleRecord
//
//  Created by vedon on 2/3/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//
#define DebugLog 1

#import "SoundMaker.h"
#import "STTypes.h"
#import "FIFOSampleBuffer.h"
#import "WaveHeader.h"
@interface SoundMaker()
{
    CFURLRef  _destinationFileURL;
    ExtAudioFileRef   _destinationFile;
}
@end
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
//    mSoundTouch.setSetting(SETTING_USE_AA_FILTER, YES);
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 16);
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 8);
    
    soundTouchDatas = [[NSMutableData alloc] init];
}

-(void)processingSample:(soundtouch::SAMPLETYPE *)inSamples
                 length:(NSUInteger)nSamples
{
    mSoundTouch.putSamples(inSamples, nSamples/2);
}


-(void)getProcessedSampleDataLength:(int)data_length
                     completedBlock:(void (^)(soundtouch::SAMPLETYPE * data,uint rev_sampLen))block
{
    int bufferSize = data_length * sizeof(soundtouch::SAMPLETYPE);
    
    soundtouch::SAMPLETYPE *samples = (soundtouch::SAMPLETYPE *)malloc(bufferSize);
    soundtouch::SAMPLETYPE *sampleContainer = (soundtouch::SAMPLETYPE *)malloc(bufferSize);
    memset(sampleContainer, 0, bufferSize);
    soundtouch::SAMPLETYPE * pointer = sampleContainer;
#if DebugLog
    printf("***********************************\n");
    printf("TotalSampleSize: %d\n",data_length);
#endif
    int numSamples = 0;
    do {
        memset(samples, 0, bufferSize);
        numSamples = mSoundTouch.receiveSamples(samples, data_length);
#if DebugLog
        printf("ReceiveSamples: %d \n",numSamples);
#endif
        if (numSamples <= 0) {
            break;
        }else
        {
            memcpy(pointer, samples,numSamples);
            pointer +=numSamples;
        }
    } while (numSamples != 0);
    if (block) {
        block(sampleContainer,data_length);
    }
    
#if DebugLog
    printf("***********************************\n");
    printf("\n");
    printf("\n");
#endif
    free (samples);
    free (sampleContainer);
}

-(void)save
{
    NSMutableData *wavDatas = [[NSMutableData alloc] init];
    
    int fileLength = soundTouchDatas.length;
    void *header = createWaveHeader(fileLength, 1, 16000, 16);
//    [wavDatas appendBytes:header length:44];
    [wavDatas appendData:soundTouchDatas];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"soundtouch.wav"];
    [wavDatas writeToFile:filePath atomically:YES];
    
    wavDatas = nil;
    soundTouchDatas = nil;
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
    [SoundMaker checkResult:ExtAudioFileCreateWithURL(_destinationFileURL,
                                                                 kAudioFileCAFType,
                                                                 &destinationFormat,
                                                                 NULL,
                                                                 kAudioFileFlags_EraseFile,
                                                                 &_destinationFile)
                             operation:"Failed to create ExtendedAudioFile reference"];
    // Set the client format
    AudioStreamBasicDescription clientFormat = destinationFormat;
    UInt32 propertySize = sizeof(clientFormat);
    [SoundMaker checkResult:ExtAudioFileSetProperty(_destinationFile,
                                                 kExtAudioFileProperty_ClientDataFormat,
                                                 propertySize,
                                                 &destinationFormat)
               operation:"Failed to set client data format on destination file"];
    
    // Instantiate the writer
    [SoundMaker checkResult:ExtAudioFileWriteAsync(_destinationFile, 0, NULL)
               operation:"Failed to initialize with ExtAudioFileWriteAsync"];
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

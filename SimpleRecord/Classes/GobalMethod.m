//
//  GobalMethod.m
//  ClairAudient
//
//  Created by vedon on 16/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "GobalMethod.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "TSLibraryImport.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation GobalMethod

//我的下载
+(void)getExportPath:(NSString *)fileName completedBlock:(void (^)(BOOL isDownloaded,NSString * exportFilePath))block
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString * fileFloder = [documentsDirectoryPath stringByAppendingPathComponent:@"我的下载"];
    NSString *exportPath = [fileFloder stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileFloder]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:fileFloder withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        block(YES,exportPath);
        return;
    }
    block(NO,exportPath);
}


//获取音乐长度
+(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

+(NSString *)getMakeTime;
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

+(NSString *)userCurrentTimeAsFileName
{
    NSDate * date = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * tempFileName = [format stringFromDate:date];
    return tempFileName;
}

+(NSString *)customiseTimeFormat:(NSString *)date
{
    NSDateFormatter * format  = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSDate * tempDate = [format dateFromString:date];
    
    NSDateFormatter * customiseFormat  = [[NSDateFormatter alloc]init];
    [customiseFormat setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [customiseFormat stringFromDate:tempDate];
    return dateStr;
}

+(BOOL)removeItemAtPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:path error: &error];
        if (error) {
            NSLog(@"RemoveItem Error: %@",[error description]);
            return NO;
        }
        return YES;
    }
    return NO;
}

+(CGFloat)getAudioFileLength:(NSURL *)fileURL
{
    ExtAudioFileRef audioFile;
    AudioStreamBasicDescription fileFormat;
    Float32 totalDuration = 0.0;
    
    [GobalMethod checkResult:ExtAudioFileOpenURL((__bridge CFURLRef)(fileURL),&audioFile)
               operation:"Failed to open audio file for reading"];
    UInt32 size = sizeof(fileFormat);
    [GobalMethod checkResult:ExtAudioFileGetProperty(audioFile,kExtAudioFileProperty_FileDataFormat, &size, &fileFormat)
               operation:"Failed to get audio stream basic description of input file"];
    [GobalMethod printASBD:fileFormat];
    SInt64  totalFrames;
    size = sizeof(totalFrames);
    [GobalMethod checkResult:ExtAudioFileGetProperty(audioFile,kExtAudioFileProperty_FileLengthFrames, &size, &totalFrames)
               operation:"Failed to get total frames of input file"];
    
    // Total duration
    totalDuration = totalFrames / fileFormat.mSampleRate;
    return totalDuration;
}

+(NSString *)getExportPath:(NSString *)fileName
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString * fileFloder = [documentsDirectoryPath stringByAppendingPathComponent:@"我的制作"];
    NSString *exportPath = [fileFloder stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileFloder]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:fileFloder withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    return exportPath;
}


+(NSString *)convertSecondToMinute:(CGFloat)time
{
    NSInteger roundDownSecond = floor(time);
    int   h = roundDownSecond / (60 * 60);
    int   m = floor((time - h * 60) / 60);
    int   s = (time - h * 60*60 - m * 60);
    
    NSString * str = nil;
    if (h ==0) {
        if (m == 0 && h == 0) {
            str = [NSString stringWithFormat:@"00:%02d",s];
        }else
        {
            str = [NSString stringWithFormat:@"%02d:%02d",m,s];
        }
        
    }else
    {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d",h,m,s];
    }
    
    
    return str;
}
#pragma mark - OSStatus Utility
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
    return;
	exit(1);
}

#pragma mark - AudioStreamBasicDescription Utility
+(void)printASBD:(AudioStreamBasicDescription)asbd {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}

+(void)localNotificationBody:(NSString *)body
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:2]; //触发通知的时间
        notification.repeatInterval=0; //循环次数，kCFCalendarUnitWeekday一周一次
        
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody=body;
        
        notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        
        notification.applicationIconBadgeNumber = 1; //设置app图标右上角的数字
        
        //下面设置本地通知发送的消息，这个消息可以接受
        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:body forKey:@"content"];
        notification.userInfo = infoDic;
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

+(void)audio_PCMtoMP3WithSourceFile:(NSString *)sourceFile destinationFile:(NSString *)desFile withSampleRate:(NSInteger)sampleRate completedHandler:(void(^)(NSError *error))block
{
    NSString *cafFilePath = sourceFile;
    
    NSString *mp3FilePath = desFile;
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSUTF8StringEncoding], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSUTF8StringEncoding], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192*2;
        const int MP3_SIZE = 8192*2;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_set_brate(lame, 88);
        lame_set_mode(lame, 1);
        lame_set_quality(lame, 2);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            int writeCount = fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
         block(nil);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
       
    }
}

-(void)recrdFromSourceFile:(NSString *)sourceFile destinateFile:(NSString *)destinatedFile frameSize:(UInt32)frameSize
{
    //mp3压缩参数
    lame_t lame = lame_init();
    lame_set_num_channels(lame, 2);
    lame_set_in_samplerate(lame, 88200);
    lame_set_brate(lame, 88);
    lame_set_mode(lame, 1);
    lame_set_quality(lame, 2);
    lame_init_params(lame);
    
    //这种方式初始化的NSData不需要手动释放
    NSMutableData *mp3Data = [[NSMutableData alloc] init];
    
    NSLog(@"record path: %@",sourceFile);
    NSLog(@"out path: %@", destinatedFile);
    FILE *fp;
    fp = fopen([destinatedFile cStringUsingEncoding:NSASCIIStringEncoding], "rb");
    
    long curpos;
    //if(fp) 这句得补上，但是还不确定是否有问题
    while (true)
    {
        //需要手动释放
        NSData *audioData = nil;
        
        curpos = ftell(fp);
        long startPos = ftell(fp);//文件当前读到的位置
        fseek(fp, 0, SEEK_END);
        long endPos = ftell(fp);//文件末尾位置
        long length = endPos - startPos;//剩下未读入文件长度
        fseek(fp, curpos, SEEK_SET);//把文件指针重新置回
        const int PCM_SIZE = frameSize;
        char buff[PCM_SIZE];
        memset(buff, 0, PCM_SIZE);
        if(length > frameSize)
        {
            fread(buff, 1, frameSize, fp);
            audioData = [NSData dataWithBytes:buff length:frameSize];
            short *recordingData = (short *)audioData.bytes;
            int pcmLen = audioData.length;
            int nsamples = pcmLen / 2;
            
            unsigned char buffer[pcmLen];
            
            //执行encode
            int recvLen = lame_encode_buffer(lame, recordingData, recordingData, nsamples, buffer, pcmLen);
            [mp3Data appendBytes:buffer length:recvLen];
        }
        else
        {
            if (YES)
            {
                fread(buff, 1, length, fp);
                audioData = [NSData dataWithBytes:buff length:length];
                short *recordingData = (short *)audioData.bytes;
                int pcmLen = audioData.length;
                int nsamples = pcmLen / 2;
                
                unsigned char buffer[pcmLen];
                
                //执行encode
                int recvLen = lame_encode_buffer(lame, recordingData, recordingData, nsamples, buffer, pcmLen);
                [mp3Data appendBytes:buffer length:recvLen];
                break;
            }
            else
            {
                [NSThread sleepForTimeInterval:0.05];
            }
        }
    }
    
    //写入文件
    [mp3Data writeToFile:destinatedFile atomically:YES];
    
    //释放lame  
    lame_close(lame);  
}

+(void)exportLibrarySongsToLocalFolder:(NSString *)folderName CompletedHandler:(void (^)(NSDictionary * info,NSError * error))handler
{
    TSLibraryImport* importTool = [[TSLibraryImport alloc]init];
    
    MPMediaQuery *listQuery = [MPMediaQuery playlistsQuery];
    NSNumber *musicType = [NSNumber numberWithInteger:MPMediaTypeMusic];
    
    MPMediaPropertyPredicate *musicPredicate = [MPMediaPropertyPredicate predicateWithValue:musicType forProperty:MPMediaItemPropertyMediaType];
    [listQuery addFilterPredicate: musicPredicate];
    //播放列表
    NSArray *playlist = [listQuery items];
    for (MPMediaItem * item in playlist) {
        NSString * exportPath =nil;
        if (folderName) {
            exportPath = [GobalMethod getExportPath:[folderName stringByAppendingString:[item valueForProperty:MPMediaItemPropertyTitle]]];
        }else
        {
            exportPath = [GobalMethod getExportPath:[item valueForProperty:MPMediaItemPropertyTitle]];
        }

        
        NSURL * exportURL = [NSURL URLWithString:exportPath];
        NSURL * exportFileURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
        [importTool importAsset:exportFileURL toURL:exportURL completionBlock:^(TSLibraryImport* import) {
            if (import.status != AVAssetExportSessionStatusCompleted) {
                // something went wrong with the import
                NSLog(@"Error importing: %@", import.error);
                import = nil;
                return;
            }
        }];
    }
    
}

-(void)findArtistList
{
    MPMediaQuery *listQuery = [MPMediaQuery playlistsQuery];
    NSNumber *musicType = [NSNumber numberWithInteger:MPMediaTypeMusic];
    
    MPMediaPropertyPredicate *musicPredicate = [MPMediaPropertyPredicate predicateWithValue:musicType forProperty:MPMediaItemPropertyMediaType];
    [listQuery addFilterPredicate: musicPredicate];
    //播放列表
    NSArray *playlist = [listQuery items];
    for (MPMediaItem * item in playlist) {
        NSDictionary * dic = [self getMPMediaItemInfo:item];
        
    }
}

- (NSDictionary *)getMPMediaItemInfo:(MPMediaItem *)item{
    NSString *title     = [item valueForProperty:MPMediaItemPropertyTitle];;
    NSString *artist    = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumName = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *strTime   = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    NSURL *musicURL     = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"%@",musicURL.absoluteString);
    //计算音乐文件所需要的时间
    
    int seconds = (int)[strTime integerValue];
    int minute = 0;
    if (seconds >= 60) {
        int index = seconds / 60;
        minute = index;
        seconds = seconds - index * 60;
    }
    NSString *musicTime = [NSString stringWithFormat:@"%02d:%02d", minute, seconds];
    //这里依次是 音乐名，艺术家，专辑名，音乐时间，音乐播放路径
    if (!albumName) {
        albumName = @"";
    }
    if (!artist) {
        artist = @"";
    }
    
    NSDictionary * musicInfo = @{@"Title":title,@"Artist":artist,@"Album":albumName,@"musicTime":musicTime,@"musicURL":musicURL};
    return musicInfo;
}

+(void)showAlertViewWithMsg:(NSString *)msg title:(NSString *)msgTitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * title = @"提示";
        if (msgTitle == nil) {
            title = msgTitle;
        }
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}

+(void)saveDidPlayItemInfo:(NSDictionary *)songInfo
{
    [[NSUserDefaults standardUserDefaults]setObject:songInfo forKey:CurrentPlayFileInfo];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSDictionary *)getThePreviousPlayItemInfo
{
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults]dictionaryForKey:CurrentPlayFileInfo];
    if (dic) {
        return dic;
    }
    return [NSDictionary dictionary];
}

+(UIImage *)newImageWithRect:(CGRect)rect
{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width,rect.size.height), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIColor * grandientColor1 = [UIColor colorWithRed:24.0/255 green:189.0/255.0 blue:30.0/255.0 alpha:0.8];
//    UIColor * grandientColor2 = [UIColor colorWithRed:24.0/255 green:189.0/255.0 blue:30.0/255.0 alpha:0.3];
//    UIColor * grandientColor3 = [UIColor colorWithRed:24.0/255 green:189.0/255.0 blue:30.0/255.0 alpha:0.1];
    UIColor * grandientColor1 = [UIColor colorWithRed:255/255 green:255/255.0 blue:255/255.0 alpha:0.8];
    UIColor * grandientColor2 = [UIColor colorWithRed:255/255 green:255/255.0 blue:255/255.0 alpha:0.3];
    UIColor * grandientColor3 = [UIColor colorWithRed:255/255 green:255/255.0 blue:255/255.0 alpha:0.0];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint centerPoint=CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGFloat radius=rect.size.width/2.0 > rect.size.height/2.0?rect.size.height/2.0:rect.size.width/2.0;
    CGPathAddArc(path, NULL, centerPoint.x, centerPoint.y, radius,0, M_PI*2, 0);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0,0.62,1.0 };
    NSArray *colors = @[(__bridge id) grandientColor1.CGColor, (__bridge id) grandientColor2.CGColor,(__bridge id) grandientColor3.CGColor ];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGContextDrawRadialGradient(context, gradient, centerPoint, 0, centerPoint, radius,kCGGradientDrawsAfterEndLocation );
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease (gradient);
    UIImage *imageOfContext=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsPopContext();
    return imageOfContext;

}

@end

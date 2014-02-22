//
//  GobalMethod.h
//  ClairAudient
//
//  Created by vedon on 16/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GobalMethod : NSObject
+(void)getExportPath:(NSString *)fileName completedBlock:(void (^)(BOOL isDownloaded,NSString * exportFilePath))block;

/*                 Public                  */

+(NSString *)getMakeTime;

+(NSString *)userCurrentTimeAsFileName;

+(NSString *)customiseTimeFormat:(NSString *)date;

+(BOOL)removeItemAtPath:(NSString *)path;

+(NSString *)getExportPath:(NSString *)fileName;

+(NSString *)getTempPath:(NSString *)fileName;



/*                 Audio                  */
+(CGFloat)getMusicLength:(NSURL *)url;
+(CGFloat)getAudioFileLength:(NSURL *)fileURL;
+(void)audio_PCMtoMP3WithSourceFile:(NSString *)sourceFile destinationFile:(NSString *)desFile withSampleRate:(NSInteger)sampleRate completedHandler:(void(^)(NSError *error))block;


/**
 @desc: 本地通知
 */
+(void)localNotificationBody:(NSString *)body;



@end


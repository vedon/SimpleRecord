//
//  GobalMethod.h
//  ClairAudient
//
//  Created by vedon on 16/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GobalMethod : NSObject
/**
 @desc The fileName you typed in is exist white isDownload is true,otherwise ,the file is't exist.
 */
+(void)getExportPath:(NSString *)fileName completedBlock:(void (^)(BOOL isDownloaded,NSString * exportFilePath))block;
/**
 @desc Get the current time as string returned
 *
 *
 */
+(NSString *)getMakeTime;
/**
 @desc Get the current time as string returned
 *
 *
 */
+(NSString *)userCurrentTimeAsFileName;

+(NSString *)customiseTimeFormat:(NSString *)date;
/**
 @desc Remove the item at Path
 *
 *
 */
+(BOOL)removeItemAtPath:(NSString *)path;

/**
 @desc Get the file path with the fileName ,The file prefix is the Documents/ .
 *
 *
 */
+(NSString *)getExportPath:(NSString *)fileName;
/**
 @desc Get the length of the music file in second
 *
 *
 */
+(CGFloat)getMusicLength:(NSURL *)url;
/**
 @desc Get the length of the music file in second
 *
 *
 */
+(CGFloat)getAudioFileLength:(NSURL *)fileURL;
/**
 @desc PCM convert to MP3
 *
 *
 */
+(void)audio_PCMtoMP3WithSourceFile:(NSString *)sourceFile destinationFile:(NSString *)desFile withSampleRate:(NSInteger)sampleRate completedHandler:(void(^)(NSError *error))block;
/**
 @desc Export the Ipod_library songs to local folder name.
 *
 *
 */
+(void)exportLibrarySongsToLocalFolder:(NSString *)folderName CompletedHandler:(void (^)(NSDictionary * info,NSError * error))handler;

/**
 @desc: Register a local notification
 *
 *
 */
+(void)localNotificationBody:(NSString *)body;

/**
 @desc: Show a Alerview With Message
 *
 *
 */
+(void)showAlertViewWithMsg:(NSString *)msg title:(NSString *)msgTitle;

/**
 @desc: Save the current play file info
 *
 *
 */
+(void)saveDidPlayItemInfo:(NSDictionary *)songInfo;


/**
 *@desc: Get the current play file info
 *
 *
 */
+(NSDictionary *)getThePreviousPlayItemInfo;

/**
 *@desc: create a image with Gradient
 *
 *
 */
+(UIImage *)newImageWithRect:(CGRect)rect;
@end


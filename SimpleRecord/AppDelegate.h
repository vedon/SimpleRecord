//
//  AppDelegate.h
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AudioReader;
@class AudioManager;
@class HTTPServer;
@class AudioFloatPointReader;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    HTTPServer *httpServer;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AudioReader  * reader;
@property (strong, nonatomic) AudioFloatPointReader * floatReader;
@property (strong, nonatomic) AudioManager * audioMng;

@property (strong, nonatomic) NSDictionary * currentPlayMusicInfo;
@property (assign, nonatomic) CGFloat        currentPlayMusicLength;
@property (assign, nonatomic) CGFloat        audioTotalFrame;

-(void)palyItemWithURL:(NSURL *)inputFileURL withMusicInfo:(NSDictionary *)info withPlaylist:(NSArray *)list;

-(void)seekToPostion:(CGFloat)postion;
-(void)playCurrentSongWithInfo:(NSDictionary *)info;
-(BOOL)isPlaying;
-(void)pause;
-(void)play;




@end

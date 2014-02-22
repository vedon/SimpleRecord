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
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AudioReader  * reader;
@property (strong, nonatomic) AudioManager * audioMng;
@property (assign, nonatomic) CGFloat        currentPlayMusicLength;
-(void)palyItemWithURL:(NSURL *)inputFileURL;
@end

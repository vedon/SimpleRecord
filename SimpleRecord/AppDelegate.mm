//
//  AppDelegate.m
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "AudioManager.h"
#import "AudioReader.h"
#import "GobalMethod.h"
@interface AppDelegate()<AudioReaderDelegate>
@end

@implementation AppDelegate
@synthesize reader;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"SimpleRecord.sqlite"];
    
    [self custonNavigationBar];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController * mainController = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:mainController];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)custonNavigationBar
{
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],NSFontAttributeName: [UIFont systemFontOfSize:21.0f]}];
    if([OSHelper iOS7])
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Record_Bar_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Record_Bar_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }

}

#pragma mark - Audio Stuff
-(void)palyItemWithURL:(NSURL *)inputFileURL withMusicInfo:(NSDictionary *)info
{
    self.currentPlayMusicLength = [GobalMethod getMusicLength:inputFileURL];
    self.currentPlayMusicInfo = info;
    
    [self.audioMng pause];
    [self.audioMng setForceOutputToSpeaker:YES];
    self.audioMng = [AudioManager shareAudioManager];
    
    
    reader = [AudioReader shareAudioReader];
    [reader setAudioFileURL:inputFileURL samplingRate:self.audioMng.samplingRate numChannels:self.audioMng.numOutputChannels];
    reader.currentTime = 0.0;
    reader.delegate = self;
    __weak AppDelegate * weakSelf =self;
    [self.audioMng setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.reader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
     }];
    
    [self.audioMng play];
}

-(void)play
{
    [self.audioMng play];
    [self.reader play];
    [self.audioMng setForceOutputToSpeaker:YES];
}

-(void)pause
{
    [self.audioMng pause];
    [self.reader pause];
}

-(BOOL)isPlaying
{
    if ([self.reader playing]) {
        return YES;
    }
    return NO;
}
-(void)currentFileLocation:(CGFloat)location
{
    __weak AppDelegate * weakSelf = self;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AudioProcessingLocation" object:[NSNumber numberWithFloat:location]];
    if (location >= _currentPlayMusicLength) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.reader.currentTime = 0.0;
        });
    }
}
@end

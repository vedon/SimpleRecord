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

#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"

#import "AudioFloatPointReader.h"
#import "NSTimer+Addition.h"
@interface AppDelegate()<AudioReaderDelegate>
@end

@implementation AppDelegate
@synthesize reader;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"SimpleRecord.sqlite"];
//    [self wifiTransferFileSetup];
    [self custonNavigationBar];
    
    
    
    
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController * mainController = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:mainController];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    
    _spinnerImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"spinner.png"]];
    [_spinnerImage setFrame:CGRectMake(270, 30, 25, 25)];
//    [_spinnerImage setHidden:YES];
    [self.window addSubview:_spinnerImage];
    _spinnerImageTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotateSpinnerview) userInfo:nil repeats:YES];
    [_spinnerImageTimer pauseTimer];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSDictionary * playItemInfo = [GobalMethod getThePreviousPlayItemInfo];
    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:playItemInfo];
    [temp setObject:[NSNumber numberWithFloat:_floatReader.currentPositionOfAudioFile] forKey:@"CurrentPosition"];
    [GobalMethod saveDidPlayItemInfo:temp];
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

#pragma mark - Private Method
-(void)wifiTransferFileSetup
{
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlerPortSuccess:) name:@"HTTPServer_get_port_success" object:nil];
    [nc addObserver:self selector:@selector(handlerPortFail:) name:@"HTTPServer_get_port_fail" object:nil];
    
    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    //	[httpServer setPort:12345];
	
	// Serve files from the standard Sites folder
	NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
	NSLog(@"Setting document root: %@", docRoot);
	
	[httpServer setDocumentRoot:docRoot];
	
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}

}

-(void)handlerPortSuccess:(NSNotification *)notification{
    NSDictionary* userInfo=notification.userInfo;
    NSNumber* port=[userInfo valueForKey:@"local_port"];
    NSLog(@"handlerPortSuccess----port:%d",port.unsignedShortValue);
}
-(void)handlerPortFail:(NSNotification *)notification{
    NSLog(@"handlerPortFail-----");
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


-(void)rotateSpinnerview
{
    _spinnerImage.layer.transform = CATransform3DRotate(_spinnerImage.layer.transform, 0.2, 0, 0, 1);
}


#pragma mark - Audio Stuff
-(void)palyItemWithURL:(NSURL *)inputFileURL withMusicInfo:(NSDictionary *)info withPlaylist:(NSArray *)list
{
    
    
    _floatReader = [AudioFloatPointReader shareAudioFloatPointReader];
    [_floatReader playAudioFile:inputFileURL];
    if ([list count]) {
        [_floatReader setPlaylist:list];
    }
    
    self.currentPlayMusicLength = _floatReader.audioDuration;
    self.audioTotalFrame   = _floatReader.totalFrame;
    self.currentPlayMusicInfo = info;
    self.audioMng = [AudioManager shareAudioManager];
    
    NSMutableDictionary * tempInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    [tempInfo setValue:inputFileURL.path forKey:@"FileURL"];
    [tempInfo setObject:[NSNumber numberWithFloat:0] forKey:@"CurrentPosition"];
    [tempInfo setObject:[NSNumber numberWithFloat:_floatReader.totalFrame] forKey:@"TotalFrame"];
    [GobalMethod saveDidPlayItemInfo:tempInfo];
    tempInfo = nil;
    
    [self play];
}

-(void)playCurrentSongWithInfo:(NSDictionary *)info
{
    _floatReader = [AudioFloatPointReader shareAudioFloatPointReader];
    [_floatReader playAudioFile:[NSURL fileURLWithPath:[info valueForKey:@"FileURL"]]];
    CGFloat recordPostion = [[info valueForKey:@"CurrentPosition"] floatValue];
    
    if (recordPostion >= _floatReader.currentPositionOfAudioFile) {
        [_floatReader seekToFilePostion:[[info valueForKey:@"CurrentPosition"] floatValue]];
    }else
    {
        [_floatReader seekToFilePostion:_floatReader.currentPositionOfAudioFile];
    }
    
    self.currentPlayMusicLength = _floatReader.audioDuration;
    self.audioTotalFrame        = _floatReader.totalFrame;
    self.audioMng = [AudioManager shareAudioManager];
    
    [self play];
}

-(void)play
{
    [_spinnerImageTimer resumeTimer];
    
    [_floatReader startReader];
    [self.audioMng setForceOutputToSpeaker:YES];
}

-(void)pause
{
    [_spinnerImageTimer pauseTimer];
    [_floatReader stopReader];
}

-(BOOL)isPlaying
{
    return _floatReader.playing;
}
-(void)seekToPostion:(CGFloat)postion
{
    [_floatReader seekToFilePostion:(SInt64)postion];
}
@end

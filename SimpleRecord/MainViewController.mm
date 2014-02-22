//
//  MainViewController.m
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "MainViewController.h"
#import "RecordViewController.h"
#import "LocalFileBroserViewController.h"
#import "AudioManager.h"
#import "AudioReader.h"
#import "AppDelegate.h"

@interface MainViewController ()<AudioReaderDelegate>
{
    AudioReader * audioReader;
    AppDelegate * myDelegate;
}
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.progressSlider.value = 0.0;
    //通知用来更新slider 位置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProcessingLocation:) name:@"AudioProcessingLocation" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.progressSlider.maximumValue = myDelegate.currentPlayMusicLength;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)updateProcessingLocation:(NSNotification *)noti
{
    CGFloat location = [noti.object floatValue];
    NSLog(@"%f",location);
}


#pragma mark - Outlet Method
- (IBAction)gotoRecordViewController:(id)sender {
    RecordViewController * viewController = [[RecordViewController alloc]initWithNibName:@"RecordViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}

- (IBAction)gotoLocalMusicViewController:(id)sender {
    LocalFileBroserViewController * viewController = [[LocalFileBroserViewController alloc]initWithNibName:@"LocalFileBroserViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}


#pragma mark -
-(void)currentFileLocation:(CGFloat)location
{
    NSLog(@"%f",location);
    
}
@end

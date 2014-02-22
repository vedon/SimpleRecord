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
#import "MyRecordViewController.h"
#import "AppDelegate.h"
#import "AudioReader.h"

@interface MainViewController ()
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
    
    [self.progressSlider addTarget:self action:@selector(updateCurrentPlayMusicPosition:) forControlEvents:UIControlEventValueChanged];
    
    UIImage *minImage = [[UIImage imageNamed:@"Home_Slide_Track_Fill.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage = [UIImage imageNamed:@"Home_Slide_Track.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"Home_Slide_Cap.png"];
    
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.progressSlider.maximumValue = myDelegate.currentPlayMusicLength;
    
    [self.controllBtn setSelected:[myDelegate isPlaying]];
    if (myDelegate.currentPlayMusicInfo) {
        self.musicTitle.text = [myDelegate.currentPlayMusicInfo valueForKey:@"Title"];
        self.progressingMusicLength.text = [myDelegate.currentPlayMusicInfo valueForKey:@"Length"];
    }
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
    __weak MainViewController * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.progressSlider.value = ceil(location);
    });
}


-(void)updateCurrentPlayMusicPosition:(id)sender
{
//    [myDelegate.audioMng pause];
    UISlider * slider = (UISlider*)sender;
    myDelegate.reader.currentTime = slider.value;
//    [myDelegate.audioMng play];
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

- (IBAction)gotoMyRecordViewController:(id)sender {
    
    MyRecordViewController * viewController = [[MyRecordViewController alloc]initWithNibName:@"MyRecordViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}

- (IBAction)controlBtnAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        [myDelegate play];
    }else
    {
        [myDelegate pause];
    }
}


@end

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
#import "GobalMethod.h"

@interface MainViewController ()
{
    AudioReader * audioReader;
    AppDelegate * myDelegate;
    
    BOOL isBeginTouchSlider;
    NSDictionary * previousPlayItemInfo;
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProcessingLocation:) name:CurrentPlayFilePostionInfo object:nil];
    
    [self.progressSlider addTarget:self action:@selector(updateCurrentPlayMusicPosition:) forControlEvents:UIControlEventTouchUpInside];
    self.progressSlider.continuous = NO;
    
    UIImage *minImage =     [[UIImage imageNamed:@"Home_Slide_Track_Fill.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage =     [UIImage imageNamed:@"Home_Slide_Track.png"];
    UIImage *thumbImage =   [UIImage imageNamed:@"Home_Slide_Cap.png"];
    
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    if ([OSHelper iPhone5]) {
        CGRect rect = _controlBtnContainerView.frame;
        rect.origin.y += 35;
        _controlBtnContainerView.frame = rect;
    }
    isBeginTouchSlider = NO;
    previousPlayItemInfo = nil;
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

-(void)viewWillAppear:(BOOL)animated
{
     [self.navigationController.navigationBar setHidden:YES];
    previousPlayItemInfo= [GobalMethod getThePreviousPlayItemInfo];
    if ([previousPlayItemInfo count]) {
        self.musicTitle.text = [previousPlayItemInfo valueForKey:@"Title"];
        self.progressingMusicLength.text = [previousPlayItemInfo valueForKey:@"Length"];
        _progressSlider.maximumValue = [[previousPlayItemInfo valueForKey:@"TotalFrame"] floatValue];
        _progressSlider.value       = [[previousPlayItemInfo valueForKey:@"CurrentPosition"] floatValue];
    }
    if ([myDelegate isPlaying]) {
        self.progressSlider.maximumValue = myDelegate.audioTotalFrame;
        [self.controllBtn setSelected:[myDelegate isPlaying]];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - Private Method
-(void)updateProcessingLocation:(NSNotification *)noti
{
    if (!_progressSlider.touchInside) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressSlider.value = [noti.object floatValue];
        });
        
    }
   
}
-(void)updateCurrentPlayMusicPosition:(id)sender
{
    UISlider * slider = (UISlider*)sender;
    [myDelegate seekToPostion:slider.value];

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
//        if ([myDelegate isPlaying]) {
//            [myDelegate play];
//            return;
//        }else
//        {
//            if ([previousPlayItemInfo count]) {
//                [myDelegate playCurrentSongWithInfo:previousPlayItemInfo];
//                self.progressSlider.maximumValue = myDelegate.audioTotalFrame;
//                return;
//            }
//            
//        }
        if ([previousPlayItemInfo count]) {
            [myDelegate playCurrentSongWithInfo:previousPlayItemInfo];
            self.progressSlider.maximumValue = myDelegate.audioTotalFrame;
            return;
        }
        [btn setSelected:NO];
    }else
    {
        [myDelegate pause];
    }
}


@end

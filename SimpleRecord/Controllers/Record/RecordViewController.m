//
//  RecordViewController.m
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioRecorder.h"
#import "RecordMusicInfo.h"
#import "MBProgressHUD.h"
#import "GobalMethod.h"
#import "AppDelegate.h"
#import "AudioManager.h"

@interface RecordViewController ()<UIAlertViewDelegate>
{
    AudioRecorder * recorder;
    NSTimer       * counter;
    
    NSInteger       hour;
    NSInteger       minute;
    NSInteger       second;
    NSURL    * recordFileURL;
    NSString * recordMakeTime;
    NSString * recordFilePath;
    NSString * defaultFileName;
    AppDelegate * myDelegate;
}
@property (weak, nonatomic) IBOutlet UILabel *clocker;
@end

@implementation RecordViewController

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
    
    recorder = [AudioRecorder shareAudioRecord];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private Method
-(void)timerStop
{
    if (counter !=nil) {
        [counter invalidate];
        counter = nil;
    }
}

-(void)timerStart
{
    if (counter == nil) {
        counter = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(increateTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:counter forMode:NSRunLoopCommonModes];
        [counter fire];
        
    }
}
-(NSString *)getDefaultFileName
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

-(NSString *)getMakeTime;
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

-(NSString *)getDocumentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(void)resetClocker
{
    hour = minute = second = 0;
    self.clocker.text = @"";
}

-(void)increateTime
{
    second ++;
    if ((second % 60) ==0) {
        minute ++;
        second = 0;
        if ((minute % 60) == 0) {
            hour ++;
            minute = 0;
        }
    }
    @autoreleasepool {
        NSString * hourStr = [NSString stringWithFormat:@"%ld",(long)hour];
        if ([hourStr length] == 1) {
            hourStr = [@"0" stringByAppendingString:hourStr];
        }
        
        NSString * minuteStr = [NSString stringWithFormat:@"%ld",(long)minute];
        if ([minuteStr length] == 1) {
            minuteStr = [@"0" stringByAppendingString:minuteStr];
        }
        
        NSString * secondStr = [NSString stringWithFormat:@"%ld",(long)second];
        if ([secondStr length] == 1) {
            secondStr = [@"0" stringByAppendingString:secondStr];
        }
        NSString * timeStr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minuteStr,secondStr];
        self.clocker.text = timeStr;
        
    }
}

#pragma mark - Outlet Action
- (IBAction)startRecordAction:(id)sender {
    
    [myDelegate pause];
    
    recordMakeTime  = [self getMakeTime];
    defaultFileName = [self getDefaultFileName];
    //录音的格式为caf 格式
    NSString * localRecordFileFullName = [defaultFileName stringByAppendingPathExtension:@"caf"];
    
    recordFilePath = [[self getDocumentDirectory] stringByAppendingPathComponent:localRecordFileFullName];
    recordFileURL = [NSURL fileURLWithPath:recordFilePath];
    NSLog(@"URL: %@", recordFileURL);
    if ([[NSFileManager defaultManager]fileExistsAtPath:recordFilePath isDirectory:NULL]) {
        [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    }
    
    
    [recorder initRecordWithPath:recordFilePath];
    [recorder startRecord];
    [self timerStart];
    [self resetClocker];

}

- (IBAction)pauseBtnAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        [self timerStop];
        [recorder pauseRecord];
    }else
    {
        [self timerStart];
        [recorder startRecord];
    }
}

- (IBAction)stopRecordAction:(id)sender {
    [recorder stopRecord];
    [self timerStop];
    self.clocker.text = @"00:00:00";
    
    
    //1）转换格式
    NSString * destinationFileName = [[self getDocumentDirectory] stringByAppendingPathComponent:[defaultFileName stringByAppendingPathExtension:@"mp3"]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [GobalMethod audio_PCMtoMP3WithSourceFile:recordFilePath destinationFile:destinationFileName withSampleRate:44100];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //2）保存录音文件信息
    RecordMusicInfo * recordFile = [RecordMusicInfo MR_createEntity];
    recordFile.title    = defaultFileName;
    recordFile.length   = [NSString stringWithFormat:@"%0.2f",[GobalMethod getMusicLength:recordFileURL]];
    recordFile.makeTime = recordMakeTime;
    recordFile.localPath= destinationFileName;
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
    
    //3）删除录音文件
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    alertView = nil;
}

- (IBAction)cancelRecordAction:(id)sender {
    [self timerStop];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除录音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView = nil;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //取消
            break;
        case 1:
            //确定
            [recorder stopRecord];
            [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
            break;
        default:
            break;
    }
}


@end

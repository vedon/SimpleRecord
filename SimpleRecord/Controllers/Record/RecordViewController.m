//
//  RecordViewController.m
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#define SaveRecordTag 1001
#define CancelRecordTag 1002

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioRecorder.h"
#import "RecordMusicInfo.h"
#import "MBProgressHUD.h"
#import "GobalMethod.h"
#import "AppDelegate.h"
#import "AudioManager.h"
#import "NSTimer+Addition.h"

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
    
    BOOL isRecording;
    NSString * formatType;
}
@property (weak, nonatomic) IBOutlet UILabel *clocker;
@end

@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"录音";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializationInterface];
        // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setHidden:NO];
    formatType = [[NSUserDefaults standardUserDefaults]valueForKey:@"musicFormat"];
    if (formatType == nil) {
        formatType = @"mp3";
    }
    if ([formatType isEqualToString:@"wav"]) {
        [self.wavBtn setSelected:YES];
    }else
    {
        [self.mp3Btn setSelected:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if ([counter isValid])  {
        [counter invalidate];
        counter = nil;
    }
    [self cleanRecordStuff];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private Method
-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Record_Btn_Back.png" action:@selector(backAction)];
    recorder = [AudioRecorder shareAudioRecord];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    isRecording = NO;
    
}
-(void)backAction
{
    if (isRecording) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否保存录音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = SaveRecordTag;
        [alertView show];
        alertView = nil;
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)timerStop
{
    [counter pauseTimer];
}

-(void)timerStart
{
    if (counter == nil) {
        counter = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(increateTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:counter forMode:NSRunLoopCommonModes];
        [counter fire];
        
    }else
    {
        [counter resumeTimer];
    }
}

-(void)cleanRecordStuff
{
    [recorder stopRecord];
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
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
    self.clocker.text = @"00:00:00";
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


-(void)stopRecord
{
    isRecording = NO;
    self.mp3Btn.userInteractionEnabled = !isRecording;
    self.wavBtn.userInteractionEnabled = !isRecording;
    
    [self.recordControlBtn setSelected:NO];
    [recorder stopRecord];
    [self timerStop];
    self.clocker.text = @"00:00:00";
    isRecording = NO;
    //1）转换格式
    NSString * destinationFileName = [[self getDocumentDirectory] stringByAppendingPathComponent:[defaultFileName stringByAppendingPathExtension:formatType]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [GobalMethod audio_PCMtoMP3WithSourceFile:recordFilePath destinationFile:destinationFileName withSampleRate:44100 completedHandler:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } ];
    
    
    //2）保存录音文件信息
    RecordMusicInfo * recordFile = [RecordMusicInfo MR_createEntity];
    recordFile.title    = defaultFileName;
    recordFile.length   = [NSString stringWithFormat:@"%0.2f",[GobalMethod getMusicLength:recordFileURL]];
    recordFile.makeTime = recordMakeTime;
    recordFile.localPath= destinationFileName;
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
    
    //3）删除录音文件
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    
    
    
}
#pragma mark - Outlet Action
- (IBAction)startRecordAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        
        if (!isRecording) {
            
            //stop the music that is playing
            [myDelegate pause];
            
            //Reset the recording mark
            isRecording = YES;
            self.mp3Btn.userInteractionEnabled = !isRecording;
            self.wavBtn.userInteractionEnabled = !isRecording;
            recordMakeTime  = [self getMakeTime];
            defaultFileName = [self getDefaultFileName];
            
            //The default record format is .caf
            NSString * localRecordFileFullName = [defaultFileName stringByAppendingPathExtension:@"caf"];
            
            recordFilePath = [[self getDocumentDirectory] stringByAppendingPathComponent:localRecordFileFullName];
            recordFileURL = [NSURL fileURLWithPath:recordFilePath];
        
            [recorder initRecordWithPath:recordFilePath];
            [recorder startRecord];
            
            [self resetClocker];
            [self timerStart];
            

        }else
        {
            [self timerStart];
            [recorder startRecord];
        }
    }else
    {
        [self timerStop];
        [recorder pauseRecord];
    }
    
}


- (IBAction)stopRecordAction:(id)sender {
    [self stopRecord];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    alertView = nil;
}



- (IBAction)cancelRecordAction:(id)sender {
    [self timerStop];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除录音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = CancelRecordTag;
    [alertView show];
    alertView = nil;
}

- (IBAction)wavFormatAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [self.mp3Btn setSelected:NO];
    formatType = @"wav";
    [[NSUserDefaults standardUserDefaults]setObject:formatType forKey:@"musicFormat"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (IBAction)mp3FormatAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [self.wavBtn setSelected:NO];
    
    formatType = @"mp3";
    [[NSUserDefaults standardUserDefaults]setObject:formatType forKey:@"musicFormat"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
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
            if (alertView.tag == CancelRecordTag) {
                [self cleanRecordStuff];
            }else
            {
                [self stopRecord];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            break;
        default:
            break;
    }
}


@end

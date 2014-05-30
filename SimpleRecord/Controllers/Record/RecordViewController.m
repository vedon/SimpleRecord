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
#import "PersistentStore.h"

#import "AsynEncodeAudioRecord.h"
#import "SoundMakerView.h"

@interface RecordViewController ()<UIAlertViewDelegate>
{
    AudioRecorder * recorder;
    AsynEncodeAudioRecord * asynEncodeRecorder;
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
    BOOL isUseInflexion;
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

    asynEncodeRecorder = [AsynEncodeAudioRecord shareAsynEncodeAudioRecord];
//    __weak RecordViewController * weakSelf = self;
//    [asynEncodeRecorder setDecibelBlock:^(CGFloat decibbel)
//    {
//        @autoreleasepool {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CGFloat absDecibel = abs(decibbel);
//                if (absDecibel == 0) {
//                    absDecibel = 1.0;
//                }else if (absDecibel > 6.0 )
//                {
//                    absDecibel = 5.0;
//                }
//                NSInteger size = 60 * absDecibel;
//                NSLog(@"size :%d",size);
//                UIImage * tempImage = [GobalMethod newImageWithRect:CGRectMake(0, 0, size, size)];
//                [weakSelf.gradientView setImage: tempImage];
//            });
//        }
//       
//    }];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    isRecording = NO;
    _finishBtn.userInteractionEnabled = NO;
    
    
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
    [self resetStatus];
    [self timerStop];
    [asynEncodeRecorder stopPlayer];
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
    [format setDateFormat:@"yyyyMMddhhmmss"];
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

-(void)resetStatus
{
    [self resetClocker];
    isRecording = NO;
    _finishBtn.userInteractionEnabled  = isRecording;
    self.mp3Btn.userInteractionEnabled = !isRecording;
    self.wavBtn.userInteractionEnabled = !isRecording;
    
    [self.recordControlBtn setSelected:NO];
    [asynEncodeRecorder stopPlayer];
    [self timerStop];
    
}

-(void)saveRecordFile
{
    //1）转换格式
    NSString * destinationFileName = [[self getDocumentDirectory] stringByAppendingPathComponent:[defaultFileName stringByAppendingPathExtension:formatType]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //2）保存录音文件信息
    RecordMusicInfo * recordFile = [RecordMusicInfo MR_createEntity];
    recordFile.title    = defaultFileName;
    recordFile.length   = [NSString stringWithFormat:@"%0.2f",[GobalMethod getMusicLength:recordFileURL]];
    recordFile.makeTime = recordMakeTime;
    recordFile.localPath= destinationFileName;
    
    
    //3）删除录音文件
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [self resetStatus];
    [asynEncodeRecorder saveSoundMakerFile];
    
    if (isUseInflexion) {
        SoundMakerView * makerView = [[[NSBundle mainBundle]loadNibNamed:@"SoundMakerView" owner:self options:nil]objectAtIndex:0];
        __weak AppDelegate * weakDelegate = myDelegate;
        makerView.audioFilePath = destinationFileName;
        CompletedProcessingBlock  tempBlocl = ^(NSString * filePath,BOOL isProcess,BOOL isSuccess)
        {
            if (isSuccess)
            {
                [weakDelegate palyItemWithURL:[NSURL URLWithString:filePath] withMusicInfo:@{@"Length":recordFile.length,@"Title":@"变音文件"} withPlaylist:nil];
                recordFile.localPath = filePath;
                [PersistentStore save];
            }
        };
        [makerView setProcessingBlock:tempBlocl];
        makerView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            makerView.alpha = 1.0;
            [self.view addSubview:makerView];
        }];
    }else
    {
        [PersistentStore save];
    }
    
    
}

-(void)saveSuccessfully
{
    [GobalMethod showAlertViewWithMsg
     :@"保存成功" title:nil];
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
            _finishBtn.userInteractionEnabled  = isRecording;
            self.mp3Btn.userInteractionEnabled = !isRecording;
            self.wavBtn.userInteractionEnabled = !isRecording;
            recordMakeTime  = [self getMakeTime];
            defaultFileName = [self getDefaultFileName];
            
            //The default record format is .caf
            NSString * localRecordFileFullName = [defaultFileName stringByAppendingPathExtension:@"caf"];
            
            recordFilePath = [[self getDocumentDirectory] stringByAppendingPathComponent:localRecordFileFullName];
            recordFileURL = [NSURL fileURLWithPath:recordFilePath];
        
            [asynEncodeRecorder initializationAudioRecrodWithFileExtension:formatType];
            [asynEncodeRecorder playFile:recordFilePath];
            [asynEncodeRecorder startPlayer];
            
            
            [self resetClocker];
            [self timerStart];
        }else
        {
            [self timerStart];
            [asynEncodeRecorder stopPlayer];
        }
    }else
    {
        [self timerStop];
        [asynEncodeRecorder stopPlayer];
    }
    
}


- (IBAction)stopRecordAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    if (isRecording) {
        [self saveRecordFile];
    }
}



- (IBAction)cancelRecordAction:(id)sender {

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


- (IBAction)inflexionAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    isUseInflexion = btn.selected;
    
    
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //取消
            if (alertView.tag == CancelRecordTag) {
                //do nothing
            }else
            {
                [self cleanRecordStuff];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case 1:
            //确定
            if (alertView.tag == CancelRecordTag) {
                [self cleanRecordStuff];
            }else
            {
                [self saveRecordFile];
//                [self.navigationController popViewControllerAnimated:YES];
            }
            
            break;
        default:
            break;
    }
}


@end

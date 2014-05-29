//
//  SoundMakerView.m
//  ClairAudient
//
//  Created by vedon on 25/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "SoundMakerView.h"
#import "SoundMaker.h"
#import "AppDelegate.h"
#import "GobalMethod.h"
#import "MBProgressHUD.h"

@interface SoundMakerView()
{
    NSInteger pitchValue;
    NSInteger rateValue;
    NSInteger tempoValue;
    
    NSString * desPath;
    BOOL isAlreadyProcess;
}
@end
@implementation SoundMakerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
 
        pitchValue = tempoValue = rateValue = 0;
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
  
    
    self.containerView.layer.cornerRadius = 15;
    isAlreadyProcess = NO;
    _rateLabel.text = @"0";
    _pitchLabel.text = @"0";
    _tempoLabel.text = @"0";
    pitchValue = tempoValue = rateValue = 0;
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSoundMakerView)];
//    [_soundMakerViewBg addGestureRecognizer:tap];
//    tap = Nil;
    
    

    if ([OSHelper iPhone5]) {
        CGRect rect  = _maskView.frame;
        rect.size.height+=88;
        _maskView.frame = rect;
    }
}


- (IBAction)listenBtnAciont:(id)sender {
    
    NSString * fileName = [_audioFilePath stringByDeletingPathExtension];
    desPath = [fileName stringByAppendingString:@"_temp.caf"];
    if (_audioFilePath&&!isAlreadyProcess) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self animated:YES];
            SoundMaker * maker = [[SoundMaker alloc]init];
            __weak __typeof(self) weakSelf = self;
            [maker initalizationSoundTouchWithSampleRate:44100 Channels:1 TempoChange:tempoValue PitchSemiTones:pitchValue RateChange:rateValue processingAudioFile:_audioFilePath destPath:desPath completedBlock:^(BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                  
                    isAlreadyProcess = YES;
                }else
                {
                    [self showAlertViewWithMessage:@"不支持格式"];
                }
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            }];
        });
        
    }
    
}

- (IBAction)sureBtnAction:(id)sender {
    
    
    [[NSFileManager defaultManager]removeItemAtPath:_audioFilePath error:nil];

   [self removeFromSuperview];
    
    if (_processingBlock) {
        _processingBlock(desPath,YES,nil);
    }
}



- (IBAction)rateSliderAction:(id)sender {
    
    UISlider * slider = sender;
    rateValue = slider.value;
    _rateLabel.text = [NSString stringWithFormat:@"%d",rateValue];
}
- (IBAction)pitchSliderAction:(id)sender {
    UISlider * slider = sender;
    pitchValue = slider.value;
    _pitchLabel.text = [NSString stringWithFormat:@"%d",pitchValue];
}

- (IBAction)tempoSliderAction:(id)sender {
    UISlider * slider = sender;
    tempoValue = slider.value;
    _tempoLabel.text = [NSString stringWithFormat:@"%d",tempoValue];
}

- (IBAction)cancelAction:(id)sender {
    [self removeSoundMakerView];
}

-(void)removeSoundMakerView
{
    [self removeFromSuperview];
    if (_processingBlock) {
        _processingBlock(nil,NO,nil);
    }
}

-(void)playItemWithPath:(NSString *)localFilePath length:(NSString *)length
{
//    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    NSURL *inputFileURL = [NSURL fileURLWithPath:localFilePath];
//    if([inputFileURL.absoluteString isEqualToString:[myDelegate currentPlayFilePath]])
//    {
//        //同一文件
//        [myDelegate play];
//    }else
//    {
//        [myDelegate playItemWithURL:inputFileURL withMusicInfo:nil withPlaylist:nil];
//
//    }
    
}
- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}
@end

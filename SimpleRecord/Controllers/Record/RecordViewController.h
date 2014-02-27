//
//  RecordViewController.h
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
@interface RecordViewController : CommonViewController

- (IBAction)startRecordAction:(id)sender;
- (IBAction)stopRecordAction:(id)sender;
- (IBAction)cancelRecordAction:(id)sender;
- (IBAction)wavFormatAction:(id)sender;
- (IBAction)mp3FormatAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *mp3Btn;
@property (weak, nonatomic) IBOutlet UIButton *wavBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;


@end

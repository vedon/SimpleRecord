//
//  MainViewController.h
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

- (IBAction)gotoRecordViewController:(id)sender;
- (IBAction)gotoLocalMusicViewController:(id)sender;
- (IBAction)gotoMyRecordViewController:(id)sender;

- (IBAction)controlBtnAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *controllBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *progressingMusicLength;

@end

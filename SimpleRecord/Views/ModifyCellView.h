//
//  ModifyCellView.h
//  SimpleRecord
//
//  Created by vedon on 22/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ModifyCellViewBlock) (BOOL isModify,NSString * modifiedName);
@interface ModifyCellView : UIView

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelModifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmModifyBtn;
- (IBAction)cancelAction:(id)sender;
- (IBAction)confirmAction:(id)sender;


@property (strong ,nonatomic) ModifyCellViewBlock block;
@end

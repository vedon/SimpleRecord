//
//  ModifyCellView.m
//  SimpleRecord
//
//  Created by vedon on 22/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "ModifyCellView.h"

@implementation ModifyCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)cancelAction:(id)sender {
    if (self.block) {
        self.block(NO,self.contentTextField.text);
        self.block = nil;
    }
    [self.contentTextField resignFirstResponder];
    [self removeFromSuperview];
}

- (IBAction)confirmAction:(id)sender {
    if (self.block) {
        self.block(YES,self.contentTextField.text);
        self.block = nil;
    }
    [self.contentTextField resignFirstResponder];
    [self removeFromSuperview];
}
@end

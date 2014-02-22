//
//  MusicInfoCell.m
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "RecordItemInfo.h"

@implementation RecordItemInfo

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)resetContentAlpha:(CGFloat)alpha
{
    self.musicTitle.alpha = alpha;
    self.shareBtn.alpha = alpha;
    self.uploadBtn.alpha = alpha;
}

@end

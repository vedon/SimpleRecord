//
//  LocalFileBroserViewController.h
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
@interface LocalFileBroserViewController :CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@end

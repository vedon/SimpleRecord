//
//  MyRecordViewController.m
//  SimpleRecord
//
//  Created by vedon on 22/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "MyRecordViewController.h"
#import "RecordItemInfo.h"
#import "RecordMusicInfo.h"
#import "PersistentStore.h"
#import "AppDelegate.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyRecordViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * dataSource;
    NSArray * cells;
}
@end

@implementation MyRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的录音";
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
    [self.navigationController.navigationBar setHidden:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private method
-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Record_Btn_Back.png" action:nil];
    dataSource = [PersistentStore getAllObjectWithType:[RecordMusicInfo class]];
    
    
    UINib * cellNib = [UINib nibWithNibName:@"RecordItemInfo" bundle:[NSBundle bundleForClass:[RecordItemInfo class]]];
    [self.contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    if ([OSHelper iOS7]) {
        self.contentTable.separatorInset = UIEdgeInsetsZero;
    }
    self.contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentTable setBackgroundView:nil];
    [self.contentTable setBackgroundColor:[UIColor clearColor]];
}

-(void)playItemWithPath:(NSString *)localFilePath musicInfo:(NSDictionary *)dic
{
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [myDelegate palyItemWithURL:[NSURL fileURLWithPath:localFilePath]withMusicInfo:dic];
}

-(void)resetTheCellAlphaWhenScrolling
{
    @autoreleasepool {
        CGFloat count = (CGFloat)[cells count];
        
        for (int i =0 ;i < [cells count];i++) {
            RecordItemInfo * cell = [cells objectAtIndex:i];
            [cell resetContentAlpha:((count -i)/count)];
        }
    }
    
}

#pragma mark - UITableView Stuff
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordItemInfo * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    RecordMusicInfo * info = [dataSource objectAtIndex:indexPath.row];
    cell.musicTitle.text = info.title;
    
    CGFloat totalItems = (CGFloat)[dataSource count];
    CGFloat alpha = 1.0 / totalItems * (totalItems - indexPath.row);
    [cell resetContentAlpha:alpha];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordMusicInfo * info = [dataSource objectAtIndex:indexPath.row];
    [self playItemWithPath:info.localPath musicInfo:@{@"Title": info.title,@"Length":info.length}];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cells = [tableView visibleCells];
    [self resetTheCellAlphaWhenScrolling];
}
@end

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
@interface MyRecordViewController ()
{
    NSArray * dataSource;
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
-(void)playItemWithPath:(NSString *)localFilePath musicInfo:(NSDictionary *)dic
{
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [myDelegate palyItemWithURL:[NSURL fileURLWithPath:localFilePath]withMusicInfo:dic];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordMusicInfo * info = [dataSource objectAtIndex:indexPath.row];
    [self playItemWithPath:info.localPath musicInfo:@{@"Title": info.title,@"Length":info.length}];
}
@end

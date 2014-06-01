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
#import "ModifyCellView.h"


static NSString * cellIdentifier = @"cellIdentifier";
@interface MyRecordViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * dataSource;
    NSArray * cells;
    
    NSArray * playList;
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
    dataSource = [NSMutableArray array];
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
    [self updateDataSource];
    
    
    UINib * cellNib = [UINib nibWithNibName:@"RecordItemInfo" bundle:[NSBundle bundleForClass:[RecordItemInfo class]]];
    [self.contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
#ifdef iOS7_SDK
    if ([OSHelper iOS7]) {
        self.contentTable.separatorInset = UIEdgeInsetsZero;
    }
#else
    CGRect rect = _tableContainerView.frame;
    rect.origin.y +=20;
    _tableContainerView.frame = rect;

#endif
    self.contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentTable setBackgroundView:nil];
    [self.contentTable setBackgroundColor:[UIColor colorWithRed:15/255.0 green:18/255.0 blue:25/255.0 alpha:1.0]];
    
}

-(void)resetTheCellAlphaWhenScrolling
{
    @autoreleasepool {
        CGFloat count = (CGFloat)[cells count];
        
        for (int i =0 ;i < [cells count];i++) {
            RecordItemInfo * cell = [cells objectAtIndex:i];
            [cell resetContentAlpha:((count -i)/count)+0.2];
        }
    }
    
}

-(void)updateDataSource
{
    [dataSource removeAllObjects];
     [dataSource  addObjectsFromArray:[PersistentStore getAllObjectWithType:[RecordMusicInfo class]]];
    if ([dataSource count]) {
        NSArray * tempSordedArray = [dataSource sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            RecordMusicInfo * object1 = (RecordMusicInfo *)obj1;
            RecordMusicInfo * object2 = (RecordMusicInfo *)obj2;
            
            if (object1.makeTime.integerValue > object2.makeTime.integerValue) {
                return NSOrderedAscending;
            }else
            {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
            
        }];
        [dataSource removeAllObjects];
        [dataSource addObjectsFromArray:tempSordedArray];
         tempSordedArray = nil;
        //Get the playLists
        NSMutableArray * tempPlaylist = [NSMutableArray array];
        for (RecordMusicInfo * object in dataSource) {
            [tempPlaylist addObject:[NSURL fileURLWithPath:object.localPath]];
        }
        playList = tempPlaylist;
        [self.contentTable reloadData];
    }

    
}

-(void)addLongPressGestureToCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIView * gestureView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,50)];
    UILongPressGestureRecognizer * longPressGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(modifyItemName:)];
    longPressGes.allowableMovement = 200.0f;
    longPressGes.minimumPressDuration = 1.0;
    [gestureView addGestureRecognizer:longPressGes];
    [gestureView setBackgroundColor:[UIColor clearColor]];
    gestureView.tag = index;
    [cell.contentView addSubview:gestureView];
    gestureView = nil;
    longPressGes = nil;
}

-(void)modifyItemName:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        __weak MyRecordViewController * weakSelf = self;
        UIView * tempView = gesture.view;
        RecordMusicInfo * object = [dataSource objectAtIndex:tempView.tag];
        ModifyCellView * cellView = [[[NSBundle mainBundle]loadNibNamed:@"ModifyCellView" owner:self options:nil]objectAtIndex:0];
        cellView.contentTextField.text = object.title;
        [cellView.contentTextField becomeFirstResponder];
        [cellView setBlock:^(BOOL isModify,NSString *modifiedName)
         {
             if (isModify) {
                 NSLog(@"%@",modifiedName);
                 [PersistentStore updateObject:object Key:@"title" Value:modifiedName];
                 [weakSelf updateDataSource];
             }
         }];
        cellView.alpha = 0.3;
        [UIView animateWithDuration:0.3 animations:^{
            cellView.alpha = 1.0;
            [self.view addSubview:cellView];
            
        }];
        cellView = nil;

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
    [self addLongPressGestureToCell:cell withIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordMusicInfo * info = [dataSource objectAtIndex:indexPath.row];
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        UIImageView * musicIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"musicIcon.png"]];
        
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [tableView convertRect:cellRect toView:[tableView superview]];
        [musicIcon setFrame:CGRectMake(10, rectInSuperview.origin.y+rectInSuperview.size.height, 20, 20)];
        [myDelegate.window addSubview:musicIcon];
        [UIView animateWithDuration:1.5 animations:^{
            
            CATransform3D transform = CATransform3DTranslate(musicIcon.layer.transform,250, -rectInSuperview.origin.y, 0);
            transform = CATransform3DRotate(transform, M_PI/2, 0,0, 1.0f);
            musicIcon.layer.transform = transform;
            
        } completion:^(BOOL finished) {
            [musicIcon removeFromSuperview];
        }];
    });

    
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        [myDelegate palyItemWithURL:[NSURL fileURLWithPath:info.localPath]withMusicInfo:@{@"Title": info.title,@"Length":info.length} withPlaylist:nil];
    });
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cells = [tableView visibleCells];
    [self resetTheCellAlphaWhenScrolling];
//    [(RecordItemInfo *)cell resetContentAlpha:((dataSource.count -indexPath.row)/dataSource.count)];

    CGFloat animationTimeOffset = indexPath.row * 0.18;
    if (animationTimeOffset > 1.2) {
        animationTimeOffset = 1.2;
    }
//    RecordItemInfo * tempCell = (RecordItemInfo *)cell;
//    tempCell.bgImageView.layer.borderWidth = 0.1;
//     tempCell.bgImageView.layer.borderColor =[UIColor whiteColor].CGColor;
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( M_PI/6, 1, 0.0, 0.0);
    rotation.m34 = 1.0/ -600;
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.layer.transform = rotation;

    [UIView animateWithDuration:animationTimeOffset/5 animations:^{
        cell.layer.transform = CATransform3DIdentity;
        cell.layer.shadowOffset = CGSizeMake(0, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationTimeOffset/3 animations:^{
            
            CATransform3D rotation;
            rotation = CATransform3DMakeRotation( M_PI/4, 1, 0.0, 0.0);
            rotation.m34 = 1.0/ -600;
            cell.layer.shadowColor = [[UIColor blackColor]CGColor];
            cell.layer.shadowOffset = CGSizeMake(10, 10);
            cell.layer.transform = rotation;
            
        } completion:^(BOOL finished) {
            [UIView beginAnimations:@"rotation" context:NULL];
            [UIView setAnimationDuration:animationTimeOffset/6];
            cell.layer.transform = CATransform3DIdentity;
            cell.alpha = 1;
            cell.layer.shadowOffset = CGSizeMake(0, 0);
            cell.layer.repeatCount = 3;
            [UIView commitAnimations];
//            tempCell.bgImageView.layer.borderWidth = 0.0;
        }];
    }];
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL someCondition = YES;
    return (someCondition) ?
    UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete the local Record of the music item
        RecordMusicInfo * object = [dataSource objectAtIndex:indexPath.row];
        [PersistentStore deleteObje:object];
        
        //Delete Data source
        [dataSource removeObjectAtIndex:indexPath.row];
        
        //Of course,delete the item in the table
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
@end

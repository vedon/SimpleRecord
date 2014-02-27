//
//  LocalFileBroserViewController.m
//  SimpleRecord
//
//  Created by vedon on 21/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "LocalFileBroserViewController.h"
#import "TSLibraryImport.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"
#import "MusicInfoCell.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/NSObjCRuntime.h>
#import "AudioReader.h"
#import "AudioManager.h"
#import "AppDelegate.h"
#import "MusicInfo.h"
#import "PersistentStore.h"
#import "GobalMethod.h"

//#import "PersistentStore.h"
static NSString * cellIdentifier = @"Identifier";
@interface LocalFileBroserViewController ()<UITableViewDataSource,UITableViewDelegate,AudioReaderDelegate>
{
    TSLibraryImport* importTool;
    NSMutableArray * dataSource;
    //当前选择文件的本地路径
    NSString * currentLocationPath;
    
    NSArray * playlist;
}
@property (strong ,nonatomic) NSOperationQueue *autoCompleteQueue;
@end

@implementation LocalFileBroserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"本地音乐";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}


#pragma mark - Private Method

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Record_Btn_Back.png" action:nil];
    dataSource = [NSMutableArray array];
    importTool = [[TSLibraryImport alloc] init];
    
    playlist = nil;
    [self findArtistList];
    if ([dataSource count] == 0) {
        //没有歌曲
        [self showAlertViewWithMessage:@"本地没有音乐文件"];
    }else
    {
        //TODO:playlist configuration
    }
    
    UINib * cellNib = [UINib nibWithNibName:@"MusicInfoCell" bundle:[NSBundle bundleForClass:[MusicInfoCell class]]];
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
    [self.contentTable setBackgroundColor:[UIColor clearColor]];
    [self.contentTable setBackgroundView:nil];
}

-(void)configureLibraryMusicWithSelector:(SEL)action withInfo:(NSDictionary *)info
{
    if ([self isValidMusicName:[info valueForKey:@"Title"]])
    {
            NSURL* assetURL         = (NSURL *)[info valueForKey:@"musicURL"];
            NSString * musicTitle   = info[@"Title"];
            [self getLocationFilePath:assetURL title:musicTitle];
            
            
            //判断是否已经在本地有音乐库的文件
            NSArray * array =[PersistentStore getAllObjectWithType:[MusicInfo class]];
            if ([array count]) {
                for (MusicInfo * object in array) {
                    if ([object.title isEqualToString:musicTitle]) {
                        objc_msgSend(self, action,object.localFilePath,@{@"Title": object.title,@"Length":object.length});
                        return;
                    }
                }
            }
            //在数据库中没有找到已经读取的文件，执行一下操作：从ipd library 中复制音乐文件到用户document 目录下
            //1) 保存数据到数据库
            MusicInfo * tempMusicInfo    = [MusicInfo MR_createEntity];
            tempMusicInfo.title          =  musicTitle;
            tempMusicInfo.artist         = [info valueForKey:@"Artist"];
            tempMusicInfo.localFilePath  = currentLocationPath;
            tempMusicInfo.length         = [info valueForKey:@"musicTime"];
            [PersistentStore save];
        
            //复制文件到本地
            [self exportAssetAtURL:assetURL withTitle:tempMusicInfo.title completedHandler:^(NSString *path) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (action) {
                        objc_msgSend(self, action,path,@{@"Title":tempMusicInfo.title,@"Length":tempMusicInfo.length});
                    }
                });
                
            }];
    }else
    {
        [self showAlertViewWithMessage:@"音乐文件名有误"];
    }
}

-(BOOL)isValidMusicName:(NSString *)musicName
{
    //有可能会遇到像   泡沫/杨子琪.mp3 这样的文件。需要首先判断是否是合法的名称
    if ([musicName rangeOfString:@"/"].location != NSNotFound) {
        return NO;
    }
    return YES;
}

-(void)findArtistList
{
    MPMediaQuery *listQuery = [MPMediaQuery playlistsQuery];
    NSNumber *musicType = [NSNumber numberWithInteger:MPMediaTypeMusic];
    
    MPMediaPropertyPredicate *musicPredicate = [MPMediaPropertyPredicate predicateWithValue:musicType forProperty:MPMediaItemPropertyMediaType];
    [listQuery addFilterPredicate: musicPredicate];
    //播放列表
    NSArray *playlist = [listQuery items];
    for (MPMediaItem * item in playlist) {
        NSDictionary * dic = [self getMPMediaItemInfo:item];
        [dataSource addObject:dic];
    }
}

- (NSDictionary *)getMPMediaItemInfo:(MPMediaItem *)item{
    NSString *title     = [item valueForProperty:MPMediaItemPropertyTitle];;
    NSString *artist    = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumName = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *strTime   = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    NSURL *musicURL     = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"%@",musicURL.absoluteString);
    //计算音乐文件所需要的时间
    
    int seconds = (int)[strTime integerValue];
    int minute = 0;
    if (seconds >= 60) {
        int index = seconds / 60;
        minute = index;
        seconds = seconds - index * 60;
    }
    NSString *musicTime = [NSString stringWithFormat:@"%02d:%02d", minute, seconds];
    //这里依次是 音乐名，艺术家，专辑名，音乐时间，音乐播放路径
    if (!albumName) {
        albumName = @"";
    }
    if (!artist) {
        artist = @"";
    }
    
    NSDictionary * musicInfo = @{@"Title":title,@"Artist":artist,@"Album":albumName,@"musicTime":musicTime,@"musicURL":musicURL};
    return musicInfo;
}


-(void)getLocationFilePath:(NSURL*)assetURL title:(NSString *)title
{
    NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:title];
    currentLocationPath = [filePath stringByAppendingPathExtension:ext];
    
}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title completedHandler:(void (^)(NSString * path))completedBlock
{
	NSURL* outURL = [NSURL fileURLWithPath:currentLocationPath];
    //已经存在就删除
    [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];

    if (![[NSFileManager defaultManager] fileExistsAtPath:currentLocationPath]) {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        __weak LocalFileBroserViewController * weakSelf = self;
        [importTool importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            });
            if (import.status != AVAssetExportSessionStatusCompleted) {
                // something went wrong with the import
                NSLog(@"Error importing: %@", import.error);
                import = nil;
                return;
            }
            completedBlock (currentLocationPath);
        }];
        
    }else
    {
        //音频文件已经存在
        completedBlock (currentLocationPath);
    }
}

-(void)playItemWithPath:(NSString *)localFilePath musicInfo:(NSDictionary *)dic
{
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [myDelegate palyItemWithURL:[NSURL fileURLWithPath:localFilePath]withMusicInfo:dic withPlaylist:nil];
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
    MusicInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary * musicInfo = [dataSource objectAtIndex:indexPath.row];
    
    cell.musicTitle.text = [musicInfo valueForKey:@"Title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * musicInfo = [dataSource objectAtIndex:indexPath.row];
    [self configureLibraryMusicWithSelector:@selector(playItemWithPath:musicInfo:) withInfo:musicInfo];
}

@end

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
#import "PersistentStore.h"

@interface LocalFileBroserViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    TSLibraryImport* importTool;
    NSMutableArray * dataSource;
}
@end

@implementation LocalFileBroserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataSource = [NSMutableArray array];
    importTool = [[TSLibraryImport alloc] init];
    
    [self findArtistList];
    if ([dataSource count] == 0) {
        //没有歌曲
        [self showAlertViewWithMessage:@"本地没有音乐文件"];
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureLibraryMusicWithSelector:(SEL)action withInfo:(NSDictionary *)info
{
    if ([self isValidMusicName:[info valueForKey:@"Title"]])
    {
            NSURL* assetURL         = (NSURL *)[info valueForKey:@"musicURL"];
            NSString * musicTitle   = info[@"Title"];
            [self getLocationFilePath:assetURL title:musicTitle];
            
            
//            //判断是否已经在本地有音乐库的文件
//            NSArray * array =[PersistentStore getAllObjectWithType:[MusicInfo class]];
//            if ([array count]) {
//                for (MusicInfo * object in array) {
//                    if ([object.title isEqualToString:musicTitle]) {
//                        objc_msgSend(self, action,object.localFilePath);
//                        return;
//                    }
//                }
//            }
//            //在数据库中没有找到已经读取的文件，执行一下操作：从ipd library 中复制音乐文件到用户document 目录下
//            //1) 保存数据到数据库
//            MusicInfo * tempMusicInfo    = [MusicInfo MR_createEntity];
//            tempMusicInfo.title          =  musicTitle;
//            tempMusicInfo.artist         = [info valueForKey:@"Artist"];
//            tempMusicInfo.localFilePath  = currentLocationPath;
//            [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
        
            //复制文件到本地
            [self exportAssetAtURL:assetURL withTitle:info[@"Title"] completedHandler:^(NSString *path) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (action) {
                        objc_msgSend(self, action,path);
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
        __weak LocalMusicViewController * weakSelf = self;
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


@end
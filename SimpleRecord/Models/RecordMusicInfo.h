//
//  RecordMusicInfo.h
//  SimpleRecord
//
//  Created by vedon on 22/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecordMusicInfo : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * makeTime;
@property (nonatomic, retain) NSString * title;

@end

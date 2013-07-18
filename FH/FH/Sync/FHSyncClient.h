//
//  FHSyncClient.h
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncClient.h"
#import "JSONKit.h"
#import "FHSyncConfig.h"




@interface FHSyncClient : NSObject


+ (FHSyncClient*) getInstance;
- (id) initWithConfig:(FHSyncConfig*) config;
- (void) manageWithDataId:(NSString* ) dataId AndConfig:(FHSyncConfig*) config AndQuery:(NSDictionary* ) queryParams;
- (NSDictionary *) readWithDataId:(NSString*) dataId AndUID:(NSString*) uid;
- (NSDictionary *) listWithDataId:(NSString*) dataId;
- (BOOL) createWithDataId:(NSString*) dataId AndData:(NSDictionary *) data;
- (BOOL) updateWithDataId:(NSString*) dataId AndUID:(NSString*) uid AndData:(NSDictionary *) data;
- (BOOL) deleteWithDataId:(NSString*) dataId AndUID:(NSString*) uid;
- (void) stopWithDataId:(NSString*) dataId;
- (void) destroy;

@end

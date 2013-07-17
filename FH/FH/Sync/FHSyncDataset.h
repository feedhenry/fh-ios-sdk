//
//  FHSyncDataset.h
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncConfig.h"
/**
 A class representing a sync dataset managed by the sync service
 **/
@interface FHSyncDataset : NSObject
{
  BOOL _syncRunning;
  BOOL _initialised;
  NSString* _datasetId;
  NSDate* _syncLoopStart;
  NSDate* _syncLoopEnd;
  BOOL _syncLoopPending;
  FHSyncConfig* _syncConfig;
  NSMutableDictionary* _pendingDataRecords;
  NSMutableDictionary* _dataRecords;
  NSDictionary* _queryParams;
  NSMutableDictionary* _metaData;
  NSString* _hashValue;
}

/** Indicate if the sync process is currently running **/
@property BOOL syncRunning;
/** Indicate if the dataset is initialised **/
@property BOOL initialised;
/** A unique id of the dataset **/
@property NSString* datasetId;
/** When last sync started **/
@property (copy) NSDate* syncLoopStart;
/** Wehn last sync finished **/
@property (copy) NSDate* syncLoopEnd;
/** Indicate if sync should be run in next run loop **/
@property BOOL syncLoopPending;
/** The sync config for this dataset **/
@property (copy) FHSyncConfig* syncConfig;
/** A collection of pending data records **/
@property NSMutableDictionary* pendingDataRecords;
/** A collection of synced data records **/
@property NSMutableDictionary* dataRecords;
/** The query params for this dataset **/
@property NSDictionary* queryParams;
/** Meta data associated with this data set**/
@property NSMutableDictionary* metaData;
/** The SHA1 hash value of this data set **/
@property NSString* hashValue;

- (id) initWithDataId:(NSString* )dataId;
-(id) initFromFileWithDataId:(NSString*) dataId error:(NSError*) error;

- (NSDictionary*) JSONData;
- (NSString*) JSONString;
+ (FHSyncDataset*) objectFromJSONString:(NSString*) jsonStr;
+ (FHSyncDataset*) objectFromJSONData:(NSDictionary*) jsonData;
- (void) saveToFile:(NSError*) error;

@end

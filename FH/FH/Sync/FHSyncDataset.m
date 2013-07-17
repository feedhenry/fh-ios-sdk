//
//  FHSyncDataset.m
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHSyncDataset.h"
#import "FHSyncUtils.h"
#import "JSONKit.h"
#import "FHSyncPendingDataRecord.h"
#import "FHSyncDataRecord.h"

#define STORAGE_FILE_PATH @".sync.json"

#define KEY_DATASETID @"dataSetId"
#define KEY_SYNCLOOP_START @"syncLoopStart"
#define KEY_SYNCLOOP_END @"syncLoopEnd"
#define KEY_SYNCCONFIG @"syncConfig"
#define KEY_PENDING_RECORDS @"pendingDataRecords"
#define KEY_DATA_RECORDS @"dataRecords"
#define KEY_HASHVALUE @"hashValue"

@implementation FHSyncDataset

@synthesize  syncRunning = _syncRunning;
@synthesize  initialised = _initialised;
@synthesize  datasetId = _datasetId;
@synthesize  syncLoopStart = _syncLoopStart;
@synthesize  syncLoopEnd = _syncLoopEnd;
@synthesize  syncLoopPending = _syncLoopPending;
@synthesize  syncConfig = _syncConfig;
@synthesize  pendingDataRecords = _pendingDataRecords;
@synthesize  dataRecords = _dataRecords;
@synthesize  queryParams = _queryParams;
@synthesize  metaData = _metaData;
@synthesize  hashValue = _hashValue;

- (id) initWithDataId:(NSString* )dataId
{
  self = [super init];
  if(self){
    self.syncRunning = NO;
    self.datasetId = dataId;
    self.syncLoopStart = nil;
    self.syncLoopEnd = nil;
    self.syncLoopPending = YES;
    self.syncConfig = nil;
    self.pendingDataRecords = [NSMutableDictionary dictionary];
    self.dataRecords = [NSMutableDictionary dictionary];
    self.queryParams = nil;
    self.metaData = [NSMutableDictionary dictionary];
    self.hashValue = nil;
    self.initialised = NO;
  }
  return self;
}

-(id) initFromFileWithDataId:(NSString*) dataId error:(NSError*) error
{
  NSString* data = [FHSyncUtils loadDataFromFile:[dataId stringByAppendingPathExtension:STORAGE_FILE_PATH] error:error];
  if(nil != data){
    return [FHSyncDataset objectFromJSONString:data];
  } else {
    return nil;
  }
}

- (NSDictionary*) JSONData
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
  [dict setObject:self.datasetId forKey:KEY_DATASETID];
  [dict setObject:[self.syncConfig JSONData] forKey:KEY_SYNCCONFIG];
  NSMutableDictionary* pendingDataDict = [NSMutableDictionary dictionary];
  [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    [pendingDataDict setObject:[obj JSONData] forKey:key];
  }];
  [dict setObject:pendingDataDict forKey:KEY_PENDING_RECORDS];
  NSMutableDictionary* dataDict = [NSMutableDictionary dictionary];
  [self.dataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    [dataDict setObject:[obj JSONData] forKey:key];
  }];
  [dict setObject:dataDict forKey:KEY_DATA_RECORDS];
  
  if(nil != self.syncLoopStart){
    [dict setObject:[NSNumber numberWithDouble:[self.syncLoopStart timeIntervalSince1970]] forKey:KEY_SYNCLOOP_START];
  }
  if(nil != self.syncLoopEnd){
    [dict setObject:[NSNumber numberWithDouble:[self.syncLoopEnd timeIntervalSince1970]] forKey:KEY_SYNCLOOP_END];
  }
  return dict;
}

/** Serialize this object to JSON string **/
- (NSString*) JSONString
{
  NSDictionary* dict = [self JSONData];
  return [dict JSONString];
}

- (void) saveToFile: (NSError*) error
{
  NSString* jsonStr = [self JSONString];
  NSLog(@"content = %@", jsonStr);
  [FHSyncUtils saveData:jsonStr toFile:[self.datasetId stringByAppendingPathExtension:STORAGE_FILE_PATH] error:error];
}

+ (FHSyncDataset*) objectFromJSONData:(NSDictionary*) jsonObj
{
  FHSyncDataset* instance = [[FHSyncDataset alloc] init];
  instance.datasetId = [jsonObj objectForKey:KEY_DATASETID];
  instance.syncConfig = [FHSyncConfig objectFromJSONData:[jsonObj objectForKey:KEY_SYNCCONFIG]];
  instance.hashValue = [jsonObj objectForKey:KEY_HASHVALUE];
  instance.pendingDataRecords = [NSMutableDictionary dictionary];
  NSDictionary* pendingJson = [jsonObj objectForKey:KEY_PENDING_RECORDS];
  if(nil != pendingJson){
    [pendingJson  enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      [instance.pendingDataRecords setObject:[FHSyncPendingDataRecord objectFromJSONData:obj] forKey:key];
    }];
  }
  instance.dataRecords = [NSMutableDictionary dictionary];
  NSDictionary* dataJson = [jsonObj objectForKey:KEY_DATA_RECORDS];
  if(nil != dataJson){
    [dataJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      [instance.dataRecords setObject:[FHSyncDataRecord objectFromJSONData:obj] forKey:key];
    }];
  }
  if([jsonObj objectForKey:KEY_SYNCLOOP_START]){
    instance.syncLoopStart = [NSDate dateWithTimeIntervalSince1970:[[jsonObj objectForKey:KEY_SYNCLOOP_START] doubleValue]];
  }
  if([jsonObj objectForKey:KEY_SYNCLOOP_END]){
    instance.syncLoopEnd = [NSDate dateWithTimeIntervalSince1970:[[jsonObj objectForKey:KEY_SYNCLOOP_END] doubleValue]];
  }
  instance.initialised = YES;
  return instance;

}

+ (FHSyncDataset*) objectFromJSONString:(NSString*) jsonStr
{
  NSDictionary* jsonObj = [jsonStr objectFromJSONString];
  return [FHSyncDataset objectFromJSONData:jsonObj];
}

- (NSString*) description
{
  return [self JSONString];
}


@end

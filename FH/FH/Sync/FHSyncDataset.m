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
#import "FH.h"
#import "FHSyncNotificationMessage.h"
#import "FHResponse.h"

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
@synthesize  syncStarted = _syncStarted;
@synthesize  acknowledgements = _acknowledgements;
@synthesize  stopSync = _stopSync;

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
    self.syncStarted = NO;
    self.acknowledgements = [NSMutableArray array];
    self.stopSync = NO;
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
  @synchronized(self){
    [FHSyncUtils saveData:jsonStr toFile:[self.datasetId stringByAppendingPathExtension:STORAGE_FILE_PATH] error:error];
  }
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

- (NSDictionary*) listData
{
  NSMutableDictionary* data = [NSMutableDictionary dictionary];
  if(self.dataRecords){
    [self.dataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      FHSyncDataRecord* record = (FHSyncDataRecord*) obj;
      [data setObject:record.data forKey:record.uid];
    }];
  }
  return data;
}

- (NSDictionary*) readDataWithUID: (NSString*) uid
{
  FHSyncDataRecord* record = [self.dataRecords objectForKey:uid];
  if(record){
    return [record data];
  } else {
    return nil;
  }
}

- (BOOL) createWithData:(NSDictionary*) data
{
  return [self addPendingObject:nil data:data AndAction:@"create"];
}

- (BOOL) updateWithUID:(NSString*) uid data:(NSDictionary*) data
{
  return [self addPendingObject:uid data:data AndAction:@"update"];
}

- (BOOL) deleteWithUID: (NSString*) uid
{
  return [self addPendingObject:uid data:NULL AndAction:@"delete"];
}

- (BOOL) addPendingObject:(NSString*) uid data:(NSDictionary*) data AndAction:(NSString*) action
{
  BOOL success = NO;
  if(![FH isOnline]){
    [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:uid code:OFFLINE_UPDATE_MESSAGE message:action];
  }
  FHSyncPendingDataRecord* pendingObj = [[FHSyncPendingDataRecord alloc] init];
  pendingObj.inFlight = NO;
  pendingObj.action = action;
  
  if(data){
    FHSyncDataRecord* postdata = [[FHSyncDataRecord alloc] initWithData:data];
    pendingObj.postData = postdata;
  }
  
  if([action isEqualToString:@"create"]){
    pendingObj.uid = pendingObj.postData.hashValue;
    [self storePendingObj:pendingObj];
  } else {
    FHSyncDataRecord* existingData = [self.dataRecords objectForKey:uid];
    if(nil != existingData){
      pendingObj.uid = uid;
      pendingObj.preData = [existingData copy];
      [self storePendingObj:pendingObj];
    }
  }
  success = YES;
  return success;
}

- (void) storePendingObj:(FHSyncPendingDataRecord*) obj
{
  [self.pendingDataRecords setObject:obj forKey:obj.hashValue];
  [self updateDatasetFromLocal:obj];
  if (self.syncConfig.autoSyncLocalUpdates) {
    self.syncLoopPending = YES;
  }
  [self saveToFile:nil];
  [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:obj.uid code:LOCAL_UPDATE_APPLIED_MESSAGE message:obj.action];
}

- (void) updateDatasetFromLocal: (FHSyncPendingDataRecord*) pendingObj
{
  NSString* previousePendingUID = nil;
  FHSyncPendingDataRecord* previousePendingObj = nil;
  NSString* uid = pendingObj.uid;
  NSLog(@"updating local dataset for uid %@ - action = %@", uid, pendingObj.action);
  NSMutableDictionary* metadata = [self.metaData objectForKey:uid];
  if (nil == metadata) {
    metadata =[NSMutableDictionary dictionary];
    [self.metaData setObject:metadata forKey:uid];
  }
  
  FHSyncDataRecord* existing = [self.dataRecords objectForKey:uid];
  id fromPending = [metadata objectForKey:@"fromPending"];
  
  if([pendingObj.action isEqualToString:@"create"]){
    if (nil != existing) {
      NSLog(@"dataset already exists for uid for create :: %@", existing);
      if (fromPending && [fromPending boolValue]) {
        // We are trying to create on top of an existing pending record
        // Remove the previous pending record and use this one instead
        previousePendingUID = [metadata objectForKey:@"pendingUid"];
        [self.pendingDataRecords removeObjectForKey:previousePendingUID];
      }
    }
    [self.dataRecords setObject:[[FHSyncDataRecord alloc] init] forKey:uid];
  }

  if([pendingObj.action isEqualToString:@"update"]){
    if (nil != existing) {
      if (fromPending && [fromPending boolValue]){
        NSLog(@"updating an existing pending record for dataset :: %@", existing);
        // We are trying to update an existing pending record
        previousePendingUID = [metadata objectForKey:@"pendingUid"];
        [metadata setObject:previousePendingUID forKey:@"previousPendingUid"];
        previousePendingObj = [self.pendingDataRecords objectForKey:previousePendingUID];
        if (nil != previousePendingObj && !previousePendingObj.inFlight) {
          NSLog(@"existing pre-flight pending record = %@", previousePendingObj);
          // We are trying to perform an update on an existing pending record
          // modify the original record to have the latest value and delete the pending update
          previousePendingObj.postData = pendingObj.postData;
          [self.pendingDataRecords removeObjectForKey:pendingObj.hashValue];
        }
      }
    }
  }
  
  if ([pendingObj.action isEqualToString:@"delete"]) {
    if (nil != existing){
      if (fromPending && [fromPending boolValue]) {
        NSLog(@"Deleting an existing pending record for dataset :: %@", existing);
        // We are trying to delete an existing pending record
        previousePendingUID = [metadata objectForKey:@"pendingUid"];
        [metadata setObject:previousePendingUID forKey:@"previousPendingUid"];
        previousePendingObj = [self.pendingDataRecords objectForKey:previousePendingUID];
        if (previousePendingObj && !previousePendingObj.inFlight) {
          NSLog(@"existing pending record = %@", previousePendingObj);
          if ([previousePendingObj.action isEqualToString:@"create"]) {
            // We are trying to perform a delete on an existing pending create
            // These cancel each other out so remove them both
            [self.pendingDataRecords removeObjectForKey:pendingObj.hashValue];
            [self.pendingDataRecords removeObjectForKey:previousePendingUID];
          }
          if ([previousePendingObj.action isEqualToString:@"update"]) {
            // We are trying to perform a delete on an existing pending update
            // Use the pre value from the pending update for the delete and
            // get rid of the pending update
            pendingObj.preData = previousePendingObj.preData;
            pendingObj.inFlight = false;
            [self.pendingDataRecords removeObjectForKey:previousePendingUID];
          }
        }
      }
      [self.dataRecords removeObjectForKey:uid];
    }
  }
  
  if ([self.dataRecords objectForKey:uid]) {
    FHSyncDataRecord* record = pendingObj.postData;
    [self.dataRecords setObject:record forKey:uid];
    [metadata setObject:[NSNumber numberWithBool:YES] forKey:@"fromPending"];
    [metadata setObject:pendingObj.hashValue forKey:@"pendingUid"];
  }

}

- (void) startSyncLoop
{
  if (!self.syncStarted) {
    [self performSelectorInBackground:@selector(startSyncTask:) withObject:nil];
    self.syncStarted = YES;
  }
}

- (void) startSyncTask
{
  self.syncLoopPending = NO;
  self.syncRunning = YES;
  self.syncLoopStart = [NSDate date];
  [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:NULL code:SYNC_STARTED_MESSAGE message:NULL];
  if (![FH isOnline]) {
    [self syncCompleteWithCode:@"offline"];
  } else {
    NSMutableDictionary* syncLoopParams = [NSMutableDictionary dictionary];
    [syncLoopParams setObject:@"sync" forKey:@"fn"];
    [syncLoopParams setObject:self.datasetId forKey:@"dataset_id"];
    [syncLoopParams setObject:self.queryParams forKey:@"query_params"];
    [syncLoopParams setObject:self.hashValue forKey:@"dataset_hash"];
    [syncLoopParams setObject:self.acknowledgements forKey:@"acknowledgements"];
    
    NSMutableArray* pendingArray = [NSMutableArray array];
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
      if(!pendingRecord.inFlight && !pendingRecord.crashed){
        pendingRecord.inFlight = YES;
        pendingRecord.inFlightDate = [NSDate date];
        [pendingArray addObject:[pendingRecord JSONData]];
      }
    }];
    
    [syncLoopParams setObject:pendingArray forKey:@"pending"];
    if ([pendingArray count] > 0) {
      NSLog(@"Starting sync loop - global hash = %@ :: params = %@", self.hashValue, syncLoopParams);
    }
    
    @try
    {
      [FH performActRequest:self.datasetId WithArgs:syncLoopParams AndSuccess:^(FHResponse* response){
        
        NSMutableDictionary* resData = [[response parsedResponse] mutableCopy];
        // Check to see if any new pending records need to be updated to reflect the current state of play.
        [self updatePendingFromNewData:resData];
        
        //Check to see if any previously crashed inflight records can now be resolved
        [self updateCrashedInFlightFromNewData:resData];
        
        //Update the new dataset with details of any inflight updates which we have not received a response on
        [self updateNewDataFromInFlight:resData];
        
        // Update the new dataset with details of any pending updates
        [self updateNewDataFromPending:resData];
        
        if([resData objectForKey:@"records"]){
          // Full Dataset returned
          [self resetDataRecords:resData];
        }
        
        if([resData objectForKey:@"updates"]){
          NSMutableArray* ack = [NSMutableArray array];
          NSDictionary* updates = [resData objectForKey:@"updates"];
          [self processUpdates:[updates objectForKey:@"applied"] notification:REMOTE_UPDATE_APPLIED_MESSAGE acknowledgements:ack];
          [self processUpdates:[updates objectForKey:@"failed"] notification:REMOTE_UPDATE_FAILED_MESSAGE acknowledgements:ack];
          [self processUpdates:[updates objectForKey:@"collisions"] notification:COLLISION_DETECTED_MESSAGE acknowledgements:ack];
          self.acknowledgements = ack;
        } else if([resData objectForKey:@"hash"] && ![[resData objectForKey:@"hash"] isEqualToString:self.hashValue]){
          NSString* remoteHash = [resData objectForKey:@"hash"];
          NSLog(@"Local dataset stale - syncing records :: local hash= %@ - remoteHash = %@", self.hashValue, remoteHash);
           // Different hash value returned - Sync individual records
          [self syncRecords];
        } else {
          NSLog(@"LOcal dataset up to date");
        }
        
        [self syncCompleteWithCode:@"online"];
        
      } AndFailure:^(FHResponse* response){
        // The AJAX call failed to complete succesfully, so the state of the current pending updates is unknown
        // Mark them as "crashed". The next time a syncLoop completets successfully, we will review the crashed
        // records to see if we can determine their current state.
        [self markInFlightAsCrashed];
        NSLog(@"syncLoop failed : msg = %@", [[response parsedResponse] JSONString]);
        [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:NULL code:SYNC_FAILED_MESSAGE message:[[response parsedResponse] JSONString]];
        [self syncCompleteWithCode:[[response parsedResponse] JSONString]];
      }];
    }
    @catch (NSException * ex)
    {
      NSLog(@"Error performing sync - %@", ex);
      [self syncCompleteWithCode:ex.reason];
    }
  
  }
}

- (void) syncRecords
{
  NSMutableDictionary* clientRecs = [NSMutableDictionary dictionary];
  [self.dataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    NSString* uid = (NSString*) key;
    NSString* hash = [(FHSyncDataRecord*) obj hashValue];
    [clientRecs setObject:hash forKey:uid];
  }];
  
  NSMutableDictionary* syncRecsParams = [NSMutableDictionary dictionary];
  [syncRecsParams setObject:@"syncRecords" forKey:@"fn"];
  [syncRecsParams setObject:self.datasetId forKey:@"dataset_id"];
  [syncRecsParams setObject:self.queryParams forKey:@"query_params"];
  [syncRecsParams setObject:clientRecs forKey:@"clientRecs"];
  
  NSLog(@"syncRecParams :: %@", [syncRecsParams JSONString] );
  
  [FH performActRequest:self.datasetId WithArgs:syncRecsParams AndSuccess:^(FHResponse* response){
    NSDictionary* dataCreated =[[response parsedResponse] objectForKey:@"create"];
    if (nil != dataCreated) {
      [dataCreated enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        FHSyncDataRecord* rec = [[FHSyncDataRecord alloc] initWithData:[obj objectForKey:@"data"]];
        rec.hashValue = [obj objectForKey:@"hash"];
        [self.dataRecords setObject:rec forKey:key];
        [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:key code:DELTA_RECEIVED_MESSAGE message:@"create"];
      }];
    }
    
    NSDictionary* dataUpdated = [[response parsedResponse] objectForKey:@"update"];
    if (nil != dataUpdated) {
      [dataUpdated enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        FHSyncDataRecord* rec = [self.dataRecords objectForKey:key];
        if (rec) {
          rec.data = [obj objectForKey:@"data"];
          rec.hashValue = [obj objectForKey:@"hash"];
          [self.dataRecords setObject:rec forKey:key];
          [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:key code:DELTA_RECEIVED_MESSAGE message:@"update"];
        }
      }];
    }
    
    NSDictionary* deleted = [[response parsedResponse] objectForKey:@"delete"];
    if (nil != deleted) {
      [deleted enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        [self.dataRecords removeObjectForKey:key];
        [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:key code:DELTA_RECEIVED_MESSAGE message:@"delete"];
      }];
    }
    
    if ([[response parsedResponse] objectForKey:@"hash"]) {
      self.hashValue = [[response parsedResponse] objectForKey:@"hash"];
    }
   [self syncCompleteWithCode:@"online"];
   
  } AndFailure:^(FHResponse* response){
    NSLog(@"syncRecords failed : %@", [[response parsedResponse] JSONString]);
    [self syncCompleteWithCode:[[response parsedResponse] JSONString]];
  }];
}

- (void) resetDataRecords: (NSDictionary*) resData
{
  NSDictionary* records = [resData objectForKey:@"records"];
  NSMutableDictionary* allRecords = [NSMutableDictionary dictionary];
  [records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    NSDictionary* data = (NSDictionary*) obj;
    FHSyncDataRecord* record = [[FHSyncDataRecord alloc] initWithData:data];
    [allRecords setObject:record forKey:key];
  }];
  
  self.dataRecords = allRecords;
  self.hashValue = [resData objectForKey:@"hash"];
  [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:self.hashValue code:DELTA_RECEIVED_MESSAGE message:@"full dataset"];
}

- (void) processUpdates:(NSDictionary* ) updates notification:(NSString*) notifcation acknowledgements:(NSMutableArray*) acknowledgements
{
  if (nil !=  updates) {
    [updates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      NSDictionary* up = (NSDictionary*) obj;
      NSString* keyVal = (NSString*) key;
      [acknowledgements addObject:up];
      FHSyncPendingDataRecord* pendingRec = [self.pendingDataRecords objectForKey:keyVal];
      if ((nil != pendingRec) && pendingRec.inFlight && !pendingRec.crashed) {
        [self.pendingDataRecords removeObjectForKey:keyVal];
        [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:[up objectForKey:@"uid"] code:notifcation message:[up JSONString]];
      }
    }];
  }
}

/*
 FH will run all the callbacks on the main thread. Because this syncCompleteWithStatus function is called mostly from the callback functions,
 if the device is online, the function will be executed on the main thread and it may bloack the UI when saving large data.
 However, if the device is offline, this function may get called from the background thread. But the background thread could be kill by the os
 as soon as the function finishes, the NSTimer instance will not be executed.
 
 So, we always put the NSTimer instance on the main thread, which means the startSyncTaskWithTimer will be called from the main thread.Then in that
 function we invoke the sync task on a background thread and we always do the data saving on the background thread.
 */
- (void) syncCompleteWithCode: (NSString*) code
{
  self.syncRunning = NO;
  self.syncLoopEnd = [NSDate date];
  BOOL isMainThread = [NSThread isMainThread];
  if (isMainThread) {
    [self performSelectorInBackground:@selector(saveToFile) withObject:nil];
  } else {
    [self saveToFile:nil];
  }
  [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:self.hashValue code:SYNC_COMPLETE_MESSAGE message:code];
}

- (void) updatePendingFromNewData: (NSDictionary*) remoteData
{
  if (self.pendingDataRecords && [remoteData objectForKey:@"records"]) {
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
      NSMutableDictionary* metadata = [self.metaData objectForKey:pendingRecord.uid];
      if (nil == metadata) {
        metadata = [NSMutableDictionary dictionary];
        [self.metaData setObject:metadata forKey:pendingRecord.uid];
      }
      if(!pendingRecord.inFlight){
        //Pending record that has not been submitted
        NSLog(@"updatePendingFromNewData - Found Non inFlight record -> action = %@ :: uid = %@ :: hash = %@", pendingRecord.action, pendingRecord.uid, pendingRecord.hashValue);
        if ([pendingRecord.action isEqualToString:@"update"] || [pendingRecord.action isEqualToString:@"delete"]) {
          // Update the pre value of pending record to reflect the latest data returned from sync.
          NSDictionary* remoteRec = [[remoteData objectForKey:@"records"] objectForKey:pendingRecord.uid];
          if (nil != remoteRec) {
            NSLog(@"updatePendingFromNewData - updateing pre values for existing pending record %@", pendingRecord.uid );
            FHSyncDataRecord* rec = [[FHSyncDataRecord alloc] initWithData:remoteRec];
            pendingRecord.preData = rec;
          } else {
            //The update/delete may be for a newly created record in which case the uid will be changed.
            NSString* previousPendingUid = [metadata objectForKey:@"previousPendingUid"];
            FHSyncPendingDataRecord* previousPendingRec = [self.pendingDataRecords objectForKey:previousPendingUid];
            if (nil != previousPendingRec) {
              if (nil != remoteData && [remoteData objectForKey:@"updates"]) {
                NSDictionary* updates = [remoteData objectForKey:@"updates"];
                if ([updates objectForKey:@"applied"] && [[updates objectForKey:@"applied"] objectForKey:previousPendingRec.hashValue]) {
                  //There is an update in from a previous pending action
                  NSString* remoteUid = [[[updates objectForKey:@"applied"] objectForKey:previousPendingRec.hashValue] objectForKey:@"uid"]; //dictionary...:(
                  if (nil != remoteUid) {
                    remoteRec = [[remoteData objectForKey:@"records"] objectForKey:remoteUid];
                    if (remoteRec) {
                      NSLog(@"updatePendingFromNewData - Updating pre values for existing pending record which was previously a create %@ ==> %@", pendingRecord.uid, remoteUid);
                      FHSyncDataRecord* record = [[FHSyncDataRecord alloc] initWithData:remoteRec];
                      pendingRecord.preData = record;
                      pendingRecord.uid = remoteUid;
                    }
                  }
                }
              }
            }
          }
        }
      }
      
      NSString* pendingHash = (NSString*) key;
      if ([pendingRecord.action isEqualToString:@"create"]) {
        if (nil != remoteData && [remoteData objectForKey:@"updates"]){
          NSDictionary* updates = [remoteData objectForKey:@"updates"];
          if ([updates objectForKey:@"applied"] && [[updates objectForKey:@"applied"] objectForKey:pendingHash]){
            NSDictionary* appliedData = [[updates objectForKey:@"applied"] objectForKey:pendingHash];
            NSLog(@"updatePendingFromNewData - Found an update for a pending create %@", appliedData);
            NSDictionary* remoteRec = [remoteData objectForKey:[appliedData objectForKey:@"uid"]];
            if (nil != remoteRec) {
              NSLog(@"updatePendingFromNewData - Changing pending create to an update based on new record %@", remoteRec);
              
              //Set up the pending as an update
              pendingRecord.action = @"update";
              FHSyncDataRecord* preData = [[FHSyncDataRecord alloc] initWithData:remoteRec];
              pendingRecord.preData = preData;
              pendingRecord.uid = [appliedData objectForKey:@"uid"];
            }
            
          }
        }
      }
    }];
  }
}

- (void) updateCrashedInFlightFromNewData: (NSDictionary*) remoteData
{
  NSDictionary* updateNotifications = [NSDictionary dictionaryWithObjectsAndKeys:REMOTE_UPDATE_APPLIED_MESSAGE, @"applied", REMOTE_UPDATE_FAILED_MESSAGE, @"failed", COLLISION_DETECTED_MESSAGE, @"collisions", nil];
  NSMutableDictionary* resolvedCrashed = [NSMutableDictionary dictionary];
  NSMutableArray* keysToRemove = [NSMutableArray array];
  
  [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
    NSString* pendingHash = (NSString*) key;
    if(pendingRecord.inFlight && pendingRecord.crashed){
      NSLog(@"updateCrashedInFlightFromNewData - Found crashed inFlight pending record uid= %@ :: hash= %@", pendingRecord.uid, pendingRecord.hashValue);
      if (remoteData && [remoteData objectForKey:@"updates"] && [[remoteData objectForKey:@"updates"] objectForKey:@"hashes"]) {
        NSDictionary* hashes = [[remoteData objectForKey:@"updates"] objectForKey:@"hashes"];
        //check if the updates received contain any info about the crashed inflight update
        NSDictionary* crashedUpdate = [hashes objectForKey:pendingHash];
        if(nil != crashedUpdate){
          [resolvedCrashed setObject:crashedUpdate forKey:[crashedUpdate objectForKey:@"uid"]];
          NSLog(@"updateCrashedInFlightFromNewData - Resolving status for crashed inflight pending record %@", crashedUpdate);
          NSString* crashedType = [crashedUpdate objectForKey:@"type"];
          NSString* crashedAction = [crashedUpdate objectForKey:@"action"];
          if (nil != crashedType && [crashedType isEqualToString:@"failed"]){
            //Crashed updated failed - revert local dataset
            if (crashedAction && [crashedAction isEqualToString:@"create"]) {
              NSLog(@"updateCrashedInFlightFromNewData - Deleting failed create from dataset");
              [self.dataRecords removeObjectForKey:[crashedUpdate objectForKey:@"uid"]];
            } else if (crashedAction && ([crashedAction isEqualToString:@"update"] || [crashedAction isEqualToString:@"delete"])){
              NSLog(@"updateCrashedInFlightFromNewData - Reverting failed %@ in dataset", crashedAction);
              [self.dataRecords setObject:pendingRecord.preData forKey:[crashedUpdate objectForKey:@"uid"]];
            }
          }
          [keysToRemove addObject:pendingHash];
          [FHSyncUtils doNotifyWithDataId:self.datasetId config:self.syncConfig uid:[crashedUpdate objectForKey:@"uid"] code:[updateNotifications objectForKey:[crashedUpdate objectForKey:@"type"]] message:[crashedUpdate JSONString]];
        } else {
          // No word on our crashed update - increment a counter to reflect another sync that did not give us
          // any update on our crashed record.
          pendingRecord.crashedCount++;
        }
      } else {
        // No word on our crashed update - increment a counter to reflect another sync that did not give us
        // any update on our crashed record.
        pendingRecord.crashedCount++;
      }
    }
  }];
  
  [self.pendingDataRecords removeObjectsForKeys:keysToRemove];
  [keysToRemove removeAllObjects];
  
  [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
    NSString* pendingHash = (NSString*) key;
    
    if (pendingRecord.inFlight && pendingRecord.crashed) {
      if (pendingRecord.crashedCount > self.syncConfig.crashCountWait) {
        NSLog(@"updateCrashedInFlightFromNewData - Crashed inflight pending record has reached crashed_count_wait limit : '%@", pendingRecord);
        if (self.syncConfig.resendCrashedUpdates) {
          NSLog(@"updateCrashedInFlightFromNewData - Retryig crashed inflight pending record");
          pendingRecord.crashed = NO;
          pendingRecord.inFlight = NO;
        } else {
          NSLog(@"updateCrashedInFlightFromNewData - Deleting crashed inflight pending record");
          [keysToRemove addObject:pendingHash];
        }
      }
    } else if (!pendingRecord.inFlight && pendingRecord.crashed) {
      NSLog(@"updateCrashedInFlightFromNewData - Trying to resolve issues with crashed non in flight record - uid = %@", pendingRecord.uid);
      // Stalled pending record because a previous pending update on the same record crashed
      NSDictionary* dict = [resolvedCrashed objectForKey:pendingRecord.uid];
      if (nil != dict) {
        NSLog(@"updateCrashedInFlightFromNewData - Found a stalled pending record backed up behind a resolved crash uid=%@ :: hash=%@", pendingRecord.uid, pendingRecord.hashValue);
        pendingRecord.crashed = NO;
      }
    }
  }];
  
  [self.pendingDataRecords removeObjectsForKeys:keysToRemove];
  
}

- (void) updateNewDataFromInFlight:(NSMutableDictionary*) remoteData
{
  if (self.pendingDataRecords && [remoteData objectForKey:@"records"]) {
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
      NSString* pendingHash = (NSString*) key;
      
      if (pendingRecord.inFlight) {
        BOOL updateReceivedForPending = (nil != remoteData) && (nil!= [remoteData objectForKey:@"updates"]) && (nil!= [[remoteData objectForKey:@"updates"] objectForKey:@"hashes"]) && (nil!= [[[remoteData objectForKey:@"updates"] objectForKey:@"hashes"] objectForKey:pendingHash] ) ? YES : NO;
        NSLog(@"updateNewDataFromInFlight - Found inflight pending Record - action = %@ :: hash = %@ :: updateReceivedForPending= %d", pendingRecord.action, pendingHash, updateReceivedForPending);
        if (!updateReceivedForPending) {
          NSMutableDictionary* remoteRecord = [[[remoteData objectForKey:@"records"] objectForKey:pendingRecord.uid] mutableCopy];
          if ([pendingRecord.action isEqualToString:@"update"] && (nil != remoteRecord)) {
            // Modify the new Record to have the updates from the pending record so the local dataset is consistent
            [remoteRecord setObject:pendingRecord.postData.data forKey:@"data"];
            [remoteRecord setObject:pendingRecord.postData.hashValue forKey:@"hash"];
          } else if ( [pendingRecord.action isEqualToString:@"delete"] && (nil != remoteRecord)){
            // Remove the record from the new dataset so the local dataset is consistent
            [[remoteData objectForKey:@"records"] removeObjectForKey:pendingRecord.uid];
          } else if ([pendingRecord.action isEqualToString:@"create"]){
            // Add the pending create into the new dataset so it is not lost from the UI
            NSLog(@"updateNewDataFromInFlight - re adding pending create to incomming dataset");
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:pendingRecord.postData.data, @"data", pendingRecord.postData.hashValue, @"hash", nil];
            [[remoteData objectForKey:@"records"] setObject:dict forKey:pendingRecord.uid];
          }
        }
        
      }
      
    }];
  }
}

- (void) updateNewDataFromPending: (NSMutableDictionary*) remoteData
{
  if (self.pendingDataRecords && [remoteData objectForKey:@"records"]) {
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
      FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
      
      if (!pendingRecord.inFlight) {
        NSLog(@"updateNewDataFromPending - Found Non inFlight record -> action=%@ :: uid=%@ :: hash=%@", pendingRecord.action, pendingRecord.uid, pendingRecord.hashValue);
        NSMutableDictionary* remoteRecord = [[remoteData objectForKey:@"records"] objectForKey:pendingRecord.uid];
        if ([pendingRecord.action isEqualToString:@"update"] && (nil != remoteRecord)) {
          // Modify the new Record to have the updates from the pending record so the local dataset is consistent
          [remoteRecord setObject:pendingRecord.postData.data forKey:@"data"];
          [remoteRecord setObject:pendingRecord.postData.hashValue forKey:@"hash"];
        } else if ([pendingRecord.action isEqualToString:@"delete"] && (nil != remoteRecord)){
          [[remoteData objectForKey:@"records"] removeObjectForKey:pendingRecord.uid];
        } else if([pendingRecord.action isEqualToString:@"create"]){
          // Add the pending create into the new dataset so it is not lost from the UI
          NSLog(@"updateNewDataFromPending - re adding pending create to incomming dataset");
          NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:pendingRecord.postData.data, @"data", pendingRecord.postData.hashValue, @"hash", nil];
          [[remoteData objectForKey:@"records"] setObject:dict forKey:pendingRecord.uid];
        }
      }
    }];
  }
}

- (void) markInFlightAsCrashed
{
  NSMutableDictionary* crashedRecords = [NSMutableDictionary dictionary];
  [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
    NSString* pendingHash = (NSString*) key;
    if (pendingRecord.inFlight) {
      NSLog(@"Marking in flight pending record as crashed : %@", pendingHash);
      pendingRecord.crashed = YES;
      [crashedRecords setObject:pendingRecord forKey:pendingRecord.uid];
    }
  }];
  
  // Check for any pending updates that would be modifying a crashed record. These can not go out until the
  // status of the crashed record is determined
  [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*) obj;
    if (!pendingRecord.inFlight) {
      if ([crashedRecords objectForKey:pendingRecord.uid]) {
        pendingRecord.crashed = YES;
      }
    }
  }];
  
}

@end

//
//  FHSyncClient.m
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncClient.h"
#import "FHSyncConfig.h"
#import "JSONKit.h"
#import "FHSyncNotificationMessage.h"
#import <CommonCrypto/CommonDigest.h>
#import "FH.h"
#import "FHResponse.h"
#import "FHSyncUtils.h"




@interface FHSyncClient()
{
  NSMutableDictionary * _dataSets;
  FHSyncConfig * _syncConfig;
  BOOL _initialized;
  NSMutableDictionary* _runningTasks;
}

@property (nonatomic, retain) NSMutableDictionary* dataSets;
@property (nonatomic, retain) FHSyncConfig* syncConfig;
@property (nonatomic, retain) NSMutableDictionary* runningTasks;
@end

@implementation FHSyncClient
@synthesize dataSets = _dataSets;
@synthesize syncConfig = _syncConfig;
@synthesize runningTasks = _runningTasks;

static FHSyncClient* shared = nil;

- (id) initWithConfig:(FHSyncConfig*) config
{
  self = [super init];
  if(self){
    _syncConfig = [config copy];
    _runningTasks = [NSMutableDictionary dictionary];
    _dataSets = [NSMutableDictionary dictionary];
    _initialized = YES;
    [self datasetMonitor];
  }
  return self;
}

+ (FHSyncClient*) getInstance
{
  @synchronized(self){
    if(nil == shared){
      shared = [[self alloc] init];
    }
  }
  return shared;
}

- (void) datasetMonitor
{
  NSLog(@"start to run checkDataets");
  [self checkDatasets];
  [NSTimer scheduledTimerWithTimeInterval:500 target:self selector:@selector(datasetMonitor:) userInfo:[NSDictionary dictionary] repeats:NO];
}

- (void) checkDatasets
{
  [self.dataSets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
    NSDictionary* dataset = (NSDictionary*) obj;
    NSNumber* syncRunning = [dataset objectForKey:@"syncRunning"];
    if( nil != syncRunning && ![syncRunning boolValue]){
      //sync isn't running for dataId at the moment, check if needs to start it
      NSDate* lastSyncStart = [dataset objectForKey:@"syncLoopStart"];
      NSDate* lastSyncCmp = [dataset objectForKey:@"syncLoopEnd"];
      if( nil == lastSyncStart){
        //sync never started
        [dataset setValue:[NSNumber numberWithBool:YES] forKey:@"syncPending"];
      } else if(nil != lastSyncCmp){
        //otherwise check how long since the last sync has finished
        NSTimeInterval timeSinceLastSync = [[NSDate date] timeIntervalSinceDate:lastSyncCmp];
        FHSyncConfig* dataSyncConfig = [dataset objectForKey:@"config"];
        if(timeSinceLastSync > dataSyncConfig.syncFrequency){
          [dataset setValue:[NSNumber numberWithBool:YES] forKey:@"syncPending"];
        }
      }
      if([[dataset objectForKey:@"syncPending"] boolValue]){
        NSLog(@"start to run syncLoopWithDataId %@", key);
        [self syncLoopWithDataId:(NSString*)key];
      }
    }
  }];
}

- (BOOL) isOnline
{
  return [FH isOnline];
}

- (void) manageWithDataId:(NSString* ) dataId AndConfig:(FHSyncConfig *)config AndQuery:(NSDictionary *)queryParams
{
  if(!_initialized){
    [NSException raise:@"FHSyncClient isn't initialized" format:@"FHSyncClient hasn't been initialized. Have you called the init function?"];
  }
  
  //first, check if the dataset for dataId is already loaded
  NSMutableDictionary* dataSet = [_dataSets objectForKey:dataId];
  if(nil == dataSet){
    //not loaded yet, try to read it from a local file
    NSError* error = nil;
    dataSet = [FHSyncUtils loadDataFromFile:[dataId stringByAppendingPathExtension:STORAGE_FILE_PATH] error: error];
    if (nil == error) {
      //data loaded successfully
      [self doNotifyWithDataId:dataId uid:NULL code:LOCAL_UPDATE_APPLIED_MESSAGE message:@"load"];
    } else {
      //cat not load data, create a new map for it
      dataSet = [NSMutableDictionary dictionary];
      [dataSet setObject:[NSMutableDictionary dictionary] forKey:@"pending"];
    }
    [_dataSets setObject:dataSet forKey:dataId];
  }
  
  //allow to set sync config options for each dataset
  FHSyncConfig* dataSyncConfig = [_syncConfig copy];
  if (nil != config) {
    dataSyncConfig = [config copy];
  }
  [dataSet setObject:dataSyncConfig forKey:@"config"];
  
  //if the dataset is not initialised yet, do the init
  NSNumber* inited = [dataSet objectForKey:@"initialised"];
  if(nil == inited || ![inited boolValue]){
    [dataSet setObject:queryParams forKey:@"query_params"];
    [dataSet setObject:[NSNumber numberWithBool:NO] forKey:@"syncRunning"];
    [dataSet setObject:[NSNumber numberWithBool:YES] forKey:@"syncPending"];
    [dataSet setObject:[NSNumber numberWithBool:YES] forKey:@"initialised"];
    [dataSet setObject:[NSMutableDictionary dictionary] forKey:@"meta"];
  }
  
  [self saveDataSetWithDataId:dataId];
}

- (void) saveDataSetWithDataId:(NSString*) dataId
{
  @synchronized(self){
    NSMutableDictionary* data = [_dataSets objectForKey:dataId];
    NSError* error = nil;
    [FHSyncUtils saveData:data toFile:[dataId stringByAppendingPathExtension:STORAGE_FILE_PATH] error:error];
    if (nil != error) {
      [self doNotifyWithDataId:dataId uid:NULL code:CLIENT_STORAGE_FAILED_MESSAGE message:[NSString stringWithFormat:@"failed to save file. Error: %@", [error localizedDescription]]];
    }
  }
}

- (void) stopWithDataId:(NSString*) dataId
{
  [_runningTasks setObject:@"NO" forKey:dataId];
}

- (void) destroy
{
  if (_initialized){
    [_dataSets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
      [self stopWithDataId:key];
    }];
    _dataSets = nil;
    _syncConfig = nil;
    _initialized = NO;
  }
}

- (NSDictionary *) listWithDataId:(NSString *)dataId
{
  NSDictionary* dataSet = [_dataSets objectForKey:dataId];
  NSDictionary * data = nil;
  if (dataSet) {
    data = [dataSet objectForKey:@"data"];
  }
  return data;
}

- (NSDictionary*) readWithDataId:(NSString *)dataId AndUID:(NSString *)uid
{
  NSDictionary * dataSet = [self listWithDataId:dataId];
  NSDictionary * data = nil;
  if(dataSet){
    data = [dataSet objectForKey:uid];
  }
  return data;
}

- (NSDictionary*) createWithDataId:(NSString *)dataId AndData:(NSDictionary *)data
{
  return [self addPendingObjectWithDataId:dataId uid:nil data:data AndAction:@"create"];
}

- (NSDictionary*) updateWithDataId:(NSString *)dataId AndUID:(NSString *)uid AndData:(NSDictionary *)data
{
  return [self addPendingObjectWithDataId:dataId uid:uid data:data AndAction:@"update"];
}

- (NSDictionary*) deleteWithDataId:(NSString *)dataId AndUID:(NSString *)uid
{
  return [self addPendingObjectWithDataId:dataId uid:uid data:nil AndAction:@"delete"];
}

- (NSDictionary*) getPending:(NSString*) dataId
{
  NSDictionary* dataset = [_dataSets objectForKey:dataId];
  if(nil != dataset){
    return [dataset objectForKey:@"pending"];
  }
  return nil;
}

- (void) clearPending:(NSString*) dataId
{
  NSMutableDictionary* dataset = [_dataSets objectForKey:dataId];
  if(nil != dataset){
    [dataset setObject:[NSMutableDictionary dictionary] forKey:@"pending"];
    [self saveDataSetWithDataId:dataId];
  }
}

- (void) storePendingObjWithDataId:(NSString*) dataId uid:(NSString*) uid obj:(NSMutableDictionary* ) obj action:(NSString* ) action
{
  NSString* hashValue = [FHSyncUtils generateHashForData:obj];
  [obj setObject:hashValue forKey:@"hash"];
  NSMutableDictionary* dataset = [_dataSets objectForKey:dataId];
  if(nil != dataset){
    NSMutableDictionary* pendings = [dataset objectForKey:@"pending"];
    [pendings setObject:obj forKey:hashValue];
    [self updateDatasetFromLocal:dataset obj:obj];
    if(_syncConfig.autoSyncLocalUpdates){
      [dataset setObject:[NSNumber numberWithBool:YES] forKey:@"syncPending"];
    }
    [self saveDataSetWithDataId:dataId];
    [self doNotifyWithDataId:dataId uid:uid code:LOCAL_UPDATE_APPLIED_MESSAGE message:action];
  }
}

- (NSDictionary*) addPendingObjectWithDataId:(NSString*) dataId uid:(NSString*) uid data:(NSDictionary*) data AndAction:(NSString*) action
{
  if(![self isOnline]){
    [self doNotifyWithDataId:dataId uid:uid code:OFFLINE_UPDATE_MESSAGE message:action];
  }
  NSMutableDictionary * pendingObj = [NSMutableDictionary dictionary];
  [pendingObj setObject:[NSNumber numberWithBool:NO] forKey:@"inFlight"];
  [pendingObj setValue:action forKey:@"action"];
  
  if(data){
    [pendingObj setObject:data forKey:@"post"];
    [pendingObj setObject:[FHSyncUtils generateHashForData:data] forKey:@"postHash"];
  }
  NSDate * now = [NSDate date];
  NSNumber *ts = [NSNumber numberWithDouble:[now timeIntervalSince1970] * 1000];
  [pendingObj setValue:ts  forKey:@"timestamp"];
  
  if([action isEqualToString:@"create"]){
    [pendingObj setValue:[pendingObj valueForKey:@"postHash"] forKey:@"uid"];
    [self storePendingObjWithDataId:dataId uid:uid obj:pendingObj action:action];
  } else {
    NSDictionary* existingData = [self readWithDataId:dataId AndUID:uid];
    if(nil != existingData){
      [pendingObj setValue:uid forKey:@"uid"];
      if([existingData objectForKey:@"data"]){
        [pendingObj setObject:[existingData objectForKey:@"data"] forKey:@"pre"];
        [pendingObj setValue:[FHSyncUtils generateHashForData:[existingData objectForKey:@"data"]] forKey:@"preHash"];
      }
      [self storePendingObjWithDataId:dataId uid:uid obj:pendingObj action:action];
    }
  }
}

- (void) doNotifyWithDataId:(NSString*) dataId uid:(NSString*) uid code:(NSString*) code message:(NSString*) message
{
  BOOL doSend = NO;
  if(_syncConfig.notifySyncStarted && [code isEqualToString:SYNC_STARTED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifySyncCompleted && [code isEqualToString:SYNC_COMPLETE_MESSAGE]) {
    doSend = YES;
  }
  if(_syncConfig.notifyClientStorageFailed && [code isEqualToString:CLIENT_STORAGE_FAILED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifyDeltaReceived && [code isEqualToString:DELTA_RECEIVED_MESSAGE ]){
    doSend = YES;
  }
  if(_syncConfig.notifyOfflineUpdate && [code isEqualToString:OFFLINE_UPDATE_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifySyncCollision && [code isEqualToString:COLLISION_DETECTED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifyRemoteUpdateApplied && [code isEqualToString:REMOTE_UPDATE_APPLIED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifyRemoteUpdateFailed && [code isEqualToString:REMOTE_UPDATE_FAILED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifyRemoteUpdateApplied && [code isEqualToString:LOCAL_UPDATE_APPLIED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifySyncFailed && [code isEqualToString:SYNC_FAILED_MESSAGE]){
    doSend = YES;
  }
  if(doSend){
    FHSyncNotificationMessage * notification = [[FHSyncNotificationMessage alloc] initWithDataId:dataId AndUID:uid AndCode:code AndMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHSyncStateChangedNotification object:notification];
  }
}

- (void) syncLoopWithDataId:(NSString *) dataId
{
  if(![_runningTasks objectForKey:dataId]){
   [self performSelectorInBackground:@selector(startSyncTaskWithDataId:) withObject:dataId];
    [_runningTasks setObject:@"YES" forKey:dataId];
  }
}

- (void) startSyncTaskWithTimer:(NSTimer*) timer
{
  NSDictionary* userInfo = [timer userInfo];
  NSString* dataId = [userInfo objectForKey:@"dataId"];
  [self performSelectorInBackground:@selector(startSyncTaskWithDataId:) withObject:dataId];
}

- (void) startSyncTaskWithDataId:(NSString*) dataId
{
  [self doNotifyWithDataId:dataId uid:nil code:SYNC_STARTED_MESSAGE message:nil];
  if(![self isOnline]){
    [self syncCompleteWithStatus:@"offline" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
  } else {
    NSMutableDictionary* dataSet = [_dataSets objectForKey:dataId];
    if(dataSet){
      NSMutableDictionary* params = [NSMutableDictionary dictionary];
      [params setValue:@"sync" forKey:@"fn"];
      [params setValue:dataId forKey:@"dataset_id"];
      if ([dataSet objectForKey:@"hash"]) {
        [params setValue:[dataSet objectForKey:@"hash"] forKey:@"dataset_hash"];
      }
      [params setValue:[[dataSet objectForKey:@"config"] objectForKey:@"query_params"] forKey:@"query_params"];
      NSDictionary* pendings = [dataSet objectForKey:@"pending"];
      __block NSMutableArray* pendingArray = [NSMutableArray array];
      [pendings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [pendingArray addObject:obj];
      }];
      [params setValue:pendingArray forKey:@"pending"];
      [FH performActRequest:dataId WithArgs:params AndSuccess:^(FHResponse* fhres){
        NSLog(@"FHSync success response: %@", [[fhres parsedResponse] JSONString]);
        NSMutableDictionary* resData = [[fhres parsedResponse] mutableCopy];
        if ([resData objectForKey:@"updates"]) {
          NSDictionary* updatesData = [resData objectForKey:@"updates"];
          if([updatesData objectForKey:@"applied"]){
            [self processDataWithDataId:dataId updates:[updatesData objectForKey:@"applied"] AndCode:REMOTE_UPDATE_APPLIED_MESSAGE];
          }
          if ([updatesData objectForKey:@"failed"]) {
            [self processDataWithDataId:dataId updates:[updatesData objectForKey:@"failed"] AndCode:REMOTE_UPDATE_FAILED_MESSAGE];
          }
          if([updatesData objectForKey:@"collisions"]) {
            [self processDataWithDataId:dataId updates:[updatesData objectForKey:@"collisions"] AndCode:COLLISION_DETECTED_MESSAGE];
          }
        }
       if([resData objectForKey:@"records"]){
         NSMutableDictionary * dataSet = [_dataSets objectForKey:dataId];
         [dataSet setObject:[[resData objectForKey:@"records"] mutableCopy] forKey:@"data"];
         [dataSet setObject:[resData objectForKey:@"hash"] forKey:@"hash"];
         [self doNotifyWithDataId:dataId uid:nil code:DELTA_RECEIVED_MESSAGE message:nil];
         [self syncCompleteWithStatus:@"online" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
       } else if([resData objectForKey:@"hash"]){
         NSString* resDataSetHash = (NSString* )[resData objectForKey:@"hash"];
         NSMutableDictionary * dataSet = [_dataSets objectForKey:dataId];
         NSString* localhash = [dataSet objectForKey:@"hash"];
         if(![resDataSetHash isEqualToString:localhash]){
           [self syncRecordsWithDataId:dataId];
         } else {
           [self syncCompleteWithStatus:@"online" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
         }
       } else {
         [self syncCompleteWithStatus:@"online" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
       }
      } AndFailure: ^(FHResponse* fhres){
        //the offline event may happen during the call, if it's the case, return complete with the offline message
        if (![FH isOnline]) {
          NSLog(@"FHSync failed because the device is offline during the call.");
          [self syncCompleteWithStatus:@"offline" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
        } else {
          NSLog(@"FHSync failed. Reponse: %@", [fhres rawResponseAsString]);
          [self syncCompleteWithStatus:[fhres rawResponseAsString] dataId:dataId code: SYNC_FAILED_MESSAGE];
        }
      }];
    }
  }
}

- (void) processDataWithDataId:(NSString*) dataId updates:(NSDictionary*) updates AndCode:(NSString*) code
{
  __block NSMutableDictionary* pendings = [[_dataSets objectForKey:dataId] objectForKey:@"pending"];
  [updates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop){
    [pendings removeObjectForKey:key];
    [self doNotifyWithDataId:dataId uid:(NSString*)[obj objectForKey:@"uid"] code:code message:[obj JSONString]];
  }];
}


- (void) syncRecordsWithDataId:(NSString*) dataId
{
  NSMutableDictionary* dataSet = [_dataSets objectForKey:dataId];
  if(dataSet){
    NSMutableDictionary* localdataset = [dataSet objectForKey:@"data"];
    __block NSMutableDictionary* recHash = [NSMutableDictionary dictionary];
    if(localdataset){
      [localdataset enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        if ([[obj class] isSubclassOfClass:[NSMutableDictionary class]] ) {
          [recHash setObject:[obj objectForKey:@"hash"] forKey:key];
        }
      }];
    }
    NSMutableDictionary* syncRecParams = [NSMutableDictionary dictionary];
    [syncRecParams setObject:@"syncRecords" forKey:@"fn"];
    [syncRecParams setObject:dataId forKey:@"dataset_id"];
    [syncRecParams setObject:[[dataSet objectForKey:@"config"] objectForKey:@"query_params" ] forKey:@"query_params"];
    [syncRecParams setObject:recHash forKey:@"clientRecs"];
    
    [FH performActRequest:dataId WithArgs:syncRecParams AndSuccess:^(FHResponse * fhres){
      NSLog(@"FHSyncRecords success response: %@", [[fhres parsedResponse] JSONString]);
      NSMutableDictionary* resData = [[fhres parsedResponse] mutableCopy];
      __block NSMutableDictionary* localdataset = [dataSet objectForKey:@"data"];
      if(!localdataset){
        localdataset = [NSMutableDictionary dictionary];
        [dataSet setObject:localdataset forKey:@"data"];
      }
      if([resData objectForKey:@"create"]){
        NSDictionary* createData = [resData objectForKey:@"create"];
        [createData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
          NSMutableDictionary* rec = [NSMutableDictionary dictionary];
          [rec setObject:[obj objectForKey:@"hash"] forKey:@"hash"];
          [rec setObject:[obj objectForKey:@"data"] forKey:@"data"];
          [localdataset setObject:rec forKey:key];
          [self doNotifyWithDataId:dataId uid:key code:DELTA_RECEIVED_MESSAGE message:@"create"];
        }];
      }
      if([resData objectForKey:@"update"]){
        NSDictionary* updateData = [resData objectForKey:@"update"];
        [updateData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
          NSMutableDictionary* rec = [[localdataset objectForKey:key] mutableCopy];
          if(rec){
            [rec setObject:[obj objectForKey:@"hash"] forKey:@"hash"];
            [rec setObject:[obj objectForKey:@"data"] forKey:@"data"];
            [localdataset setObject:rec forKey:key];
          }
          [self doNotifyWithDataId:dataId uid:key code:DELTA_RECEIVED_MESSAGE message:@"update"];
        }];
      }
      if([resData objectForKey:@"delete"]){
        NSDictionary* deleteData = [resData objectForKey:@"delete"];
        [deleteData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
          [localdataset removeObjectForKey:key];
          [self doNotifyWithDataId:dataId uid:key code:DELTA_RECEIVED_MESSAGE message:@"delete"];
        }];
      }
      if([resData objectForKey:@"hash"]){
        [localdataset setObject:[resData objectForKey:@"hash"] forKey:@"hash"];
      }
      [self syncCompleteWithStatus:@"online" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
    } AndFailure:^(FHResponse* fhres){
      if (![FH isOnline]) {
        NSLog(@"FhSyncRecords failed because the device is offline during the call.");
        [self syncCompleteWithStatus:@"offline" dataId:dataId code:SYNC_COMPLETE_MESSAGE];
      } else {
        NSLog(@"FhSyncRecords failed response: %@", [fhres rawResponseAsString]);
        [self syncCompleteWithStatus:[fhres rawResponseAsString] dataId:dataId code:SYNC_FAILED_MESSAGE];
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
- (void) syncCompleteWithStatus:(NSString*) status dataId:(NSString*) dataId code:(NSString*) code
{
  [self doNotifyWithDataId:dataId uid:nil code:code message:status];
  BOOL isMainThread = [NSThread isMainThread];
  if (isMainThread) {
    [self performSelectorInBackground:@selector(saveData) withObject:nil];
    [self scheduleNextRun:dataId];
  } else {
    [self performSelectorOnMainThread:@selector(scheduleNextRun:) withObject:dataId waitUntilDone:NO];
    [self saveData];
  }
}

- (void) scheduleNextRun:(NSString*) dataId
{
  NSString* keepRunning = [_runningTasks objectForKey:dataId];
  if ([keepRunning isEqualToString:@"YES"]) {
    [NSTimer scheduledTimerWithTimeInterval:[_syncConfig syncFrequency] target:self selector:@selector(startSyncTaskWithTimer:) userInfo:[NSDictionary dictionaryWithObject:dataId forKey:@"dataId"] repeats:NO];
    //NSLog(@"nstimer inited %d", [timer isValid]);
    NSLog(@"Task is not cancelled. Sleep for %f seconds and start syncing again", [_syncConfig syncFrequency]);
  } else {
    NSLog(@"Task has been cancelled with dataId %@. Stop syncing.", dataId);
    [_runningTasks removeObjectForKey:dataId];
  }

}

@end

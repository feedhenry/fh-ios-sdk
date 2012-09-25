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
#import "Reachability.h"
#import "FHSyncNotificationMessage.h"
#import <CommonCrypto/CommonDigest.h>
#import "FH.h"
#import "FHResponse.h"



#define STORAGE_FILE_PATH @".fh_sync.json"

@interface FHSyncClient()
{
  NSMutableDictionary * _dataSets;
  FHSyncConfig * _syncConfig;
  BOOL _initialized;
  BOOL _isOnline;
  Reachability* _reachability;
  NSMutableDictionary* _runningTasks;
}

@property (nonatomic, retain) NSMutableDictionary* dataSets;
@property (nonatomic, retain) FHSyncConfig* syncConfig;
@property (nonatomic, retain) NSMutableDictionary* runningTasks;
@property (nonatomic, retain) Reachability* reachability;
@end

@implementation FHSyncClient
@synthesize dataSets = _dataSets;
@synthesize syncConfig = _syncConfig;
@synthesize runningTasks = _runningTasks;
@synthesize reachability = _reachability;

static FHSyncClient* shared = nil;

- (id) initWithConfig:(FHSyncConfig*) config
{
  self = [super init];
  if(self){
    [self registerForNetworkReachabilityNotifications];
    _syncConfig = [config retain];
    _runningTasks = [[NSMutableDictionary dictionary] retain];
    NSString* storageFilePath = [self getStorageFilePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:storageFilePath];
    if (fileExists) {
      NSError* error = nil;
      NSString * fileContent = [NSString stringWithContentsOfFile:storageFilePath encoding:NSUTF8StringEncoding error:&error];
      if (error){
        NSLog(@"Failed to read file content from file : %@", storageFilePath );
        _dataSets = [[NSMutableDictionary alloc] init];
      } else {
        _dataSets = [[fileContent mutableObjectFromJSONString] retain];
      }
    } else {
      _dataSets = [[NSMutableDictionary alloc] init];
    }
    _initialized = YES;
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

- (void) registerForNetworkReachabilityNotifications
{
  _reachability = [Reachability reachabilityForInternetConnection];
  if([_reachability currentReachabilityStatus] == ReachableViaWiFi || [_reachability currentReachabilityStatus] == ReachableViaWWAN ){
    _isOnline = YES;
  } else {
    _isOnline = NO;
  }
  [_reachability startNotifier];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void) unregisterForNetworkReachabilityNotification
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if(_reachability){
    [_reachability stopNotifier];
  }
}

- (void) networkReachabilityChanged:(NSNotification *)note
{
  Reachability* reachable = (Reachability*) note;
  if([reachable currentReachabilityStatus] == ReachableViaWiFi || [reachable currentReachabilityStatus] == ReachableViaWWAN){
    _isOnline = YES;
  } else {
    _isOnline = NO;
  }
}

- (NSString*) getStorageFilePath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
  NSString *documentsDir = [paths objectAtIndex:0];
  if(![[NSFileManager defaultManager] fileExistsAtPath:documentsDir]){
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSString *storageFilePath = [documentsDir stringByAppendingPathComponent:STORAGE_FILE_PATH];
  return storageFilePath;
}

- (void) manageWithDataId:(NSString* ) dataId AndQuery:(NSDictionary* ) queryParams
{
  if(!_initialized){
    [NSException raise:@"FHSyncClient isn't initialized" format:@"FHSyncClient hasn't been initialized. Have you called the init function?"];
  }
  if(![_dataSets objectForKey:dataId]){
    NSMutableDictionary* dataSet = [NSMutableDictionary dictionary];
    [dataSet setObject:[NSMutableDictionary dictionary] forKey:@"pending"];
    NSMutableDictionary* dataSetConfig = [NSMutableDictionary dictionary];
    [dataSetConfig setObject:queryParams forKey:@"query_params"];
    [dataSet setObject:dataSetConfig forKey:@"config"];
    [_dataSets setObject:dataSet forKey:dataId];
  }
  [self syncLoopWithDataId:dataId];
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
    [self unregisterForNetworkReachabilityNotification];
    _reachability = nil;
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

- (NSDictionary*) readWidthDataId:(NSString *)dataId AndUID:(NSString *)uid
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

- (NSDictionary*) addPendingObjectWithDataId:(NSString*) dataId uid:(NSString*) uid data:(NSDictionary*) data AndAction:(NSString*) action
{
  if(!_isOnline){
    [self doNotifyWithDataId:dataId uid:uid code:OFFLINE_UPDATE_MESSAGE message:action];
  }
  NSDictionary* existingData = [self readWidthDataId:dataId AndUID:uid];
  NSMutableDictionary * pendingObj = [NSMutableDictionary dictionary];
  if(uid){
    [pendingObj setValue:uid forKey:@"uid"];
  }
  [pendingObj setValue:action forKey:@"action"];
  if(existingData){
    [pendingObj setObject:[existingData objectForKey:@"data"] forKey:@"pre"];
  }
  if(data){
    [pendingObj setObject:data forKey:@"post"];
  }
  NSString* hash = [self generateHashWithString:[pendingObj JSONString]];
  [pendingObj setValue:hash forKey:@"hash"];
  NSDate * now = [NSDate date];
  NSNumber *ts = [NSNumber numberWithDouble:[now timeIntervalSince1970] * 1000];
  [pendingObj setValue:ts  forKey:@"timestamp"];
  
  NSMutableDictionary * dataSet = [_dataSets objectForKey:dataId];
  if (dataSet) {
    [[dataSet objectForKey:@"pending"] setObject:pendingObj forKey:hash];
    [self saveData];
  }
  return pendingObj;
}

- (void) saveData
{
  @synchronized(self){
    NSString* dataToWrite = [_dataSets JSONString];
    NSString* filePath = [self getStorageFilePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
      [[NSFileManager defaultManager] createFileAtPath:filePath contents:[dataToWrite dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    } else {
      NSError* error = nil;
      [dataToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
      if(error){
        NSLog(@"Failed to write data to file at path %@ with error %@", filePath, error);
      }
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
  if(_syncConfig.notifyUpdateApplied && [code isEqualToString:UPDATE_APPLIED_MESSAGE]){
    doSend = YES;
  }
  if(_syncConfig.notifyUpdateFailed && [code isEqualToString:UPDATE_FAILED_MESSAGE]){
    doSend = YES;
  }
  if(doSend){
    FHSyncNotificationMessage * notification = [[FHSyncNotificationMessage alloc] initWithDataId:dataId AndUID:uid AndCode:code AndMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHSyncStateChangedNotification object:notification];
    [notification release];
  }
}

- (NSString*) generateHashWithString:(NSString*) text
{
  NSData * data = [text dataUsingEncoding:NSUTF8StringEncoding];
  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  
  CC_SHA1(data.bytes, data.length, digest);
  
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
  {
    [output appendFormat:@"%02x", digest[i]];
  }
  
  return output;}

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
  [self startSyncTaskWithDataId:dataId];
}

- (void) startSyncTaskWithDataId:(NSString*) dataId
{
  [self doNotifyWithDataId:dataId uid:nil code:SYNC_STARTED_MESSAGE message:nil];
  if(!_isOnline){
    [self syncCompleteWithStatus:@"offline" dataId:dataId];
  } else {
    NSMutableDictionary* dataSet = [_dataSets objectForKey:dataId];
    if(dataSet){
      NSMutableDictionary* params = [NSMutableDictionary dictionary];
      [params setValue:@"sync" forKey:@"fn"];
      [params setValue:dataId forKey:@"dataset_id"];
      [params setValue:[[dataSet objectForKey:@"config"] objectForKey:@"query_params"] forKey:@"query_params"];
      NSDictionary* pendings = [dataSet objectForKey:@"pending"];
      __block NSMutableArray* pendingArray = [NSMutableArray array];
      [pendings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [pendingArray addObject:obj];
      }];
      [params setValue:pendingArray forKey:@"pending"];
      [FH performActRequest:dataId WithArgs:params AndSuccess:^(FHResponse* fhres){
        NSLog(@"FHSync success response: %@", [[fhres parsedResponse] JSONString]);
        NSDictionary* resData = [fhres parsedResponse];
        if ([resData objectForKey:@"updates"]) {
          NSDictionary* updatesData = [resData objectForKey:@"updates"];
          if([updatesData objectForKey:@"applied"]){
            [self processDataWithDataId:dataId updates:[updatesData objectForKey:@"applied"] AndCode:UPDATE_APPLIED_MESSAGE];
          }
          if ([resData objectForKey:@"failed"]) {
            [self processDataWithDataId:dataId updates:[updatesData objectForKey:@"failed"] AndCode:UPDATE_FAILED_MESSAGE];
          }
          if([resData objectForKey:@"collisions"]) {
            [self processDataWithDataId:dataId updates:[updatesData objectForKey:@"collisions"] AndCode:COLLISION_DETECTED_MESSAGE];
          }
        }
       if([resData objectForKey:@"records"]){
         NSMutableDictionary * dataSet = [_dataSets objectForKey:dataId];
         [dataSet setObject:[resData objectForKey:@"records"] forKey:@"data"];
         [dataSet setObject:[resData objectForKey:@"hash"] forKey:@"hash"];
         [self doNotifyWithDataId:dataId uid:nil code:DELTA_RECEIVED_MESSAGE message:nil];
         [self syncCompleteWithStatus:@"online" dataId:dataId];
       } else if([resData objectForKey:@"hash"]){
         NSString* resDataSetHash = (NSString* )[resData objectForKey:@"hash"];
         NSMutableDictionary * dataSet = [_dataSets objectForKey:dataId];
         NSString* localhash = [dataSet objectForKey:@"hash"];
         if(![resDataSetHash isEqualToString:localhash]){
           [self syncRecordsWithDataId:dataId];
         } else {
           [self syncCompleteWithStatus:@"online" dataId:dataId];
         }
       } else {
         [self syncCompleteWithStatus:@"online" dataId:dataId];
       }
      } AndFailure: ^(FHResponse* fhres){
        NSLog(@"FHSync failed. Reponse: %@", [fhres rawResponseAsString]);
        [self syncCompleteWithStatus:[fhres rawResponseAsString] dataId:dataId];
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
    NSDictionary* localdataset = [dataSet objectForKey:@"data"];
    __block NSMutableDictionary* recHash = [NSMutableDictionary dictionary];
    if(localdataset){
      [localdataset enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        if ([obj class] == [NSDictionary class] ) {
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
      NSDictionary* resData = [fhres parsedResponse];
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
          NSMutableDictionary* rec = [localdataset objectForKey:key];
          if(rec){
            [rec setObject:[obj objectForKey:@"hash"] forKey:@"hash"];
            [rec setObject:[obj objectForKey:@"data"] forKey:@"data"];
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
      [self syncCompleteWithStatus:@"online" dataId:dataId];
    } AndFailure:^(FHResponse* fhres){
      NSLog(@"FhSyncRecords failed response: %@", [fhres rawResponseAsString]);
      [self syncCompleteWithStatus:[fhres rawResponseAsString] dataId:dataId];
    }];
  }
}

- (void) syncCompleteWithStatus:(NSString*) status dataId:(NSString*) dataId
{
  [self saveData];
  [self doNotifyWithDataId:dataId uid:nil code:SYNC_COMPLETE_MESSAGE message:status];
  NSString* keepRunning = [_runningTasks objectForKey:dataId];
  if ([keepRunning isEqualToString:@"YES"]) {
    NSLog(@"Task is not cancelled. Sleep for %f seconds and start syncing again", [_syncConfig syncFrequency]);
    [NSTimer scheduledTimerWithTimeInterval:[_syncConfig syncFrequency] target:self selector:@selector(startSyncTaskWithTimer:) userInfo:[NSDictionary dictionaryWithObject:dataId forKey:@"dataId"] repeats:NO];
  } else {
    NSLog(@"Task has been cancelled with dataId %@. Stop syncing.", dataId);
    [_runningTasks removeObjectForKey:dataId];
  }
}

- (void) dealloc
{
  _runningTasks = nil;
  [_runningTasks release];
  [_dataSets release];
  [super dealloc];
}
@end

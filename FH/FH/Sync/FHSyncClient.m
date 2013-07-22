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
#import "FHSyncPendingDataRecord.h"
#import "FHSyncDataRecord.h"
#import "FHSyncDataset.h"


@interface FHSyncClient()
{
  NSMutableDictionary * _dataSets;
  FHSyncConfig * _syncConfig;
  BOOL _initialized;
}

@property (nonatomic, retain) NSMutableDictionary* dataSets;
@property (nonatomic, copy) FHSyncConfig* syncConfig;
@end

@implementation FHSyncClient
@synthesize dataSets = _dataSets;
@synthesize syncConfig = _syncConfig;

static FHSyncClient* shared = nil;

- (id) initWithConfig:(FHSyncConfig*) config
{
  self = [super init];
  if(self){
    self.syncConfig = config;
    self.dataSets = [NSMutableDictionary dictionary];
    _initialized = YES;
    [self datasetMonitor:nil];
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

- (void) datasetMonitor:(NSDictionary*) info
{
  NSLog(@"start to run checkDataets");
  [self checkDatasets];
  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(datasetMonitor:) userInfo:nil repeats:NO];
}

- (void) checkDatasets
{
  if (nil != self.dataSets) {
    [self.dataSets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
      FHSyncDataset* dataset = (FHSyncDataset*) obj;
      BOOL syncRunning = dataset.syncRunning;
      if( !syncRunning && !dataset.stopSync){
        //sync isn't running for dataId at the moment, check if needs to start it
        NSDate* lastSyncStart = dataset.syncLoopStart;
        NSDate* lastSyncCmp = dataset.syncLoopEnd;
        if( nil == lastSyncStart){
          //sync never started
          dataset.syncLoopPending = YES;
        } else if(nil != lastSyncCmp){
          //otherwise check how long since the last sync has finished
          NSTimeInterval timeSinceLastSync = [[NSDate date] timeIntervalSinceDate:lastSyncCmp];
          FHSyncConfig* dataSyncConfig = dataset.syncConfig;
          if(timeSinceLastSync > dataSyncConfig.syncFrequency){
            dataset.syncLoopPending = YES;
          }
        }
        if(dataset.syncLoopPending){
          //NSLog(@"start to run syncLoopWithDataId %@", key);
          [dataset startSyncLoop];
        }
      }
    }];
  }
}


- (void) manageWithDataId:(NSString* ) dataId AndConfig:(FHSyncConfig *)config AndQuery:(NSDictionary *)queryParams
{
  if(!_initialized){
    [NSException raise:@"FHSyncClient isn't initialized" format:@"FHSyncClient hasn't been initialized. Have you called the init function?"];
  }
  
  //first, check if the dataset for dataId is already loaded
  FHSyncDataset* dataSet = [_dataSets objectForKey:dataId];
  //allow to set sync config options for each dataset
  FHSyncConfig* dataSyncConfig = _syncConfig;
  if (nil != config) {
    dataSyncConfig = config;
  }
  if(nil == dataSet){
    //not loaded yet, try to read it from a local file
    NSError* error = nil;
    dataSet = [[FHSyncDataset alloc] initFromFileWithDataId:dataId error:error];
    if (nil == error) {
      //data loaded successfully
      [FHSyncUtils doNotifyWithDataId:dataId config:dataSyncConfig uid:NULL code:LOCAL_UPDATE_APPLIED_MESSAGE message:@"load"];
    } else {
      //cat not load data, create a new map for it
      dataSet = [[FHSyncDataset alloc] initWithDataId:dataId];
    }
    [_dataSets setObject:dataSet forKey:dataId];
  }
  
  dataSet.syncConfig = dataSyncConfig;
  
  //if the dataset is not initialised yet, do the init
  dataSet.queryParams = queryParams;
  dataSet.syncRunning = NO;
  dataSet.syncLoopPending = YES;
  dataSet.stopSync = NO;
  dataSet.initialised = YES;
  
  NSError* saveError = nil;
  [dataSet saveToFile:saveError];
  if (saveError) {
    NSLog(@"Failed to save dataset with dataId %@", dataId);
  }
}

- (void) stopWithDataId:(NSString*) dataId
{
  FHSyncDataset* dataset = [self.dataSets objectForKey:dataId];
  if (dataset) {
    dataset.stopSync = YES;
  }
}

- (void) destroy
{
  if (_initialized){
    [_dataSets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
      FHSyncDataset* dataset = (FHSyncDataset*) obj;
      dataset.stopSync = YES;
    }];
    _dataSets = nil;
    _syncConfig = nil;
    _initialized = NO;
  }
}

- (NSDictionary *) listWithDataId:(NSString *)dataId
{
  FHSyncDataset* dataSet = [_dataSets objectForKey:dataId];
  if(dataSet){
    return [dataSet listData];
  }
  return nil;
}

- (NSDictionary*) readWithDataId:(NSString *)dataId AndUID:(NSString *)uid
{
  FHSyncDataset* dataSet = [_dataSets objectForKey:dataId];
  if(dataSet){
    return [dataSet readDataWithUID:uid];
  }
  return nil;
}

- (BOOL) createWithDataId:(NSString *)dataId AndData:(NSDictionary *)data
{
  FHSyncDataset* dataSet = [_dataSets objectForKey:dataId];
  if(dataSet){
    return [dataSet createWithData:data];
  }
  return nil;
}

- (BOOL) updateWithDataId:(NSString *)dataId AndUID:(NSString *)uid AndData:(NSDictionary *)data
{
  FHSyncDataset* dataSet = [_dataSets objectForKey:dataId];
  if(dataSet){
    return [dataSet updateWithUID:uid data:data];
  }
  return nil;
}

- (BOOL) deleteWithDataId:(NSString *)dataId AndUID:(NSString *)uid
{
  FHSyncDataset* dataSet = [_dataSets objectForKey:dataId];
  if(dataSet){
    return [dataSet deleteWithUID:uid];
  }
  return nil;
}

@end

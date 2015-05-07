//
//  FHSyncDataset.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncDataset.h"
#import "FHSyncUtils.h"
#import "FHJSON.h"
#import "FHSyncPendingDataRecord.h"
#import "FHSyncDataRecord.h"
#import "FH.h"
#import "FHDefines.h"
#import "FHSyncNotificationMessage.h"
#import "FHResponse.h"

static NSString *const kStorageFilePath = @"sync.json";

static NSString *const kDataSetId = @"dataSetId";
static NSString *const kSyncLoopStart = @"syncLoopStart";
static NSString *const kSyncLoopEnd = @"syncLoopEnd";
static NSString *const kSyncConfig = @"syncConfig";
static NSString *const kPendingRecords = @"pendingDataRecords";
static NSString *const kDataRecords = @"dataRecords";
static NSString *const kHashValue = @"hashValue";
static NSString *const kAck = @"acknowledgements";

@implementation FHSyncDataset

- (id)initWithDataId:(NSString *)dataId {
    self = [super init];
    if (self) {
        self.syncRunning = NO;
        self.datasetId = dataId;
        self.syncLoopStart = nil;
        self.syncLoopEnd = nil;
        self.syncLoopPending = YES;
        self.syncConfig = nil;
        self.pendingDataRecords = [NSMutableDictionary dictionary];
        self.dataRecords = [NSMutableDictionary dictionary];
        self.queryParams = [NSMutableDictionary dictionary];
        self.metaData = [NSMutableDictionary dictionary];
        self.hashValue = nil;
        self.initialised = NO;
        self.acknowledgements = [NSMutableArray array];
        self.stopSync = NO;
    }
    return self;
}

- (id)initFromFileWithDataId:(NSString *)dataId error:(NSError *)error {
    NSString *data =
        [FHSyncUtils loadDataFromFile:[dataId stringByAppendingPathExtension:kStorageFilePath]
                                error:error];
    if (nil != data) {
        return [FHSyncDataset objectFromJSONString:data];
    } else {
        return [[FHSyncDataset alloc] initWithDataId:dataId];
    }
}

- (NSDictionary *)JSONData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kDataSetId] = self.datasetId;
    dict[kSyncConfig] = [self.syncConfig JSONData];
    NSMutableDictionary *pendingDataDict = [NSMutableDictionary dictionary];
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        pendingDataDict[key] = [obj JSONData];
    }];
    dict[kPendingRecords] = pendingDataDict;
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [self.dataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        dataDict[key] = [obj JSONData];
    }];
    dict[kDataRecords] = dataDict;

    if (nil != self.syncLoopStart) {
        dict[kSyncLoopStart] = @([self.syncLoopStart timeIntervalSince1970]);
    }
    if (nil != self.syncLoopEnd) {
        dict[kSyncLoopEnd] = @([self.syncLoopEnd timeIntervalSince1970]);
    }
    dict[kAck] = self.acknowledgements;
    return dict;
}

/** Serialize this object to JSON string **/
- (NSString *)JSONString {
    NSDictionary *dict = [self JSONData];
    return [dict JSONString];
}

- (void)saveToFile:(NSError *)error {
    NSString *jsonStr = [self JSONString];
    // DLog(@"content = %@", jsonStr);
    @synchronized(self) {
        [FHSyncUtils saveData:jsonStr
                       toFile:[self.datasetId stringByAppendingPathExtension:kStorageFilePath]
                       backup:self.syncConfig.icloud_backup
                        error:error];
        if (nil != error) {
            [FHSyncUtils doNotifyWithDataId:self.datasetId
                                     config:self.syncConfig
                                        uid:NULL
                                       code:CLIENT_STORAGE_FAILED_MESSAGE
                                    message:[error localizedDescription]];
        }
    }
}

- (void)saveToFileAndNofiyComplete:(NSDictionary *)info {
    NSError *error = nil;
    [self saveToFile:error];
    NSString *message = info[@"message"];
    [FHSyncUtils doNotifyWithDataId:self.datasetId
                             config:self.syncConfig
                                uid:self.hashValue
                               code:SYNC_COMPLETE_MESSAGE
                            message:message];
}

+ (FHSyncDataset *)objectFromJSONData:(NSDictionary *)jsonObj {
    FHSyncDataset *instance = [[FHSyncDataset alloc] init];
    instance.datasetId = jsonObj[kDataSetId];
    instance.syncConfig = [FHSyncConfig objectFromJSONData:jsonObj[kSyncConfig]];
    instance.hashValue = jsonObj[kHashValue];
    instance.pendingDataRecords = [NSMutableDictionary dictionary];
    NSDictionary *pendingJson = jsonObj[kPendingRecords];
    if (nil != pendingJson) {
        [pendingJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            (instance.pendingDataRecords)[key] = [FHSyncPendingDataRecord objectFromJSONData:obj];
        }];
    }
    instance.dataRecords = [NSMutableDictionary dictionary];
    NSDictionary *dataJson = jsonObj[kDataRecords];
    if (nil != dataJson) {
        [dataJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            (instance.dataRecords)[key] = [FHSyncDataRecord objectFromJSONData:obj];
        }];
    }
    if (jsonObj[kSyncLoopStart]) {
        instance.syncLoopStart =
            [NSDate dateWithTimeIntervalSince1970:[jsonObj[kSyncLoopStart] doubleValue]];
    }
    if (jsonObj[kSyncLoopEnd]) {
        instance.syncLoopEnd =
            [NSDate dateWithTimeIntervalSince1970:[jsonObj[kSyncLoopEnd] doubleValue]];
    }
    if (jsonObj[kAck]) {
        instance.acknowledgements = jsonObj[kAck];
    }
    instance.initialised = YES;
    return instance;
}

+ (FHSyncDataset *)objectFromJSONString:(NSString *)jsonStr {
    NSDictionary *jsonObj = [jsonStr objectFromJSONString];
    return [FHSyncDataset objectFromJSONData:jsonObj];
}

- (NSString *)description {
    return [self JSONString];
}

- (NSDictionary *)listData {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (self.dataRecords) {
        [self.dataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncDataRecord *record = (FHSyncDataRecord *)obj;
            NSMutableDictionary *ret = [NSMutableDictionary dictionary];
            ret[@"data"] = record.data;
            ret[@"uid"] = key;
            data[key] = ret;
        }];
    }
    return data;
}

- (NSDictionary *)readDataWithUID:(NSString *)uid {
    FHSyncDataRecord *record = (self.dataRecords)[uid];
    if (record) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@"data"] = record.data;
        ret[@"uid"] = uid;
        return ret;
    } else {
        return nil;
    }
}

- (NSDictionary *)createWithData:(NSDictionary *)data {
    FHSyncPendingDataRecord *pending = [self addPendingObject:nil data:data AndAction:@"create"];
    FHSyncDataRecord *rec = (self.dataRecords)[pending.uid];
    if (rec) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@"data"] = rec.data;
        ret[@"uid"] = pending.uid;
        return ret;
    } else {
        return nil;
    }
}

- (NSDictionary *)updateWithUID:(NSString *)uid data:(NSDictionary *)data {
    [self addPendingObject:uid data:data AndAction:@"update"];

    FHSyncDataRecord *rec = (self.dataRecords)[uid];
    if (rec) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@"data"] = rec.data;
        ret[@"uid"] = uid;
        return ret;
    } else {
        return nil;
    }
}

- (NSDictionary *)deleteWithUID:(NSString *)uid {
    FHSyncPendingDataRecord *pending = [self addPendingObject:uid data:NULL AndAction:@"delete"];
    FHSyncDataRecord *deleted = pending.preData;
    if (deleted) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@"data"] = deleted.data;
        ret[@"uid"] = uid;
        return ret;
    } else {
        return nil;
    }
}

- (FHSyncPendingDataRecord *)addPendingObject:(NSString *)uid
                                         data:(NSDictionary *)data
                                    AndAction:(NSString *)action {
    if (![FH isOnline]) {
        [FHSyncUtils doNotifyWithDataId:self.datasetId
                                 config:self.syncConfig
                                    uid:uid
                                   code:OFFLINE_UPDATE_MESSAGE
                                message:action];
    }
    FHSyncPendingDataRecord *pendingObj = [[FHSyncPendingDataRecord alloc] init];
    pendingObj.inFlight = NO;
    pendingObj.action = action;

    if (data) {
        FHSyncDataRecord *postdata = [[FHSyncDataRecord alloc] initWithData:data];
        pendingObj.postData = postdata;
    }

    if ([action isEqualToString:@"create"]) {
        pendingObj.uid = pendingObj.postData.hashValue;
        [self storePendingObj:pendingObj];
    } else {
        FHSyncDataRecord *existingData = (self.dataRecords)[uid];
        if (nil != existingData) {
            pendingObj.uid = uid;
            pendingObj.preData = [existingData copy];
            [self storePendingObj:pendingObj];
        }
    }
    return pendingObj;
}

- (void)storePendingObj:(FHSyncPendingDataRecord *)obj {
    (self.pendingDataRecords)[obj.hashValue] = obj;
    [self updateDatasetFromLocal:obj];
    if (self.syncConfig.autoSyncLocalUpdates) {
        self.syncLoopPending = YES;
    }
    [self saveToFile:nil];
    [FHSyncUtils doNotifyWithDataId:self.datasetId
                             config:self.syncConfig
                                uid:obj.uid
                               code:LOCAL_UPDATE_APPLIED_MESSAGE
                            message:obj.action];
}

- (void)updateDatasetFromLocal:(FHSyncPendingDataRecord *)pendingObj {
    NSString *previousePendingUID = nil;
    FHSyncPendingDataRecord *previousePendingObj = nil;
    NSString *uid = pendingObj.uid;
    DLog(@"updating local dataset for uid %@ - action = %@", uid, pendingObj.action);
    NSMutableDictionary *metadata = (self.metaData)[uid];
    if (nil == metadata) {
        metadata = [NSMutableDictionary dictionary];
        (self.metaData)[uid] = metadata;
    }

    FHSyncDataRecord *existing = (self.dataRecords)[uid];
    id fromPending = metadata[@"fromPending"];

    if ([pendingObj.action isEqualToString:@"create"]) {
        if (nil != existing) {
            DLog(@"dataset already exists for uid for create :: %@", existing);
            if (fromPending && [fromPending boolValue]) {
                // We are trying to create on top of an existing pending record
                // Remove the previous pending record and use this one instead
                previousePendingUID = metadata[@"pendingUid"];
                [self.pendingDataRecords removeObjectForKey:previousePendingUID];
            }
        }
        (self.dataRecords)[uid] = [[FHSyncDataRecord alloc] init];
    }

    if ([pendingObj.action isEqualToString:@"update"]) {
        if (nil != existing) {
            if (fromPending && [fromPending boolValue]) {
                DLog(@"updating an existing pending record for dataset :: %@", existing);
                // We are trying to update an existing pending record
                previousePendingUID = metadata[@"pendingUid"];
                metadata[@"previousPendingUid"] = previousePendingUID;
                previousePendingObj = (self.pendingDataRecords)[previousePendingUID];
                if (nil != previousePendingObj && !previousePendingObj.inFlight) {
                    DLog(@"existing pre-flight pending record = %@", previousePendingObj);
                    // We are trying to perform an update on an existing pending record
                    // modify the original record to have the latest value and delete the pending
                    // update
                    previousePendingObj.postData = pendingObj.postData;
                    [self.pendingDataRecords removeObjectForKey:pendingObj.hashValue];
                }
            }
        }
    }

    if ([pendingObj.action isEqualToString:@"delete"]) {
        if (nil != existing) {
            if (fromPending && [fromPending boolValue]) {
                DLog(@"Deleting an existing pending record for dataset :: %@", existing);
                // We are trying to delete an existing pending record
                previousePendingUID = metadata[@"pendingUid"];
                metadata[@"previousPendingUid"] = previousePendingUID;
                previousePendingObj = (self.pendingDataRecords)[previousePendingUID];
                if (previousePendingObj && !previousePendingObj.inFlight) {
                    DLog(@"existing pending record = %@", previousePendingObj);
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

    if ((self.dataRecords)[uid]) {
        FHSyncDataRecord *record = pendingObj.postData;
        (self.dataRecords)[uid] = record;
        metadata[@"fromPending"] = @YES;
        metadata[@"pendingUid"] = pendingObj.hashValue;
    }
}

- (void)startSyncLoop {
    [self performSelectorInBackground:@selector(startSyncTask:) withObject:nil];
}

- (void)startSyncTask:(NSDictionary *)info {
    self.syncLoopPending = NO;
    self.syncRunning = YES;
    self.syncLoopStart = [NSDate date];
    [FHSyncUtils doNotifyWithDataId:self.datasetId
                             config:self.syncConfig
                                uid:NULL
                               code:SYNC_STARTED_MESSAGE
                            message:NULL];
    if (![FH isOnline]) {
        [self syncCompleteWithCode:@"offline"];
    } else {
        NSMutableDictionary *syncLoopParams = [NSMutableDictionary dictionary];
        syncLoopParams[@"fn"] = @"sync";
        syncLoopParams[@"dataset_id"] = self.datasetId;
        syncLoopParams[@"query_params"] = self.queryParams;
        if (self.hashValue) {
            syncLoopParams[@"dataset_hash"] = self.hashValue;
        }
        syncLoopParams[@"acknowledgements"] = self.acknowledgements;

        NSMutableArray *pendingArray = [NSMutableArray array];
        [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
            if (!pendingRecord.inFlight && !pendingRecord.crashed) {
                pendingRecord.inFlight = YES;
                pendingRecord.inFlightDate = [NSDate date];
                NSMutableDictionary *pendingJSON = [pendingRecord JSONData];
                pendingJSON[@"hash"] = pendingRecord.hashValue;
                [pendingArray addObject:pendingJSON];
            }
        }];

        syncLoopParams[@"pending"] = pendingArray;
        if ([pendingArray count] > 0) {
            DLog(@"Starting sync loop - global hash = %@ :: params = %@", self.hashValue,
                  syncLoopParams);
        }

        @try {
            [self doCloudCall:syncLoopParams
                AndSuccess:^(FHResponse *response) {

                    NSMutableDictionary *resData = [[response parsedResponse] mutableCopy];
                    if (resData[@"records"]) {
                        NSMutableDictionary *recordsCopy = [resData[@"records"] mutableCopy];
                        resData[@"records"] = recordsCopy;
                    }
                    [self syncRequestSuccess:resData];

                }
                AndFailure:^(FHResponse *response) {
                    // The AJAX call failed to complete succesfully, so the state of the current
                    // pending updates is unknown
                    // Mark them as "crashed". The next time a syncLoop completets successfully, we
                    // will review the crashed
                    // records to see if we can determine their current state.
                    [self markInFlightAsCrashed];
                    DLog(@"syncLoop failed : msg = %@", [[response parsedResponse] JSONString]);
                    [FHSyncUtils doNotifyWithDataId:self.datasetId
                                             config:self.syncConfig
                                                uid:NULL
                                               code:SYNC_FAILED_MESSAGE
                                            message:[[response parsedResponse] JSONString]];
                    [self syncCompleteWithCode:[[response parsedResponse] JSONString]];
                }];
        }
        @catch (NSException *ex) {
            DLog(@"Error performing sync - %@", ex);
            [FHSyncUtils doNotifyWithDataId:self.datasetId
                                     config:self.syncConfig
                                        uid:NULL
                                       code:SYNC_FAILED_MESSAGE
                                    message:[ex description]];
            [self syncCompleteWithCode:ex.reason];
        }
    }
}

- (void)doCloudCall:(NSMutableDictionary *)params
         AndSuccess:(void (^)(FHResponse *success))sucornil
         AndFailure:(void (^)(FHResponse *failed))failornil {
    if (self.syncConfig.hasCustomSync) {
        [FH performActRequest:self.datasetId
                     WithArgs:params
                   AndSuccess:sucornil
                   AndFailure:failornil];
    } else {
        NSString *path = [NSString stringWithFormat:@"/mbaas/sync/%@", self.datasetId];
        [FH performCloudRequest:path
                     WithMethod:@"POST"
                     AndHeaders:nil
                        AndArgs:params
                     AndSuccess:sucornil
                     AndFailure:failornil];
    }
}

- (void)syncRequestSuccess:(NSMutableDictionary *)resData {
    // Check to see if any new pending records need to be updated to reflect the current state of
    // play.
    [self updatePendingFromNewData:resData];

    // Check to see if any previously crashed inflight records can now be resolved
    [self updateCrashedInFlightFromNewData:resData];

    // Update the new dataset with details of any inflight updates which we have not received a
    // response on
    [self updateNewDataFromInFlight:resData];

    // Update the new dataset with details of any pending updates
    [self updateNewDataFromPending:resData];

    BOOL hasRecords = NO;
    if (resData[@"records"]) {
        // Full Dataset returned
        hasRecords = YES;
        [self resetDataRecords:resData];
    }

    if (resData[@"updates"]) {
        NSMutableArray *ack = [NSMutableArray array];
        NSDictionary *updates = resData[@"updates"];
        [self processUpdates:updates[@"applied"]
                notification:REMOTE_UPDATE_APPLIED_MESSAGE
            acknowledgements:ack];
        [self processUpdates:updates[@"failed"]
                notification:REMOTE_UPDATE_FAILED_MESSAGE
            acknowledgements:ack];
        [self processUpdates:updates[@"collisions"]
                notification:COLLISION_DETECTED_MESSAGE
            acknowledgements:ack];
        self.acknowledgements = ack;
    }

    if (!hasRecords && resData[@"hash"] && ![resData[@"hash"] isEqualToString:self.hashValue]) {
        NSString *remoteHash = resData[@"hash"];
        DLog(@"Local dataset stale - syncing records :: local hash= %@ - remoteHash = %@",
              self.hashValue, remoteHash);
        // Different hash value returned - Sync individual records
        [self syncRecords];
    } else {
        DLog(@"Local dataset up to date");
    }

    [self syncCompleteWithCode:@"online"];
}

- (void)syncRecords {
    NSMutableDictionary *clientRecs = [NSMutableDictionary dictionary];
    [self.dataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *uid = (NSString *)key;
        NSString *hash = [(FHSyncDataRecord *)obj hashValue];
        clientRecs[uid] = hash;
    }];

    NSMutableDictionary *syncRecsParams = [NSMutableDictionary dictionary];
    syncRecsParams[@"fn"] = @"syncRecords";
    syncRecsParams[@"dataset_id"] = self.datasetId;
    syncRecsParams[@"query_params"] = self.queryParams;
    syncRecsParams[@"clientRecs"] = clientRecs;

    DLog(@"syncRecParams :: %@", [syncRecsParams JSONString]);

    [self doCloudCall:syncRecsParams
        AndSuccess:^(FHResponse *response) {
            [self syncRecordsSuccess:[response parsedResponse]];
        }
        AndFailure:^(FHResponse *response) {
            DLog(@"syncRecords failed : %@", [[response parsedResponse] JSONString]);
            [FHSyncUtils doNotifyWithDataId:self.datasetId
                                     config:self.syncConfig
                                        uid:NULL
                                       code:SYNC_FAILED_MESSAGE
                                    message:[[response parsedResponse] JSONString]];
            [self syncCompleteWithCode:[[response parsedResponse] JSONString]];
        }];
}

- (void)syncRecordsSuccess:(NSDictionary *)resData {
    NSDictionary *dataCreated = resData[@"create"];
    if (nil != dataCreated) {
        [dataCreated enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncDataRecord *rec = [[FHSyncDataRecord alloc] initWithData:obj[@"data"]];
            rec.hashValue = obj[@"hash"];
            (self.dataRecords)[key] = rec;
            [FHSyncUtils doNotifyWithDataId:self.datasetId
                                     config:self.syncConfig
                                        uid:key
                                       code:DELTA_RECEIVED_MESSAGE
                                    message:@"create"];
        }];
    }

    NSDictionary *dataUpdated = resData[@"update"];
    if (nil != dataUpdated) {
        [dataUpdated enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncDataRecord *rec = (self.dataRecords)[key];
            if (rec) {
                rec.data = obj[@"data"];
                rec.hashValue = obj[@"hash"];
                (self.dataRecords)[key] = rec;
                [FHSyncUtils doNotifyWithDataId:self.datasetId
                                         config:self.syncConfig
                                            uid:key
                                           code:DELTA_RECEIVED_MESSAGE
                                        message:@"update"];
            }
        }];
    }

    NSDictionary *deleted = resData[@"delete"];
    if (nil != deleted) {
        [deleted enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.dataRecords removeObjectForKey:key];
            [FHSyncUtils doNotifyWithDataId:self.datasetId
                                     config:self.syncConfig
                                        uid:key
                                       code:DELTA_RECEIVED_MESSAGE
                                    message:@"delete"];
        }];
    }

    if (resData[@"hash"]) {
        self.hashValue = resData[@"hash"];
    }
    [self syncCompleteWithCode:@"online"];
}

- (void)resetDataRecords:(NSDictionary *)resData {
    NSDictionary *records = resData[@"records"];
    NSMutableDictionary *allRecords = [NSMutableDictionary dictionary];
    [records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *data = (NSDictionary *)obj;
        FHSyncDataRecord *record = [[FHSyncDataRecord alloc] initWithData:data];
        allRecords[key] = record;
    }];

    self.dataRecords = allRecords;
    self.hashValue = resData[@"hash"];
    [FHSyncUtils doNotifyWithDataId:self.datasetId
                             config:self.syncConfig
                                uid:self.hashValue
                               code:DELTA_RECEIVED_MESSAGE
                            message:@"full dataset"];
}

- (void)processUpdates:(NSDictionary *)updates
          notification:(NSString *)notifcation
      acknowledgements:(NSMutableArray *)acknowledgements {
    if (nil != updates) {
        [updates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *up = (NSDictionary *)obj;
            NSString *keyVal = (NSString *)key;
            [acknowledgements addObject:up];
            FHSyncPendingDataRecord *pendingRec = (self.pendingDataRecords)[keyVal];
            if ((nil != pendingRec) && pendingRec.inFlight && !pendingRec.crashed) {
                [self.pendingDataRecords removeObjectForKey:keyVal];
                [FHSyncUtils doNotifyWithDataId:self.datasetId
                                         config:self.syncConfig
                                            uid:up[@"uid"]
                                           code:notifcation
                                        message:[up JSONString]];
            }
        }];
    }
}

/*
 FH will run all the callbacks on the main thread. Because this syncCompleteWithStatus function is
 called mostly from the callback functions,
 if the device is online, the function will be executed on the main thread and it may bloack the UI
 when saving large data.
 However, if the device is offline, this function may get called from the background thread. But the
 background thread could be kill by the os
 as soon as the function finishes, the NSTimer instance will not be executed.

 So, we always put the NSTimer instance on the main thread, which means the startSyncTaskWithTimer
 will be called from the main thread.Then in that
 function we invoke the sync task on a background thread and we always do the data saving on the
 background thread.
 */
- (void)syncCompleteWithCode:(NSString *)code {
    self.syncRunning = NO;
    self.syncLoopEnd = [NSDate date];
    BOOL isMainThread = [NSThread isMainThread];
    if (isMainThread) {
        [self performSelectorInBackground:@selector(saveToFileAndNofiyComplete:)
                               withObject:@{
                                   @"message" : code
                               }];
    } else {
        [self saveToFileAndNofiyComplete:@{ @"message" : code }];
    }
}

- (void)updatePendingFromNewData:(NSDictionary *)remoteData {
    if (self.pendingDataRecords && remoteData[@"records"]) {
        [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
            NSMutableDictionary *metadata = (self.metaData)[pendingRecord.uid];
            if (nil == metadata) {
                metadata = [NSMutableDictionary dictionary];
                (self.metaData)[pendingRecord.uid] = metadata;
            }
            if (!pendingRecord.inFlight) {
                // Pending record that has not been submitted
                DLog(@"updatePendingFromNewData - Found Non inFlight record -> action = %@ :: uid "
                      @"= %@ :: hash = %@",
                      pendingRecord.action, pendingRecord.uid, pendingRecord.hashValue);
                if ([pendingRecord.action isEqualToString:@"update"] ||
                    [pendingRecord.action isEqualToString:@"delete"]) {
                    // Update the pre value of pending record to reflect the latest data returned
                    // from sync.
                    NSDictionary *remoteRec = remoteData[@"records"][pendingRecord.uid];
                    if (nil != remoteRec) {
                        DLog(@"updatePendingFromNewData - updating pre values for existing "
                              @"pending record %@",
                              pendingRecord.uid);
                        FHSyncDataRecord *rec = [[FHSyncDataRecord alloc] initWithData:remoteRec];
                        pendingRecord.preData = rec;
                    } else {
                        // The update/delete may be for a newly created record in which case the uid
                        // will be changed.
                        NSString *previousPendingUid = metadata[@"previousPendingUid"];
                        FHSyncPendingDataRecord *previousPendingRec =
                            (self.pendingDataRecords)[previousPendingUid];
                        if (nil != previousPendingRec) {
                            if (nil != remoteData && remoteData[@"updates"]) {
                                NSDictionary *updates = remoteData[@"updates"];
                                if (updates[@"applied"] &&
                                    updates[@"applied"][previousPendingRec.hashValue]) {
                                    // There is an update in from a previous pending action
                                    NSString *remoteUid =
                                        updates[@"applied"][previousPendingRec.hashValue][
                                            @"uid"]; // dictionary...:(
                                    if (nil != remoteUid) {
                                        remoteRec = remoteData[@"records"][remoteUid];
                                        if (remoteRec) {
                                            DLog(@"updatePendingFromNewData - Updating pre values "
                                                  @"for existing pending record which was "
                                                  @"previously a create %@ ==> %@",
                                                  pendingRecord.uid, remoteUid);
                                            FHSyncDataRecord *record =
                                                [[FHSyncDataRecord alloc] initWithData:remoteRec];
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

            NSString *pendingHash = (NSString *)key;
            if ([pendingRecord.action isEqualToString:@"create"]) {
                if (nil != remoteData && remoteData[@"updates"]) {
                    NSDictionary *updates = remoteData[@"updates"];
                    if (updates[@"applied"] && updates[@"applied"][pendingHash]) {
                        NSDictionary *appliedData = updates[@"applied"][pendingHash];
                        DLog(@"updatePendingFromNewData - Found an update for a pending create %@",
                              appliedData);
                        NSDictionary *remoteRec = remoteData[appliedData[@"uid"]];
                        if (nil != remoteRec) {
                            DLog(@"updatePendingFromNewData - Changing pending create to an "
                                  @"update based on new record %@",
                                  remoteRec);

                            // Set up the pending as an update
                            pendingRecord.action = @"update";
                            FHSyncDataRecord *preData =
                                [[FHSyncDataRecord alloc] initWithData:remoteRec];
                            pendingRecord.preData = preData;
                            pendingRecord.uid = appliedData[@"uid"];
                        }
                    }
                }
            }
        }];
    }
}

- (void)updateCrashedInFlightFromNewData:(NSDictionary *)remoteData {
    NSDictionary *updateNotifications = @{
        @"applied" : REMOTE_UPDATE_APPLIED_MESSAGE,
        @"failed" : REMOTE_UPDATE_FAILED_MESSAGE,
        @"collisions" : COLLISION_DETECTED_MESSAGE
    };
    NSMutableDictionary *resolvedCrashed = [NSMutableDictionary dictionary];
    NSMutableArray *keysToRemove = [NSMutableArray array];

    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
        NSString *pendingHash = (NSString *)key;
        if (pendingRecord.inFlight && pendingRecord.crashed) {
            DLog(@"updateCrashedInFlightFromNewData - Found crashed inFlight pending record uid= "
                  @"%@ :: hash= %@",
                  pendingRecord.uid, pendingRecord.hashValue);
            if (remoteData && remoteData[@"updates"] && remoteData[@"updates"][@"hashes"]) {
                NSDictionary *hashes = remoteData[@"updates"][@"hashes"];
                // check if the updates received contain any info about the crashed inflight update
                NSDictionary *crashedUpdate = hashes[pendingHash];
                if (nil != crashedUpdate) {
                    resolvedCrashed[crashedUpdate[@"uid"]] = crashedUpdate;
                    DLog(@"updateCrashedInFlightFromNewData - Resolving status for crashed "
                          @"inflight pending record %@",
                          crashedUpdate);
                    NSString *crashedType = crashedUpdate[@"type"];
                    NSString *crashedAction = crashedUpdate[@"action"];
                    if (nil != crashedType && [crashedType isEqualToString:@"failed"]) {
                        // Crashed updated failed - revert local dataset
                        if (crashedAction && [crashedAction isEqualToString:@"create"]) {
                            DLog(@"updateCrashedInFlightFromNewData - Deleting failed create from "
                                  @"dataset");
                            [self.dataRecords removeObjectForKey:crashedUpdate[@"uid"]];
                        } else if (crashedAction && ([crashedAction isEqualToString:@"update"] ||
                                                     [crashedAction isEqualToString:@"delete"])) {
                            DLog(@"updateCrashedInFlightFromNewData - Reverting failed %@ in "
                                  @"dataset",
                                  crashedAction);
                            (self.dataRecords)[crashedUpdate[@"uid"]] = pendingRecord.preData;
                        }
                    }
                    [keysToRemove addObject:pendingHash];
                    [FHSyncUtils doNotifyWithDataId:self.datasetId
                                             config:self.syncConfig
                                                uid:crashedUpdate[@"uid"]
                                               code:updateNotifications[crashedUpdate[@"type"]]
                                            message:[crashedUpdate JSONString]];
                } else {
                    // No word on our crashed update - increment a counter to reflect another sync
                    // that did not give us
                    // any update on our crashed record.
                    pendingRecord.crashedCount++;
                }
            } else {
                // No word on our crashed update - increment a counter to reflect another sync that
                // did not give us
                // any update on our crashed record.
                pendingRecord.crashedCount++;
            }
        }
    }];

    [self.pendingDataRecords removeObjectsForKeys:keysToRemove];
    [keysToRemove removeAllObjects];

    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
        NSString *pendingHash = (NSString *)key;

        if (pendingRecord.inFlight && pendingRecord.crashed) {
            if (pendingRecord.crashedCount > self.syncConfig.crashCountWait) {
                DLog(@"updateCrashedInFlightFromNewData - Crashed inflight pending record has "
                      @"reached crashed_count_wait limit : '%@",
                      pendingRecord);
                if (self.syncConfig.resendCrashedUpdates) {
                    DLog(@"updateCrashedInFlightFromNewData - Retryig crashed inflight pending "
                          @"record");
                    pendingRecord.crashed = NO;
                    pendingRecord.inFlight = NO;
                } else {
                    DLog(@"updateCrashedInFlightFromNewData - Deleting crashed inflight pending "
                          @"record");
                    [keysToRemove addObject:pendingHash];
                }
            }
        } else if (!pendingRecord.inFlight && pendingRecord.crashed) {
            DLog(@"updateCrashedInFlightFromNewData - Trying to resolve issues with crashed non "
                  @"in flight record - uid = %@",
                  pendingRecord.uid);
            // Stalled pending record because a previous pending update on the same record crashed
            NSDictionary *dict = resolvedCrashed[pendingRecord.uid];
            if (nil != dict) {
                DLog(@"updateCrashedInFlightFromNewData - Found a stalled pending record backed "
                      @"up behind a resolved crash uid=%@ :: hash=%@",
                      pendingRecord.uid, pendingRecord.hashValue);
                pendingRecord.crashed = NO;
            }
        }
    }];

    [self.pendingDataRecords removeObjectsForKeys:keysToRemove];
}

- (void)updateNewDataFromInFlight:(NSMutableDictionary *)remoteData {
    if (self.pendingDataRecords && remoteData[@"records"]) {
        [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
            NSString *pendingHash = (NSString *)key;

            if (pendingRecord.inFlight) {
                BOOL updateReceivedForPending =
                    (nil != remoteData) && (nil != remoteData[@"updates"]) &&
                            (nil != remoteData[@"updates"][@"hashes"]) &&
                            (nil != remoteData[@"updates"][@"hashes"][pendingHash])
                        ? YES
                        : NO;
                DLog(@"updateNewDataFromInFlight - Found inflight pending Record - action = %@ :: "
                      @"hash = %@ :: updateReceivedForPending= %d",
                      pendingRecord.action, pendingHash, updateReceivedForPending);
                if (!updateReceivedForPending) {
                    NSMutableDictionary *remoteRecord =
                        [remoteData[@"records"][pendingRecord.uid] mutableCopy];
                    if ([pendingRecord.action isEqualToString:@"update"] && (nil != remoteRecord)) {
                        // Modify the new Record to have the updates from the pending record so the
                        // local dataset is consistent
                        remoteRecord[@"data"] = pendingRecord.postData.data;
                        remoteRecord[@"hash"] = pendingRecord.postData.hashValue;
                        remoteData[@"records"][pendingRecord.uid] = remoteRecord;
                    } else if ([pendingRecord.action isEqualToString:@"delete"] &&
                               (nil != remoteRecord)) {
                        // Remove the record from the new dataset so the local dataset is consistent
                        [remoteData[@"records"] removeObjectForKey:pendingRecord.uid];
                    } else if ([pendingRecord.action isEqualToString:@"create"]) {
                        // Add the pending create into the new dataset so it is not lost from the UI
                        DLog(@"updateNewDataFromInFlight - re adding pending create to incomming "
                              @"dataset");
                        NSMutableDictionary *dict = [NSMutableDictionary
                            dictionaryWithObjectsAndKeys:pendingRecord.postData.data, @"data",
                                                         pendingRecord.postData.hashValue, @"hash",
                                                         nil];
                        remoteData[@"records"][pendingRecord.uid] = dict;
                    }
                }
            }

        }];
    }
}

- (void)updateNewDataFromPending:(NSMutableDictionary *)remoteData {
    if (self.pendingDataRecords && remoteData[@"records"]) {
        [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;

            if (!pendingRecord.inFlight) {
                DLog(@"updateNewDataFromPending - Found Non inFlight record -> action=%@ :: "
                      @"uid=%@ :: hash=%@",
                      pendingRecord.action, pendingRecord.uid, pendingRecord.hashValue);
                NSMutableDictionary *remoteRecord =
                    [remoteData[@"records"][pendingRecord.uid] mutableCopy];
                if ([pendingRecord.action isEqualToString:@"update"] && (nil != remoteRecord)) {
                    // Modify the new Record to have the updates from the pending record so the
                    // local dataset is consistent
                    remoteRecord[@"data"] = pendingRecord.postData.data;
                    remoteRecord[@"hash"] = pendingRecord.postData.hashValue;
                    remoteData[@"records"][pendingRecord.uid] = remoteRecord;
                } else if ([pendingRecord.action isEqualToString:@"delete"] &&
                           (nil != remoteRecord)) {
                    [remoteData[@"records"] removeObjectForKey:pendingRecord.uid];
                } else if ([pendingRecord.action isEqualToString:@"create"]) {
                    // Add the pending create into the new dataset so it is not lost from the UI
                    DLog(@"updateNewDataFromPending - re adding pending create to incomming "
                          @"dataset");
                    NSMutableDictionary *dict = [NSMutableDictionary
                        dictionaryWithObjectsAndKeys:pendingRecord.postData.data, @"data",
                                                     pendingRecord.postData.hashValue, @"hash",
                                                     nil];
                    remoteData[@"records"][pendingRecord.uid] = dict;
                }
            }
        }];
    }
}

- (void)markInFlightAsCrashed {
    NSMutableDictionary *crashedRecords = [NSMutableDictionary dictionary];
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
        NSString *pendingHash = (NSString *)key;
        if (pendingRecord.inFlight) {
            DLog(@"Marking in flight pending record as crashed : %@", pendingHash);
            pendingRecord.crashed = YES;
            crashedRecords[pendingRecord.uid] = pendingRecord;
        }
    }];

    // Check for any pending updates that would be modifying a crashed record. These can not go out
    // until the
    // status of the crashed record is determined
    [self.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FHSyncPendingDataRecord *pendingRecord = (FHSyncPendingDataRecord *)obj;
        if (!pendingRecord.inFlight) {
            if (crashedRecords[pendingRecord.uid]) {
                pendingRecord.crashed = YES;
            }
        }
    }];
}

@end

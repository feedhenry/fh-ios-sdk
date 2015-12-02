/*
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FHSyncConfig.h"

/**
A class representing a sync dataset managed by the sync service
**/
@interface FHSyncDataset : NSObject

/** Indicate if the sync process is currently running **/
@property (nonatomic, assign) BOOL syncRunning;
/** Indicate if the dataset is initialised **/
@property (nonatomic, assign) BOOL initialised;
/** A unique id of the dataset **/
@property (nonatomic, strong) NSString *datasetId;
/** When last sync started **/
@property (nonatomic, copy) NSDate *syncLoopStart;
/** Wehn last sync finished **/
@property (nonatomic, copy) NSDate *syncLoopEnd;
/** Indicate if sync should be run in next run loop **/
@property (nonatomic, assign) BOOL syncLoopPending;
/** The sync config for this dataset **/
@property (nonatomic, copy) FHSyncConfig *syncConfig;
/** A collection of pending data records **/
@property (nonatomic, strong) NSMutableDictionary *pendingDataRecords;
/** A collection of synced data records **/
@property (nonatomic, strong) NSMutableDictionary *dataRecords;
/** The query params for this dataset **/
@property (nonatomic, strong) NSDictionary *queryParams;
/** Sync Meta data associated with this data set, used internally for the sync**/
@property (nonatomic, strong) NSMutableDictionary *syncMetaData;
/** Custom Meta data associated with this data set, used by user to customise the dataset ie: a subset of dataset.**/
@property (nonatomic, strong) NSMutableDictionary *customMetaData;
/** The SHA1 hash value of this data set **/
@property (nonatomic, strong) NSString *hashValue;
@property (nonatomic, strong) NSMutableArray *acknowledgements;
@property (nonatomic, strong) NSMutableDictionary *uidMapping;
@property (nonatomic, assign) BOOL stopSync;

- (instancetype)initWithDataId:(NSString *)dataId;

- (instancetype)initFromFileWithDataId:(NSString *)dataId error:(NSError *)error;

- (NSDictionary *)JSONData;

- (NSString *)JSONString;

+ (FHSyncDataset *)objectFromJSONString:(NSString *)jsonStr;

+ (FHSyncDataset *)objectFromJSONData:(NSDictionary *)jsonData;

- (void)saveToFile:(NSError *)error;

- (void)startSyncLoop;

- (NSDictionary *)listData;

- (NSDictionary *)readDataWithUID:(NSString *)uid;

- (NSDictionary *)createWithData:(NSDictionary *)data;

- (NSDictionary *)updateWithUID:(NSString *)uid data:(NSDictionary *)data;

- (NSDictionary *)deleteWithUID:(NSString *)uid;

@end

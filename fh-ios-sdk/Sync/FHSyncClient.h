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

#import "FH.h"
#import "FHSyncConfig.h"
#import "FHSyncNotificationMessage.h"
#import "FHSyncDelegate.h"
#import "FHSyncDataset.h"
/**
 The sync client is part of the FeedHenry data sync framework. It provides a mechanism to manage
 bi-direction data synchronization.
 For more details, please check [data sync framework docs](http://docs.feedhenry.com/v2/index.html)
 */
@interface FHSyncClient : NSObject

/** Get the singleton instance of the sync client */
+ (FHSyncClient *)getInstance;

/** Initializer for unit testing only.

 @param config The sync configuration
 */
- (instancetype)initWithConfig:(FHSyncConfig *)config AndDataSet:(FHSyncDataset*)dataSetInjected;

/** Initialize the sync client with the sync configuration
 
 @param config The sync configuration
 */
- (instancetype)initWithConfig:(FHSyncConfig *)config;
/**
 Use sync client to manage a dataset with id dataId.

 @param dataId the id of the data set
 @param config the sync configuration for this data set
 @param queryParams the query params for the data set
 */
- (void)manageWithDataId:(NSString *)dataId
               AndConfig:(FHSyncConfig *)config
                AndQuery:(NSDictionary *)queryParams;

/**
 Use sync client to manage a dataset with id dataId.
 
 @param dataId the id of the data set
 @param config the sync configuration for this data set
 @param queryParams the query params for the data set
 @param metaData the meta data for the data set
 */
- (void)manageWithDataId:(NSString *)dataId
               AndConfig:(FHSyncConfig *)config
                AndQuery:(NSDictionary *)queryParams
             AndMetaData:(NSMutableDictionary *)metaData;

/**
 Read a data record with id uid within data set with id dataId

 @param dataId the id of the data set
 @param uid the id of the data record

 @return the data record
 */
- (NSDictionary *)readWithDataId:(NSString *)dataId AndUID:(NSString *)uid;

/**
 List all the data records with in the data set with id dataId

 @param dataId the id of the data set

 @return all data records
 */
- (NSDictionary *)listWithDataId:(NSString *)dataId;

/**
 Create a data record within data set with id dataId

 @param dataId the id of the data set
 @param data the new data

 @return the created data record
 */
- (NSDictionary *)createWithDataId:(NSString *)dataId AndData:(NSDictionary *)data;

/**
 Update an existing data record with id uid within data set with id dataId

 @param dataId the id of the data set
 @param uid the id of the data record
 @param data the new data

 @return the data record
 */
- (NSDictionary *)updateWithDataId:(NSString *)dataId
                            AndUID:(NSString *)uid
                           AndData:(NSDictionary *)data;

/**
 Delete a data record with id uid within data set with id dataId

 @param dataId the id of the data set
 @param uid the id of the data record

 @return the deleted data record
 */
- (NSDictionary *)deleteWithDataId:(NSString *)dataId AndUID:(NSString *)uid;

/**
 List the collisions for data set with id dataId

 @param dataId the id of the data set
 @param sucornil the success callback function
 @param failornil the failure callback function
 */
- (void)listCollisionWithCallbacksForDataId:(NSString *)dataId
                                 AndSuccess:(void (^)(FHResponse *success))sucornil
                                 AndFailure:(void (^)(FHResponse *failed))failornil;

/**
 Remove a collision with hash collisionHash for data set with id dataId

 @param dataId the id of the dataset
 @param collisionHash the hash value of the collision
 @param sucornil the success callback function
 @param failornil the failure callback function
 */
- (void)removeCollisionWithCallbacksForDataId:(NSString *)dataId
                                         hash:(NSString *)collisionHash
                                   AndSuccess:(void (^)(FHResponse *success))sucornil
                                   AndFailure:(void (^)(FHResponse *failed))failornil;

/**
 Stop the sync service for data set with id dataId

 @param dataId the id of the dataset
 */
- (void)stopWithDataId:(NSString *)dataId;

/**
 Stop all sync services and destroy the sync client
 */
- (void)destroy;

/**
 Causes the sync framework to schedule for immediate execution a sync.
 
 @param dataSetId The id of the dataset
 */
- (void)forceSync:(NSString*)dataSetId;
@end

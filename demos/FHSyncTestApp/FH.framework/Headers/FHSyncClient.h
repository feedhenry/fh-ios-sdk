/**
 The sync client is part of the FeedHenry data sync framework. It provides a mechanism to manage bi-direction data synchronization.
 For more details, please check [data sync framework docs](http://docs.feedhenry.com/v2/index.html)
 */

#import <Foundation/Foundation.h>
#import "FHSyncClient.h"
#import "JSONKit.h"
#import "FHSyncConfig.h"




@interface FHSyncClient : NSObject

/**@name Init the sync client */

/** Get the singleton instance of the sync client */
+ (FHSyncClient*) getInstance;

/** Initialize the sync client with the sync configuration 
 @param config The sync configuration
 */
- (id) initWithConfig:(FHSyncConfig*) config;

/**@name Use the sync client */

/**
 Use sync client to manage a dataset with id dataId.
 @param dataId the id of the data set
 @param config the sync configuration for this data set
 @param queryParams the query params for the data set
 */
- (void) manageWithDataId:(NSString* ) dataId AndConfig:(FHSyncConfig*) config AndQuery:(NSDictionary* ) queryParams;

/** @name CRUDL operations on the data set */

/**
 Read a data record with id uid within data set with id dataId
 @param dataId the id of the data set
 @param uid the id of the data record
 @return the data record
 */
- (NSDictionary *) readWithDataId:(NSString*) dataId AndUID:(NSString*) uid;

/**
 List all the data records with in the data set with id dataId
 @param dataId the id of the data set
 @return all data records
 */
- (NSDictionary *) listWithDataId:(NSString*) dataId;

/**
 Create a data record within data set with id dataId
 @param dataId the id of the data set
 @param data the new data
 @return the created data record
 */
- (BOOL) createWithDataId:(NSString*) dataId AndData:(NSDictionary *) data;

/**
 Update an existing data record with id uid within data set with id dataId
 @param dataId the id of the data set
 @param uid the id of the data record
 @param data the new data
 @return the data record
 */
- (BOOL) updateWithDataId:(NSString*) dataId AndUID:(NSString*) uid AndData:(NSDictionary *) data;

/**
 delete a data record with id uid within data set with id dataId
 @param dataId the id of the data set
 @param uid the id of the data record
 @return the deleted data record
 */
- (BOOL) deleteWithDataId:(NSString*) dataId AndUID:(NSString*) uid;

/**@name Manage Collisions */

/**
 List the collisions for data set with id dataId
 @param dataId the id of the data set
 @param sucornil the success callback function
 @param failornil the failure callback function
 */
- (void) listCollisionWithCallbacksForDataId:(NSString*) dataId AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

/**
 Remove a collision with hash collisionHash for data set with id dataId
 @param dataId the id of the dataset
 @param collisionHash the hash value of the collision
 @param sucornil the success callback function
 @param failornil the failure callback function
 */
- (void) removeCollisionWithCallbacksForDataId:(NSString*) dataId hash:(NSString*) collisionHash AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

/**@name Stop the sync service */

/**
 Stop the sync service for data set with id dataId
 @param dataId the id of the dataset
 */
- (void) stopWithDataId:(NSString*) dataId;

/**
 Stop all sync services and destroy the sync client
 */
- (void) destroy;

@end

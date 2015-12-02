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

/**
 The configuration options for the sync client
 */
@interface FHSyncConfig : NSObject

/** The sync frequency. In seconds.*/
@property double syncFrequency;

/** If set to YES, the sync loop will start immediately if there is a local
 * change made */
@property BOOL autoSyncLocalUpdates;

/** If set to YES, a notification will be created when a sync loop start */
@property BOOL notifySyncStarted;

/** If set to YES, a notification will be created when a sync loop complete */
@property BOOL notifySyncCompleted;

/** If set to YES, a notification will be created when a sync collision detect*/
@property BOOL notifySyncCollision;

/** If set to YES, a notification will be created when a offline update finish
 */
@property BOOL notifyOfflineUpdate;

/** If set to YES, a notification will be created when a remote update fail */
@property BOOL notifyRemoteUpdateFailed;

/** If set to YES, a notification will be created when a remote update applied
 */
@property BOOL notifyRemoteUpdateApplied;

/** If set to YES, a notification will be create when a local update applied */
@property BOOL notifyLocalUpdateApplied;

/** If set to YES, a notification will be created when a delta is received */
@property BOOL notifyDeltaReceived;

/** If set to YES, a notification will be created when client side storage fail
 */
@property BOOL notifyClientStorageFailed;

/** If set to YES, a notification will be created when a sync loop fail */
@property BOOL notifySyncFailed;

/** Set the crash count limit before the crashed records either resent or
 * discarded*/
@property NSInteger crashCountWait;

/** If set to YES, the crashed updates will be discarded if the crash count
 * limit reached */
@property BOOL resendCrashedUpdates;

/** If use the old sync API on the cloud side, set this to true. Default to
 * false. **/
@property BOOL hasCustomSync;

/** If the local data file should be synced via iCloud **/
@property BOOL icloud_backup;

@property BOOL debug;

- (instancetype)init;

- (NSDictionary *)JSONData;

- (NSString *)JSONString;

+ (FHSyncConfig *)objectFromJSONString:(NSString *)jsonStr;

+ (FHSyncConfig *)objectFromJSONData:(NSDictionary *)jsonData;

@end

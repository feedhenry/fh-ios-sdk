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
extern NSString *const kFHSyncStateChangedNotification;

extern NSString *const SYNC_STARTED_MESSAGE;
extern NSString *const SYNC_COMPLETE_MESSAGE;
extern NSString *const SYNC_FAILED_MESSAGE;
extern NSString *const OFFLINE_UPDATE_MESSAGE;
extern NSString *const COLLISION_DETECTED_MESSAGE;
extern NSString *const REMOTE_UPDATE_FAILED_MESSAGE;
extern NSString *const REMOTE_UPDATE_APPLIED_MESSAGE;
extern NSString *const LOCAL_UPDATE_APPLIED_MESSAGE;
extern NSString *const DELTA_RECEIVED_MESSAGE;
extern NSString *const CLIENT_STORAGE_FAILED_MESSAGE;

/**
 The notification message created by the sync client
 */
@interface FHSyncNotificationMessage : NSObject

- (instancetype)initWithDataId:(NSString *)dataId
                        AndUID:(NSString *)uid
                       AndCode:(NSString *)code
                    AndMessage:(NSString *)message;

/** Get the data set id associated with the notification */
@property (nonatomic, strong, readonly) NSString *dataId;

/** Get the id of the data record associated with the notification (if any)*/
@property (nonatomic, strong, readonly) NSString *UID;

/** Get the code of the notification */
@property (nonatomic, strong, readonly) NSString *code;

/** Extra message of the noification */
@property (nonatomic, strong, readonly) NSString *message;

@end

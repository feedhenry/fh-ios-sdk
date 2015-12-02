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
#import "FHSyncNotificationMessage.h"

NSString *const kFHSyncStateChangedNotification = @"kFHSyncStateChangedNotification";

NSString *const SYNC_STARTED_MESSAGE = @"SYNC_STARTED";
NSString *const SYNC_COMPLETE_MESSAGE = @"SYNC_COMPLETE";
NSString *const SYNC_FAILED_MESSAGE = @"SYNC_FAILED";
NSString *const OFFLINE_UPDATE_MESSAGE = @"OFFLINE_UPDATE";
NSString *const COLLISION_DETECTED_MESSAGE = @"COLLISION_DETECTED";
NSString *const REMOTE_UPDATE_FAILED_MESSAGE = @"REMOTE_UPDATE_FAILED";
NSString *const REMOTE_UPDATE_APPLIED_MESSAGE = @"REMOTE_UPDATE_APPLIED";
NSString *const LOCAL_UPDATE_APPLIED_MESSAGE = @"LOCAL_UPDATE_APPLIED";
NSString *const DELTA_RECEIVED_MESSAGE = @"DELTA_RECEIVED";
NSString *const CLIENT_STORAGE_FAILED_MESSAGE = @"CLIENT_STORAGE_FAILED";

@implementation FHSyncNotificationMessage

- (instancetype)initWithDataId:(NSString *)dataId
                        AndUID:(NSString *)uid
                       AndCode:(NSString *)code
                    AndMessage:(NSString *)message {
    self = [super init];
    if (self) {
        _dataId = dataId;
        _UID = uid;
        _code = code;
        _message = message;
    }
    return self;
}

- (NSString *)description {
    return [NSString
        stringWithFormat:@"dataId:%@-uid:%@-code:%@-message:%@", _dataId, _UID, _code, _message];
}

@end

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

#import "FHSyncDataRecord.h"

@interface FHSyncPendingDataRecord : NSObject

@property (nonatomic, assign) BOOL inFlight;
@property (nonatomic, assign) BOOL crashed;
@property (nonatomic, strong) NSDate *inFlightDate;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSNumber *timestamp;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) FHSyncDataRecord *preData;
@property (nonatomic, strong) FHSyncDataRecord *postData;
@property (nonatomic, strong, readonly) NSString *hashValue;
@property (nonatomic, assign) int crashedCount;
@property (nonatomic, assign) BOOL delayed;
@property (nonatomic, strong) NSString* waitingFor;

- (NSMutableDictionary *)JSONData;

+ (FHSyncPendingDataRecord *)objectFromJSONData:(NSDictionary *)jsonData key:(NSString*) key;

- (NSString *)JSONString;

+ (FHSyncPendingDataRecord *)objectFromJSONString:(NSString *)jsonStr;

@end

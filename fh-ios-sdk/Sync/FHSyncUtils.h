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

@interface FHSyncUtils : NSObject

+ (NSString *)getStorageFilePath:(NSString *)fileName;

+ (NSString *)loadDataFromFile:(NSString *)fileName error:(NSError *)error;

+ (void)saveData:(NSString *)data
          toFile:(NSString *)fileName
          backup:(BOOL)backup
           error:(NSError *)error;

+ (NSString *)generateHashWithString:(NSString *)text;

+ (NSString *)generateHashForData:(id)data;

+ (void)doNotifyWithDataId:(NSString *)dataId
                    config:(FHSyncConfig *)config
                       uid:(NSString *)uid
                      code:(NSString *)code
                   message:(NSString *)message;

@end

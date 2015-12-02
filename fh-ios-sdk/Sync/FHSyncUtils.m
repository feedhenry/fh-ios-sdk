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

#import <CommonCrypto/CommonDigest.h>

#import "FHSyncUtils.h"
#import "FHSyncClient.h"
#import "FHDefines.h"

@implementation FHSyncUtils

+ (NSString *)getStorageFilePath:(NSString *)fileName {
    NSArray *paths =
        NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = paths[0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    NSString *storageFilePath = [documentsDir stringByAppendingPathComponent:fileName];
    DLog(@"file path is %@", storageFilePath);
    return storageFilePath;
}

+ (NSString *)loadDataFromFile:(NSString *)fileName error:(NSError *)error;
{
    NSString *storageFilePath = [FHSyncUtils getStorageFilePath:fileName];
    NSString *fileContent = nil;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:storageFilePath];
    if (fileExists) {
        fileContent = [NSString stringWithContentsOfFile:storageFilePath
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
        if (error) {
            DLog(@"Failed to read file content from file : %@ with error %@", storageFilePath,
                  [error localizedDescription]);
        }
    }
    return fileContent;
}

+ (void)saveData:(NSString *)data
          toFile:(NSString *)fileName
          backup:(BOOL)backup
           error:(NSError *)error {
    NSString *filePath = [FHSyncUtils getStorageFilePath:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]
            createFileAtPath:filePath
                    contents:[data dataUsingEncoding:NSUTF8StringEncoding]
                  attributes:nil];
        if (!backup) {
            NSError *error = nil;
            NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
            BOOL success =
                [fileUrl setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            if (!success) {
                DLog(@"Error excluding %@ from backup %@", filePath, error);
            }
        }
    } else {
        [data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DLog(@"Failed to write data to file at path %@ with error %@", filePath,
                  [error localizedDescription]);
        }
    }
}

+ (NSString *)generateHashWithString:(NSString *)text {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

+ (id)sortData:(id)data {
    if (nil == data ||
        (![data isKindOfClass:[NSDictionary class]] && ![data isKindOfClass:[NSArray class]])) {
        return data;
    }

    NSMutableArray *results = [NSMutableArray array];
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSArray *keys = [(NSDictionary *)data allKeys];
        NSArray *sortedKeys =
            [keys sortedArrayUsingSelector:@selector(compare:)];
        for (int i = 0; i < sortedKeys.count; i++) {
            NSString *key = sortedKeys[i];
            id value = data[key];
            NSMutableDictionary *record = [NSMutableDictionary dictionary];
            record[@"key"] = key;
            record[@"value"] = [FHSyncUtils sortData:value];
            [results addObject:record];
        }

    } else if ([data isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [data count]; i++) {
            NSMutableDictionary *record = [NSMutableDictionary dictionary];
            record[@"key"] = [NSString stringWithFormat:@"%d", i];
            record[@"value"] = [FHSyncUtils sortData:data[i]];
            [results addObject:record];
        }
    }
    return results;
}

/** We have to make sure the hash value generated by this method will result the
 * same value as the function in JS SDK **/
+ (NSString *)generateHashForData:(id)data {
    id results = [FHSyncUtils sortData:data];
    NSString *jsonStr = [results JSONString];
    DLog(@"sorted data = %@", jsonStr);
    return [FHSyncUtils generateHashWithString:jsonStr];
}

+ (void)doNotifyWithDataId:(NSString *)dataId
                    config:(FHSyncConfig *)config
                       uid:(NSString *)uid
                      code:(NSString *)code
                   message:(NSString *)message {
    BOOL doSend = NO;
    if (config.notifySyncStarted && [code isEqualToString:SYNC_STARTED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifySyncCompleted && [code isEqualToString:SYNC_COMPLETE_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifyClientStorageFailed && [code isEqualToString:CLIENT_STORAGE_FAILED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifyDeltaReceived && [code isEqualToString:DELTA_RECEIVED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifyOfflineUpdate && [code isEqualToString:OFFLINE_UPDATE_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifySyncCollision && [code isEqualToString:COLLISION_DETECTED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifyRemoteUpdateApplied && [code isEqualToString:REMOTE_UPDATE_APPLIED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifyRemoteUpdateFailed && [code isEqualToString:REMOTE_UPDATE_FAILED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifyRemoteUpdateApplied && [code isEqualToString:LOCAL_UPDATE_APPLIED_MESSAGE]) {
        doSend = YES;
    }
    if (config.notifySyncFailed && [code isEqualToString:SYNC_FAILED_MESSAGE]) {
        doSend = YES;
    }
    if (doSend) {
        FHSyncNotificationMessage *notification =
            [[FHSyncNotificationMessage alloc] initWithDataId:dataId
                                                       AndUID:uid
                                                      AndCode:code
                                                   AndMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHSyncStateChangedNotification
                                                            object:notification];
    }
}

@end

//
//  FHSyncUtils.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
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

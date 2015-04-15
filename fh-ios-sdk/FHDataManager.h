//
//  FHDataManager.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHDataManager : NSObject

+ (void)save:(NSString *)key withObject:(id)value;

+ (id)read:(NSString *)key;

+ (void)remove:(NSString *)key;

@end

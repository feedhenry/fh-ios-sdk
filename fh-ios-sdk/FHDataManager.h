//
//  FHDataManager.h
//  fh-ios-sdk
//
//  Created by Wei Li on 10/04/2015.
//  Copyright (c) 2015 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHDataManager : NSObject

+ (void) save:(NSString*) key withObject:(NSObject*) value;

+ (id) read:(NSString*) key;

+ (void) remove:(NSString*) key;

@end

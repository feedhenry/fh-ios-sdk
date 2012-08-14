//
//  FHConfig.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 30/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+MD5.h"

@interface FHConfig : NSObject{
    NSMutableDictionary * properties;
    NSString * propertiesPath;
}

@property(nonatomic, retain) NSDictionary* properties;

- (NSString *)getConfigValueForKey:(NSString *)key;
- (void)setConfigValue:(NSString *)val ForKey:(NSString *)key;
- (NSString *)uid;
+ (FHConfig *)getSharedInstance;
@end

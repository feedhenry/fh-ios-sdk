//
//  FHConfig.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 30/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHConfig : NSObject

+ (NSString *)getConfigValueForKey:(NSString *)key;
+ (void)setConfigValue:(NSString *)val ForKey:(NSString *)key;

@end

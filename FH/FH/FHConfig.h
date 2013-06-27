//
//  FHConfig.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 30/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+MD5.h"
#import <AdSupport/AdSupport.h>

/** A utility class to get the app configurations from fhconfig.plist file. */

@interface FHConfig : NSObject{
    NSMutableDictionary * properties;
    NSString * propertiesPath;
}

/** Access the configurations. */
@property(nonatomic, retain) NSDictionary* properties;

/** Get a configuration value for a given key.
 
 @param key The configuration key
 @return Returns the configuration value
 */
- (NSString *)getConfigValueForKey:(NSString *)key;

/** Set the configuration value for a given key.
 
 @param val The configuration value
 @param key The configuration key
 */
- (void)setConfigValue:(NSString *)val ForKey:(NSString *)key;

/** Get the hash value of the device's unique id (OpenUDID) 
 
 @return The device's unique ID
 */
- (NSString *)uid;

- (NSString *)advertiserId;
- (BOOL)trackingEnabled;

/** Get the singleton instace of this class 
 
 @return The singleton instance
 */
+ (FHConfig *)getSharedInstance;
@end

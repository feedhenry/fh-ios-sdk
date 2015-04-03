//
//  FHConfig.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

/**
 A utility class to get the app configurations from fhconfig.plist file.
 */
@interface FHConfig : NSObject

/** Access the configurations. */
@property (nonatomic, strong, readonly) NSDictionary *properties;

/** Get or generate and get a new CFUUID (stored in NSUserDefaults)

 @return CFUUID
 */
@property (nonatomic, strong, readonly) NSString *uuid;

/** Return vendorIdentifier */
@property (nonatomic, strong, readonly) NSString *vendorId;

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

/** Get the singleton instace of this class

 @return The singleton instance
 */
+ (FHConfig *)getSharedInstance;

@end

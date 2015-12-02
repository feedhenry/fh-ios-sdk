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

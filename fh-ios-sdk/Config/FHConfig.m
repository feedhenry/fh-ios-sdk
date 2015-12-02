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

#import <UIKit/UIKit.h>

#import "FHConfig.h"
#import "FHDataManager.h"

@interface FHConfig ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *properties;
@end

@implementation FHConfig

/**
 Init method called by unit test without using singleton.
*/
+ (instancetype)config {
    return [[FHConfig alloc] initWithFileName:@"fhconfig"];
}
- (instancetype)initWithFileName:(NSString*)fileName {
    self = [super init];
    if (self) {
        NSString *path =
            [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        if (path) {
            self.properties = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        } else {
            path = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"plist"];
            if (path) {
                self.properties = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            } else {
                @throw([NSException exceptionWithName:@"fhconfigException"
                                               reason:@"fhconfig.plist was not located"
                                             userInfo:nil]);
            }
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithFileName:@"fhconfig"];
}

+ (FHConfig *)getSharedInstance {
    static FHConfig *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[FHConfig alloc] init];
    });

    return _shared;
}

- (NSString *)getConfigValueForKey:(NSString *)key {
    NSString *ret = [self.properties valueForKey:key];
    if ([self isStringEmpty:ret]) {
        return nil;
    } else {
        return ret;
    }
}

- (BOOL)isStringEmpty:(NSString *)value {
    if ((NSNull *)value == [NSNull null]) {
        return YES;
    } else if (value == nil) {
        return YES;
    } else if ([value length] == 0) {
        return YES;
    } else {
        value = [value
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([value length] == 0) {
            return YES;
        }
    }
    return NO;
}

- (void)setConfigValue:(NSString *)val ForKey:(NSString *)key {
    [self.properties setValue:val forKey:key];
}

// Unique vendor ID
- (NSString *)vendorId {
    NSUUID *vendorId = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuid = [vendorId UUIDString];
    return uuid;
}

// Fetches existing UUID stored in NSUserDefaults, or generates a new one
- (NSString *)uuid {
    static NSString *UUID_KEY = @"FHUUID";

    NSString *app_uuid = [FHDataManager read:UUID_KEY];

    if (app_uuid == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);

        app_uuid = [NSString stringWithString:(__bridge NSString *)uuidString];
        [FHDataManager save:UUID_KEY withObject:app_uuid];

        CFRelease(uuidString);
        CFRelease(uuidRef);
    }

    return app_uuid;
}

@end

//
//  FHConfig.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FHConfig.h"
#import "NSString+MD5.h"
#import "FHDataManager.h"

@interface FHConfig ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *properties;
@end

@implementation FHConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path =
            [[NSBundle mainBundle] pathForResource:@"fhconfig" ofType:@"plist"];
        if (path) {
            self.properties = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        } else {
            path = [[NSBundle bundleForClass:[self class]] pathForResource:@"fhconfig" ofType:@"plist"];
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

// Unique vendor ID (available in iOS6+)
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

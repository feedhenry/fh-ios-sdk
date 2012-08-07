//
//  FHConfig.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 30/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHConfig.h"
#import "NSString+MD5.h"
#include "OpenUDID.h"

static FHConfig * shared;
@implementation FHConfig

- (id)init{
    self = [super init];
    if(self){
        NSString * path = [[NSBundle mainBundle] pathForResource:@"fhconfig" ofType:@"plist"];
        if(path){
            propertiesPath  = path;
            properties      = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        }else{
            @throw ([NSException exceptionWithName:@"fhconfigException" reason:@"fhconfig.plist was not located" userInfo:nil]);
        }
    }
    return self;
}

+ (void)initialize{
    static BOOL initialized = NO;
    if(!initialized){
        initialized = YES;
        shared = [[FHConfig alloc]init];
    }
}

+ (FHConfig *)getSharedInstance{
    return shared;
}

- (NSString *)getConfigValueForKey:(NSString *)key{
    return [properties objectForKey:key];
}
- (void)setConfigValue:(NSString *)val ForKey:(NSString *)key{
    [properties setValue:val forKey:key];
}

- (NSString *)uid{
    NSString *openUDID = [OpenUDID value];
    return [openUDID MD5Hash];
}

@end

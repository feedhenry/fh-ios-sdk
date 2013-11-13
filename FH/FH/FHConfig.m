//
//  FHConfig.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 30/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHConfig.h"
#import "NSString+MD5.h"
#include "FH_OpenUDID.h"

@implementation FHConfig
static FHConfig * shared = nil;
@synthesize properties;

- (id)init{
  self = [super init];
  if(self){
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"fhconfig" ofType:@"plist"];
    if(path){
      propertiesPath  = path;
      self.properties      = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }else{
      @throw ([NSException exceptionWithName:@"fhconfigException" reason:@"fhconfig.plist was not located" userInfo:nil]);
    }
  }
  return self;
}

+ (FHConfig *)getSharedInstance{
  @synchronized(self){
    if(shared == nil){
      shared = [[self alloc] init];
    }
  }
  return shared;
}

- (NSString *)getConfigValueForKey:(NSString *)key{
  NSString* ret = [self.properties valueForKey:key];
  if ([self isStringEmpty:ret]) {
    return nil;
  } else {
    return ret;
  }
}

- (BOOL) isStringEmpty:(NSString*) value
{
  if ((NSNull*) value == [NSNull null]) {
    return YES;
  } else if (value == nil) {
    return YES;
  } else if ([value length] == 0){
    return YES;
  } else {
    value = [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([value length] == 0) {
      return YES;
    }
  }
  return NO;
}

- (void)setConfigValue:(NSString *)val ForKey:(NSString *)key{
  [self.properties setValue:val forKey:key];
}

- (NSString *)uid{
  return [[FH_OpenUDID value] MD5Hash];
}


- (NSString *)advertiserId {
  ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
  NSUUID *advertId = [manager advertisingIdentifier];
  NSString *advertIdString = [advertId UUIDString];
  return advertIdString;
}

- (BOOL)trackingEnabled {
  ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
  BOOL trackingEnabled = manager.advertisingTrackingEnabled;
  return trackingEnabled;
}


@end

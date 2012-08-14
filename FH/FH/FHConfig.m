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
  return [self.properties valueForKey:key];
}
- (void)setConfigValue:(NSString *)val ForKey:(NSString *)key{
  [self.properties setValue:val forKey:key];
}

- (NSString *)uid{
  return [[FH_OpenUDID value] MD5Hash];
}

-(void)dealloc{
  [super dealloc];
}

@end

//
//  FHInitRequest.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHInitRequest.h"
#import "FHConfig.h"
#import "FHDefines.h"

#define FH_INIT_PATH @"box/srv/1.1/app/init"

@implementation FHInitRequest

- (id)initWithProps:(NSDictionary *) props{
  self = [super initWithProps:props];
  if(self){
    [self initArgs];
  }
  return self;
}

- (void) initArgs{
  [args setValue:[[FHConfig getSharedInstance] getConfigValueForKey:@"appid"] forKey:@"appid"];
  [args setValue:[[FHConfig getSharedInstance] getConfigValueForKey:@"appkey"] forKey:@"appkey"];
  [args setValue:uid forKey:@"cuid"];
  [args setValue:[NSString stringWithFormat:@"FH_IOS_SDK/%@", FH_SDK_VERSION] forKey:@"sdk_version"];
  [args setValue:@"ios" forKey:@"destination"];
}

- (NSString *) getPath {
  return FH_INIT_PATH;
}

@end

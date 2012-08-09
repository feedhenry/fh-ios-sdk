//
//  FHInitRequest.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHInitRequest.h"
#import <UIKit/UIDevice.h>

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
  [args setValue:[appConfig getConfigValueForKey:@"appID"] forKey:@"appID"];
  [args setValue:[appConfig getConfigValueForKey:@"appKey"] forKey:@"appKey"];
  [args setValue:uid forKey:@"deviceID"];
  NSString * destination = @"iphone";
  if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
    destination = @"ipad";
  }
  [args setValue:destination forKey:@"destination"];
}

- (NSString *) getPath {
  return FH_INIT_PATH;
}

@end

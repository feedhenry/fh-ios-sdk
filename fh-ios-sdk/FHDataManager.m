//
//  FHDataManager.m
//  fh-ios-sdk
//
//  Created by Wei Li on 10/04/2015.
//  Copyright (c) 2015 FeedHenry. All rights reserved.
//

#import "FHDataManager.h"

@implementation FHDataManager

+ (void) save:(NSString*) key withObject:(NSObject*) value
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:value forKey:key];
  [defaults synchronize];
}

+ (id) read:(NSString*) key
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:key];
}

+ (void) remove:(NSString*) key
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:key];
}

@end

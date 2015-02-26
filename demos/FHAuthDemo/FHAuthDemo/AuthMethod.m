//
//  AuthMethod.m
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "AuthMethod.h"

@implementation AuthMethod

- (id) initWithName:(NSString*)_name icon:(NSString*)_iconName policyId:(NSString*)_policyId
{
  self = [super  init];
  if(self){
    name = [_name retain];
    iconName = [_iconName retain];
    policyId = [_policyId retain];
  }
  return self;
}

- (NSString*) getName
{
  return name;
}

- (NSString*) getIcon
{
  return iconName;
}

- (void) performAuthWithViewController:(UIViewController*) viewController
{
  //do nothing
}

-(void)dealloc{
  [name release];
  [iconName release];
  [policyId release];
  [super dealloc];
}
@end

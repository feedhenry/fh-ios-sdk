//
//  AuthMethod.h
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthMethod : NSObject
{
  NSString* name;
  NSString* iconName;
  NSString* policyId;
}

- (id) initWithName:(NSString*)name icon:(NSString*)iconName policyId:(NSString*)policyId;
- (NSString*) getName;
- (NSString*) getIcon;
- (void) performAuthWithViewController:(UIViewController*) viewController;
@end

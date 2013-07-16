//
//  FHAuthReqeust.h
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

/** Authentication & authorization using FeedHenry */

#import "FHAct.h"
#import <UIKit/UIViewController.h>

@interface FHAuthRequest : FHAct {
  NSString * policyId;
  NSString * userId;
  NSString * password;
  UIViewController* parentViewController;
}

/** The policyId used by this request. Don't access it directly, use authWithPolicyId:. */
@property (nonatomic, retain)NSString *policyId;

/** If the auth policy type is FeedHenry or LDAP, the userId and password should be provided. Don't access it directly, use authWithPolicyId:UserId:Password:. */
@property (nonatomic, retain)NSString *userId;

/** If the auth policy type is FeedHenry or LDAP, the userId and password should be provided. Don't access it directly, use authWithPolicyId:UserId:Password:. */
@property (nonatomic, retain)NSString *password;

/** If the auth policy type is OAuth, to allow user authenticate with the OAuth provider, a UIWebView is used to load the login page and do the authentication. 
 The library has a built-in UI component to handle this automatially. If this property is set, the built-in UI component will be used. Otherwise you need to handle the OAuth process.
 */
@property (nonatomic, retain)UIViewController* parentViewController;

/** Init a new request and set the parentViewController.
 
 @param props The app configurations
 @param viewController The parent UIViewController to present OAuth UI component. See parentViewController.
 */
- (id) initWithProps:(NSDictionary *)props AndViewController:(UIViewController*) viewController;

/** Set the policyId for this auth request.
 
 Normally should be used if the auth type is OAuth.
 
 @param policyId The policyId value
 */
- (void) authWithPolicyId:(NSString *)policyId;

/** Set the policyId and user credentials for this auth request. 
 
 Normally should be used if the auth type is FeedHenry or LDAP.
 
 @param policyId The policyId
 @param userId The user id
 @param password The user password
 */
- (void) authWithPolicyId:(NSString *)policyId UserId:(NSString *)userId Password:(NSString *)password;  

@end
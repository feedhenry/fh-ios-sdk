//
//  FHAuthReqeust.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHAct.h"

/**
 Authentication & authorization using FeedHenry
 */
@interface FHAuthRequest : FHAct

/** The policyId used by this request. Don't access it directly, use
 * authWithPolicyId:. */
@property (nonatomic, strong) NSString *policyId;

/** If the auth policy type is FeedHenry or LDAP, the userId and password should
 * be provided. Don't access it directly, use authWithPolicyId:UserId:Password:.
 */
@property (nonatomic, strong) NSString *userId;

/** If the auth policy type is FeedHenry or LDAP, the userId and password should
 * be provided. Don't access it directly, use authWithPolicyId:UserId:Password:.
 */
@property (nonatomic, strong) NSString *password;

/** If the auth policy type is OAuth, to allow user authenticate with the OAuth
provider, a UIWebView is used to load the login page and do the authentication.
The library has a built-in UI component to handle this automatially. If this
property is set, the built-in UI component will be used. Otherwise you need to
handle the OAuth process.
*/
@property (nonatomic, strong) UIViewController *parentViewController;

/** Init a new request and set the parentViewController.
@param viewController The parent UIViewController to present OAuth UI component.
See parentViewController.
*/
- (instancetype)initWithViewController:(UIViewController *)viewController;

/** Set the policyId for this auth request.

Normally should be used if the auth type is OAuth.

@param policyId The policyId value
*/
- (void)authWithPolicyId:(NSString *)policyId;

/** Set the policyId and user credentials for this auth request.

Normally should be used if the auth type is FeedHenry or LDAP.

@param policyId The policyId
@param userId The user id
@param password The user password
*/
- (void)authWithPolicyId:(NSString *)policyId
                  UserId:(NSString *)userId
                Password:(NSString *)password;

@end
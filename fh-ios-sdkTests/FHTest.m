//
//  FHTest.m
//  fh-ios-sdk
//
//  Created by Corinne Krych on 05/11/15.
//  Copyright © 2015 FeedHenry. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMOck/OCMock.h>
#import "FH.h"
#import "AeroGearPush.h"

@interface FHTest : XCTestCase

@end

@implementation FHTest

id _mockApplication;

- (void)setUp {
    [super setUp];
    _mockApplication = OCMClassMock([UIApplication class]);
    OCMStub([_mockApplication registerUserNotificationSettings:[OCMArg any]]);
    OCMStub([_mockApplication registerForRemoteNotifications]);

}

- (void)tearDown {
    [super tearDown];
}

- (void)testPushEnabledForRemoteNotification {
    // given
    
    // when
    [FH pushEnabledForRemoteNotification:_mockApplication];
    
    // then
    OCMVerify([_mockApplication registerUserNotificationSettings:[OCMArg any]]);
    OCMVerify([_mockApplication registerForRemoteNotifications]);
}

- (void)testPushRegister {
    // given
    NSData* deviceToken = [@"AAAA-BBBB-CCCC" dataUsingEncoding:NSUTF8StringEncoding];
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    OCMStub([userDefaultsMock setObject:deviceToken forKey:@"deviceToken"]);
    
    // when
    [FH pushRegister:deviceToken andSuccess:^(FHResponse *success) {
    } andFailure:^(FHResponse *failed) {
    }];
    
    // then
    OCMVerify([userDefaultsMock setObject:[OCMArg any] forKey:@"deviceToken"]);
}

- (void)testSetPushAlias {
    // given
    NSData* deviceToken = [@"AAAA-BBBB-CCCC" dataUsingEncoding:NSUTF8StringEncoding];
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    OCMStub([userDefaultsMock objectForKey:@"deviceToken"]).andReturn(deviceToken);
    
    id registrationMock = OCMClassMock([AGDeviceRegistration class]);
    OCMStub([registrationMock registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        [clientInfo setDeviceToken:[@"AAAA-BBBB-CCCC" dataUsingEncoding:NSUTF8StringEncoding]];
        [clientInfo setAlias:@"ALIAS"];
        [clientInfo setCategories:[OCMArg any]];
    } success:^{

    } failure:^(NSError *error) {

    }]);

    
    // when
    [FH setPushAlias:@"ALIAS" andSuccess:^(FHResponse *success) {
    } andFailure:^(FHResponse *failed) {
    }];
    
    // then
}
- (void)testSetPushCategories {
    // given
    NSData* deviceToken = [@"AAAA-BBBB-CCCC" dataUsingEncoding:NSUTF8StringEncoding];
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    OCMStub([userDefaultsMock objectForKey:@"deviceToken"]).andReturn(deviceToken);
    
    id registrationMock = OCMClassMock([AGDeviceRegistration class]);
    OCMStub([registrationMock registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        [clientInfo setDeviceToken:[@"AAAA-BBBB-CCCC" dataUsingEncoding:NSUTF8StringEncoding]];
        [clientInfo setAlias:@"ALIAS"];
        [clientInfo setCategories:[OCMArg any]];
    } success:^{
        
    } failure:^(NSError *error) {
        
    }]);
    
    
    // when
    [FH setPushCategories:@[@"one_category"] andSuccess:^(FHResponse *success) {
    } andFailure:^(FHResponse *failed) {
    }];
    
    // then
}

@end

/*
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

- (void)testIsTagDisabled {
    XCTAssertFalse([FH isTagDisabled]);
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

- (void)testSendMetricsWhenAppLaunched {
    // given
    id analyticsMock = OCMClassMock([AGPushAnalytics class]);
    OCMStub([analyticsMock sendMetricsWhenAppLaunched:[OCMArg any]]);
    
    // when
    [FH sendMetricsWhenAppLaunched:@{}];
    
    // then
    OCMVerify([analyticsMock sendMetricsWhenAppLaunched:[OCMArg any]]);
}

- (void)testSendMetricsWhenAppAwoken {
    // given
    id analyticsMock = OCMClassMock([AGPushAnalytics class]);
    OCMStub([analyticsMock sendMetricsWhenAppAwoken:UIApplicationStateActive userInfo:[OCMArg any]]);
    
    // when
    [FH sendMetricsWhenAppAwoken:UIApplicationStateActive userInfo:@{}];
    
    // then
    OCMVerify([analyticsMock sendMetricsWhenAppAwoken:UIApplicationStateActive userInfo:[OCMArg any]]);
}


@end

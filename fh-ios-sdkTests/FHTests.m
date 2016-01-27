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

#import "FH.h"
#import "FHInitRequest.h"
#import "FHDefines.h"
#import "FHAct.h"
#import "FHAuthRequest.h"
#import "Nocilla.h"
#import <XCTest/XCTest.h>

float TEST_TIMEOUT = 5.0;
@interface FHTests : XCTestCase
@end

@implementation FHTests

- (void)setUp {
    [[LSNocilla sharedInstance] start];
    
    // Stub our init API
    stubRequest(@"POST", @"http://testing.feedhenry.com/box/srv/1.1/app/init").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody(@"{\"domain\":\"testing\", \"firstTime\" : \"false\", \"hosts\" : { \"environment\" : \"dev\", \"type\" : \"cloud_nodejs\", \"url\" : \"http://dev.test.example.com\" } }");
    
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"init"];
    void (^success)(FHResponse *)=^(FHResponse * res){
        [initExpectation fulfill];
    };
    
    void (^failure)(id)=^(FHResponse * res){
        XCTAssertTrue(false == true, @"Init request failed");
        [initExpectation fulfill];
        NSLog(@"FH init failed. Response = %@", res.rawResponse);
    };
    
    // We need to first init the SDK against our mocked API call, so the subsequent operations will work.
    [FH initWithSuccess:success AndFailure:failure];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            XCTAssertTrue(false == true, @"Init failed within timeout");
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    [super setUp];
}

- (void)tearDown {
    // Looks like there is a bug in Xcode sometimes some tests are not finished
    // if you run a suite of tests together.
    // add the following line seems fix it. see
    // http://stackoverflow.com/questions/12308297/some-of-my-unit-tests-tests-are-not-finishing-in-xcode-4-4
    [NSThread sleepForTimeInterval:1.0];
    [[LSNocilla sharedInstance] stop];
    [super tearDown];
}
/*
- (void)testCloud {
    FHActRequest * action = (FHActRequest *) [FH buildActRequest:@"getTweets" WithArgs:[NSDictionary dictionary]];
    stubRequest(@"POST", @"http://dev.test.example.com/cloud/getTweets").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody(@"{\"tweets\" : [ \"Hi there\", \"Another tweet\"] }");

    XCTestExpectation *cloudExpectation = [self expectationWithDescription:@"testCloud"];
    [action execAsyncWithSuccess:^(FHResponse * actRes){
        XCTAssertTrue( actRes != nil, @"");
        XCTAssertTrue( actRes.parsedResponse != nil, @"");
        XCTAssertTrue( [actRes.parsedResponse objectForKey:@"tweets"] != nil, @"");
        [cloudExpectation fulfill];
    } AndFailure:^(FHResponse * actFailRes){
        NSLog(@"Failed to read tweets. Response = %@", actFailRes.rawResponse);
        XCTAssertTrue(false == true, @"Cloud request failed");
        [cloudExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
*/
- (void)testCloudPlaintextScrewyResponse {
    FHActRequest * action = (FHActRequest *) [FH buildActRequest:@"getPlainText" WithArgs:[NSDictionary dictionary]];
    stubRequest(@"POST", @"http://dev.test.example.com/cloud/getPlainText").
    andReturn(200).
    // We do this on app not found - should really really really fix this
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody(@"\"App not found: someappguid\"");
    
    XCTestExpectation *cloudExpectation = [self expectationWithDescription:@"testCloudPlaintextResponse"];
    [action execAsyncWithSuccess:^(FHResponse * actRes){
        XCTAssertTrue(actRes != nil, @"Cloud request should return OK");
        XCTAssertTrue(actRes.rawResponseAsString != nil, @"Cloud request should return response text as string");
        [cloudExpectation fulfill];
    } AndFailure:^(FHResponse * actFailRes){
        XCTAssertTrue(false == true, @"Cloud request should not fail with plaintext response");
        [cloudExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testCloud500Response {
    FHActRequest * action = (FHActRequest *) [FH buildActRequest:@"getPlainText" WithArgs:[NSDictionary dictionary]];
    stubRequest(@"POST", @"http://dev.test.example.com/cloud/getPlainText").
    andReturn(500).
    withHeaders(@{@"Content-Type": @"text/plain"}).
    withBody(@"Some plain error text like socked hung up");
    
    XCTestExpectation *cloudExpectation = [self expectationWithDescription:@"testCloudPlaintextResponse"];
    [action execAsyncWithSuccess:^(FHResponse * actRes){
        XCTAssertTrue(false == true, @"Cloud request should fail on 500");
        [cloudExpectation fulfill];
    } AndFailure:^(FHResponse * actFailRes){
        XCTAssertTrue(actFailRes != nil, @"Cloud request should return its failed response");
        XCTAssertTrue(actFailRes.rawResponseAsString != nil, @"Cloud request should return response text as string");
        [cloudExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testCloudHttpErrorResponse {
    FHActRequest * action = (FHActRequest *) [FH buildActRequest:@"getPlainText" WithArgs:[NSDictionary dictionary]];
    stubRequest(@"POST", @"http://dev.test.example.com/cloud/getPlainText").
    andFailWithError([NSError errorWithDomain:@"foo" code:123 userInfo:nil]);
    
    XCTestExpectation *cloudExpectation = [self expectationWithDescription:@"testCloudPlaintextResponse"];
    [action execAsyncWithSuccess:^(FHResponse * actRes){
        XCTAssertTrue(false == true, @"Cloud request should fail on http error");
        [cloudExpectation fulfill];
    } AndFailure:^(FHResponse * actFailRes){
        XCTAssertTrue(actFailRes != nil, @"Cloud request should return some failure");
        XCTAssertTrue(actFailRes.error != nil, @"Cloud request should return an error object");
        [cloudExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
/*
- (void)testAuthFailure {
    stubRequest(@"POST", @"http://testing.feedhenry.com/box/srv/1.1/admin/authpolicy/auth").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody(@"{\"message\":\"User login failed\",\"status\":\"error\"}");

    XCTestExpectation *authExpectation = [self expectationWithDescription:@"testAuthFailure"];
    FHAuthRequest* authRequest = [FH buildAuthRequest];
    [authRequest authWithPolicyId:@"MyFeedHenryPolicy" UserId:@"user" Password:@"pass"];
    void (^success)(FHResponse *)=^(FHResponse * res){
        [authExpectation fulfill];
        XCTAssertTrue(true == false, @"Failed auth request should fail");
        NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
    };
    void (^failure)(FHResponse *)=^(FHResponse* res){
        [authExpectation fulfill];
        XCTAssertTrue(res != nil, @"Failed auth request should return something");
        XCTAssertTrue([@"error" isEqualToString:[res.parsedResponse objectForKey:@"status"]], @"Failed auth request should return an error status");
        NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
    };
    [authRequest execAsyncWithSuccess:success AndFailure:failure];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testAuthSuccess {
    stubRequest(@"POST", @"http://testing.feedhenry.com/box/srv/1.1/admin/authpolicy/auth").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody(@"{\"message\":\"Authentication successful\",\"sessionToken\":\"qtqerlp42qom4h5orezrm2uf\",\"status\":\"ok\",\"userId\":\"ciclarke@redhat.com\"}");
    
    XCTestExpectation *authExpectation = [self expectationWithDescription:@"testAuthSuccess"];
    FHAuthRequest* authRequest = [FH buildAuthRequest];
    [authRequest authWithPolicyId:@"MyFeedHenryPolicy" UserId:@"user" Password:@"pass"];
    void (^success)(FHResponse *)=^(FHResponse * res){
        [authExpectation fulfill];
        XCTAssertTrue(res != nil, @"Auth request should return success");
        XCTAssertTrue([res.parsedResponse objectForKey:@"sessionToken"] != nil, @"Auth request should return success");
        NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
    };
    void (^failure)(FHResponse *)=^(FHResponse* res){
        [authExpectation fulfill];
        XCTAssertTrue(true == false, @"Successful auth request should succeed");
        NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
    };
    [authRequest execAsyncWithSuccess:success AndFailure:failure];
    [self waitForExpectationsWithTimeout:TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
*/
// the [FH getDefaultParamsAsHeaders] setup's default params
// containing both raw values as well as json representation
// of foundation collection clases. After JSON refactor, ensure
// that there wasn't any side effect
- (void)testgetDefaultParamsAsHeaders {
    NSDictionary *params = [FH getDefaultParamsAsHeaders];
    XCTAssertNotNil(params, @"params should be not nil");
    // should correctly contain collection class json parsed
    NSArray *cuiidMap = [params[@"X-FH-cuidMap"] objectFromJSONString];
    XCTAssertNotNil(cuiidMap, @"params should contain 'X-FH-cuidMap'");
    XCTAssertTrue(cuiidMap.count == 2, @"X-FH-cuidMap should contain 2 values");
}

@end

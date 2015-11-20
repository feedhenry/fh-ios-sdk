/*
 * JBoss, Home of Professional Open Source.
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
#import "FHCloudRequest.h"

@interface FHCloudRequestTest : XCTestCase

@end

@implementation FHCloudRequestTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBuildUrlForGet {
    // given
    FHCloudProps* props = [[FHCloudProps alloc] initWithCloudProps: @{@"url":@"http://someserver.com"}];
    FHAct* request = [[FHCloudRequest alloc] initWithProps: props];
    request.requestMethod = @"get";
    request.args = @{@"one": @"oneValue", @"two": @"twoValue"};
    request.path = @"/restofurl";
    
    // when
    NSURL* url = request.buildURL;
    
    // then
    if ([url.absoluteString rangeOfString:@"http://someserver.com/restofurl?"].location == NSNotFound) {
        XCTAssertTrue(false, "malformed URL");
    }
    if ([url.absoluteString rangeOfString:@"one=oneValue"].location == NSNotFound) {
        XCTAssertTrue(false, "malformed URL");
    }
    if ([url.absoluteString rangeOfString:@"two=twoValue"].location == NSNotFound) {
        XCTAssertTrue(false, "malformed URL");
    }

}

- (void)testDefaultHeaders {
    // given
    FHCloudProps* props = [[FHCloudProps alloc] initWithCloudProps: @{@"url":@"http://someserver.com"}];
    FHAct* request = [[FHCloudRequest alloc] initWithProps: props];
    
    // when
    NSDictionary* defaultHeader = request.headers;
    
    // then
    XCTAssertEqualObjects(defaultHeader[@"X-FH-appid"], @"APP_ID");
    XCTAssertEqualObjects(defaultHeader[@"X-FH-appkey"], @"APP_KEY");
    XCTAssertEqualObjects(defaultHeader[@"X-FH-connectiontag"], @"CONNECTION_TAG");
    XCTAssertNotNil(defaultHeader[@"X-FH-cuid"]);
    XCTAssertNotNil(defaultHeader[@"X-FH-cuidMap"]);
    XCTAssertEqualObjects(defaultHeader[@"X-FH-destination"], @"ios");
    XCTAssertEqualObjects(defaultHeader[@"X-FH-projectid"], @"PROJECT_ID");
    XCTAssertNotNil(defaultHeader[@"X-FH-sdk_version"]);
    //XCTAssertNotNil(defaultHeader[@"X-FH-sessionToken"]);
}
@end

//
//  FHcloudRequest.m
//  fh-ios-sdk
//
//  Created by Corinne Krych on 04/11/15.
//  Copyright © 2015 FeedHenry. All rights reserved.
//

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

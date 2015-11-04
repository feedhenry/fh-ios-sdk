//
//  FHResponseTest.m
//  fh-ios-sdk
//
//  Created by Corinne Krych on 03/11/15.
//  Copyright © 2015 FeedHenry. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FHResponse.h"

@interface FHResponseTest : XCTestCase

@end

@implementation FHResponseTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseResponseString {
    // given
    FHResponse* response = [[FHResponse alloc] init];
    NSString* jsonString = @"{\"greeting\":{\"french\":\"hello\"}}";
    
    // when
    [response parseResponseString: jsonString];
    
    // then
    XCTAssertEqualObjects(response.parsedResponse, @{@"greeting":@{@"french": @"hello"}});
}

- (void)testParseResponseData {
    // given
    FHResponse* response = [[FHResponse alloc] init];
    NSData* data = [@"{\"greeting\":{\"french\":\"hello\"}}" dataUsingEncoding:NSUTF8StringEncoding];
    // when
    [response parseResponseData: data];
    
    // then
    XCTAssertEqualObjects(response.parsedResponse, @{@"greeting":@{@"french": @"hello"}});
}

@end

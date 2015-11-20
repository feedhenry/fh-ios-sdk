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

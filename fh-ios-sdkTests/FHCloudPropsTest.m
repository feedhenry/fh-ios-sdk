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
#import "FHCloudProps.h"
#import "FHConfig.h"

@interface FHCloudPropsTest : XCTestCase

@end

@implementation FHCloudPropsTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetCloudHostWhenCloudPropsContainsURL {
    // given
    FHCloudProps* props = [[FHCloudProps alloc] initWithCloudProps: @{@"url":@"http://someserver.com"}];
    
    // when
    NSString* url = props.cloudHost;
    
    // then
    XCTAssertEqualObjects(url, @"http://someserver.com/");
}

- (void)testGetCloudHostWhenCloudPropsContainsHost {
    // given
    FHCloudProps* props = [[FHCloudProps alloc] initWithCloudProps: @{@"hosts":@{@"url":@"http://someserver.com"}}];

    // when
    NSString* url = props.cloudHost;
    
    // then
    XCTAssertEqualObjects(url, @"http://someserver.com/");
}

- (void)testGetCloudHostWhenFHConfigContainsModeSetToDev {
    // given
    FHCloudProps* props = [[FHCloudProps alloc] initWithCloudProps: @{@"hosts":@{@"debugCloudUrl":@"http://someserver.com"}}];

    // when
    NSString* url = props.cloudHost;
    
    // then
    XCTAssertEqualObjects(url, @"http://someserver.com/");
}

- (void)testURLWithTrainlingSlash {
    // given
    FHCloudProps* props = [[FHCloudProps alloc] initWithCloudProps: @{@"url":@"http://someserver.com/"}];
    
    // when
    NSString* url = props.cloudHost;
    
    // then
    XCTAssertEqualObjects(url, @"http://someserver.com/");
}

@end

//
//  FHCloudPropsTest.m
//  fh-ios-sdk
//
//  Created by Corinne Krych on 04/11/15.
//  Copyright © 2015 FeedHenry. All rights reserved.
//

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

//
//  FHDataManagerTest.m
//  fh-ios-sdk
//
//  Created by Corinne Krych on 04/11/15.
//  Copyright © 2015 FeedHenry. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FHDataManager.h"
#import <OCMock/OCMock.h>

@interface FHDataManagerTest : XCTestCase

@end

@implementation FHDataManagerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDataRead {
    // given
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    OCMStub([userDefaultsMock objectForKey:@"read-me"]).andReturn(@"here-I-am");
    // when
    [FHDataManager read:@"read-me"];
    
    // then
    OCMVerify([userDefaultsMock objectForKey:@"read-me"]);
}

- (void)testDataRemove {
    // given
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    OCMStub([userDefaultsMock removeObjectForKey:@"remove-me"]);
    // when
    [FHDataManager remove:@"remove-me"];
    
    // then
    OCMVerify([userDefaultsMock removeObjectForKey:@"remove-me"]);
    OCMVerify([userDefaultsMock synchronize]);
}

- (void)testDataSave {
    // given
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    OCMStub([userDefaultsMock removeObjectForKey:@"remove-me"]);
    // when
    [FHDataManager save:@"save-me" withObject:@"me me"];
    
    // then
    OCMVerify([userDefaultsMock setObject:@"me me" forKey:@"save-me"]);
    OCMVerify([userDefaultsMock synchronize]);
}

@end

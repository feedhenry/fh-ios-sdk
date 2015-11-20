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

//
//  FHTests.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHConfigTests.h"
#import "FHConfig.h"
#import <OCMock/OCMock.h>
#import "FHDataManager.h"

@implementation FHConfigTests

- (void) setUp {
    [super setUp];
    // Set-up code here.
}

- (void) tearDown {
    // Tear-down code here.

    [super tearDown];
}

- (void) testReadConfig {
    // given
    
    // when default config file
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];
    
    // then
    XCTAssertEqualObjects([fhconfig getConfigValueForKey:@"host"], @"http://testing.feedhenry.com");
    XCTAssertEqualObjects([fhconfig getConfigValueForKey:@"appid"], @"APP_ID");
    XCTAssertEqualObjects([fhconfig getConfigValueForKey:@"appkey"], @"APP_KEY");
    XCTAssertEqualObjects([fhconfig getConfigValueForKey:@"projectid"], @"PROJECT_ID");
    XCTAssertEqualObjects([fhconfig getConfigValueForKey:@"connectiontag"], @"CONNECTION_TAG");
    XCTAssertEqualObjects([fhconfig getConfigValueForKey:@"mode"], @"dev");
    XCTAssertNil([fhconfig getConfigValueForKey:@"invalidkey"]);

}

- (void) testConfigFileNotFound {
    // given
    
    // when default config file
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];

    // then
    XCTAssertThrowsSpecificNamed([fhconfig performSelector:@selector(initWithFileName:) withObject:@"invalidName"], NSException, @"fhconfigException");
}

-(void) testGetValueExisting {
    // given
    FHConfig *fhconfig = [FHConfig getSharedInstance];
    
    // when
    NSString* appId = [fhconfig getConfigValueForKey:@"appid"];
    
    // then
    XCTAssertEqualObjects(appId, @"APP_ID");
}

-(void) testGetValueEmpty {
    // given
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];
    [fhconfig performSelector:@selector(setConfigValue:ForKey:) withObject:@"" withObject:@"appid"];
    
    // when
    NSString* appId = [fhconfig getConfigValueForKey:@"appid"];
    
    // then
    XCTAssertTrue(appId == nil);
}

-(void) testGetValuefilledWithSpaces {
    // given
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];
    [fhconfig performSelector:@selector(setConfigValue:ForKey:) withObject:@"   " withObject:@"appid"];
    
    // when
    NSString* appId = [fhconfig getConfigValueForKey:@"appid"];
    
    // then
    XCTAssertTrue(appId == nil);
}

-(void) testGetValuefilledNSNull {
    // given
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];
    [fhconfig performSelector:@selector(setConfigValue:ForKey:) withObject:[NSNull null] withObject:@"appid"];
    
    // when
    NSString* appId = [fhconfig getConfigValueForKey:@"appid"];
    
    // then
    XCTAssertTrue(appId == nil);
}

-(void) testUuidAlreadyExistingInDB {
    // given
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];
    id mock = OCMClassMock([FHDataManager class]);
    
    // when
    OCMStub([mock read:@"FHUUID"]).andReturn(@"ABCD");
    NSString* uuid = [fhconfig uuid];
    
    // then assert, verify
    XCTAssertEqualObjects(uuid, @"ABCD");
    OCMVerify([mock read:@"FHUUID"]);
}

-(void) testNewUuid {
    // given
    FHConfig *fhconfig = [FHConfig performSelector:@selector(config)];
    id mock = OCMClassMock([FHDataManager class]);
    
    // when
    OCMStub([mock read:@"FHUUID"]).andReturn(nil);
    NSString* uuid = [fhconfig uuid];
    
    // then assert, verify
    XCTAssertNotNil(uuid);
    OCMVerify([mock save:@"FHUUID" withObject:[OCMArg any]]);
}

@end

//
//  FHTests.m
//  FH
//
//  Created by Wei Li on 10/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHTests.h"
#import "MockFHHttpClient.h"
#import "FHInitRequest.h"
#import "FH.h"
#import "FHResponse.h"
#import "FHAct+SetHttpClient.h"

@implementation FHTests

- (void)setUp
{
  [super setUp];
  
  // Set-up code here.
}

- (void)tearDown
{
  //Looks like there is a bug in Xcode sometimes some tests are not finished if you run a suite of tests together.
  //add the following line seems fix it. see http://stackoverflow.com/questions/12308297/some-of-my-unit-tests-tests-are-not-finishing-in-xcode-4-4
  [NSThread sleepForTimeInterval:1.0];
  [super tearDown];
}

- (void) testInit 
{
  MockFHHttpClient* httpClient = [[MockFHHttpClient alloc]init];
  FHInitRequest * init   = [[FHInitRequest alloc]init];
  init.method       = FH_INIT;
  [init setHttpClient:httpClient];
  void (^success)(FHResponse *)=^(FHResponse * res){
    NSDictionary* data = res.parsedResponse;
    STAssertTrue(nil != [data valueForKey:@"domain"], @"Can not find domain in init response");
    STAssertTrue(nil != [data objectForKey:@"hosts"], @"Can not find hosts in init response");
  };
  [init execWithSuccess:success AndFailure:nil];
}


-(void) testCloud
{
  MockFHHttpClient* httpClient = [[MockFHHttpClient alloc]init];
  
  NSMutableDictionary* initRes = [NSMutableDictionary dictionary];
  NSMutableDictionary* innerP = [NSMutableDictionary dictionary];
  [innerP setValue:@"http://dev.test.example.com" forKey:@"debugCloudUrl"];
  [innerP setValue:@"http://live.test.example.com" forKey:@"releaseCloudUrl"];
  
  [initRes setValue:@"test" forKey:@"domain"];
  [initRes setValue:FALSE forKey:@"firstTime"];
  [initRes setValue:innerP forKey:@"hosts"];
  
  FHActRequest * cloud = [[FHActRequest alloc]initWithProps:initRes];
  cloud.method = FH_CLOUD;
  [cloud setHttpClient:httpClient];
  
  NSURL* url = [cloud buildURL];
  STAssertTrue([[url host] isEqualToString:@"dev.test.example.com"], @"Cloud host url should equal to development cloud host");
  
  void (^success)(FHResponse *)=^(FHResponse * res){
    NSDictionary* data = res.parsedResponse;
    STAssertTrue(nil != [data valueForKey:@"status"], @"Can not find status in init response");
  };
  
  [cloud execWithSuccess:success AndFailure:nil];
}

-(void) testAuth
{
  MockFHHttpClient* httpClient = [[MockFHHttpClient alloc]init];
  
  NSMutableDictionary* initRes = [NSMutableDictionary dictionary];
  NSMutableDictionary* innerP = [NSMutableDictionary dictionary];
  [innerP setValue:@"http://dev.test.example.com" forKey:@"development-url"];
  [innerP setValue:@"http://live.test.example.com" forKey:@"live-url"];
  
  [initRes setValue:@"test" forKey:@"domain"];
  [initRes setValue:FALSE forKey:@"firstTime"];
  [initRes setValue:innerP forKey:@"hosts"];

  NSMutableDictionary* authRes = [NSMutableDictionary dictionary];
  [authRes setValue:@"testToken" forKey:@"sessionToken"];
  
  FHAuthReqeust* auth = [[FHAuthReqeust alloc] initWithProps:initRes];
  auth.method = FH_AUTH;
  [auth setHttpClient:httpClient];
  [auth authWithPolicyId:@"testPolicy"];
  
  void (^success)(FHResponse *)=^(FHResponse * res){
    NSDictionary* data = res.parsedResponse;
    STAssertTrue(nil != [data valueForKey:@"sessionToken"], @"Can not find sessionToken in init response");
  };
  
  [auth execWithSuccess:success AndFailure:nil];
}

@end

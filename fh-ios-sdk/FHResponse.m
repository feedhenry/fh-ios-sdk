//
//  FHResponse.m
//  fh-ios-sdk
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHResponse.h"
#import "JSONKit.h"

@implementation FHResponse
@synthesize rawResponse, rawResponseAsString, parsedResponse;



- (void)parseResponseString:(NSString *)res{
    self.parsedResponse =  [res objectFromJSONString];    
}

- (void)parseResponseData:(NSData *)dat{
    self.parsedResponse = [dat objectFromJSONData];
}

- (void)dealloc{
    rawResponse         = nil;
    [rawResponse release];
    rawResponseAsString = nil;
    [rawResponseAsString release];
    parsedResponse      = nil;
    [parsedResponse release];
    [super dealloc];
    
}

@end

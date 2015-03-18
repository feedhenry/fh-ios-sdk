//
//  FHResponse.m
//  fh-ios-sdk
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHResponse.h"
#import "FHJSON.h"

@implementation FHResponse

- (void)parseResponseString:(NSString *)res{
    self.parsedResponse =  [res objectFromJSONString];    
}

- (void)parseResponseData:(NSData *)dat{
    self.parsedResponse = [dat objectFromJSONData];
}

@end

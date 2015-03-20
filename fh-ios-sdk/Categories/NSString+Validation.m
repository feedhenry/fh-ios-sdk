//
//  NSString+Validation.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL)validateGuid {
    return ([self length] == 24);
}

- (BOOL)validateDomain {
    // TODO validate domain
    return YES;
}

- (BOOL)validateInsId {
    return YES;
}

- (BOOL)validateApiUrl {
    return YES;
}

@end

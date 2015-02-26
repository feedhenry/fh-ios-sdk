//
//  NSString+Validation.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 27/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)


- (BOOL)validateGuid{
    return ([self length]==24);
}

- (BOOL)validateDomain{
   //TODO validate domain
    return YES; 
}

- (BOOL)validateInsId{
    return YES;
}

- (BOOL)validateApiUrl{
    return YES;
}



@end

//
//  FHJSON.m
//  fh-ios-sdk
//
//  Copyright (c) 2015 FeedHenry. All rights reserved.
//

#import "FHJSON.h"

@implementation NSString (JSON)

- (id)objectFromJSONString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data objectFromJSONData];
}

@end

@implementation NSData (JSON)

- (id)objectFromJSONData {
    return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:nil];
}

@end

@implementation NSArray (JSON)

- (NSString *)JSONString {
    NSData *data = [self JSONData];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSData *)JSONData {
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
}

@end

@implementation NSDictionary (JSON)

- (NSString *)JSONString {
    NSData *data = [self JSONData];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSData *)JSONData {
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
}

@end
//
//  FHJSON.h
//  fh-ios-sdk
//
//  Copyright (c) 2015 FeedHenry. All rights reserved.
//

@interface NSString (JSON)

- (NSString *)JSONString;
- (id)objectFromJSONString;

@end

@interface NSData (JSON)

- (id)objectFromJSONData;

@end

@interface NSArray (JSON)

- (NSString *)JSONString;
- (NSData *)JSONData;

@end

@interface NSDictionary (JSON)

- (NSString *)JSONString;
- (NSData *)JSONData;

@end

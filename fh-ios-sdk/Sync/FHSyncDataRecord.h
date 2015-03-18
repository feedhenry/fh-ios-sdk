//
//  FHSyncDataRecord.h
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHSyncDataRecord : NSObject

@property(nonatomic, strong) NSString* hashValue;
@property(nonatomic, strong) NSDictionary* data;
@property(nonatomic, strong) NSString* uid;

- (instancetype) init;
- (instancetype) initWithData: (NSDictionary*) data;
- (NSDictionary*) JSONData;
+ (FHSyncDataRecord*) objectFromJSONData:(NSDictionary*) jsonData;
- (NSString*) JSONString;
+ (FHSyncDataRecord*) objectFromJSONString:(NSString*) jsonStr;
@end

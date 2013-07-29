//
//  FHSyncDataRecord.h
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHSyncDataRecord : NSObject
{
  NSString* _hashValue;
  NSDictionary* _data;
  NSString* _uid;
}

@property NSString* hashValue;
@property NSDictionary* data;
@property NSString* uid;

- (id) init;
- (id) initWithData: (NSDictionary*) data;
- (NSDictionary*) JSONData;
+ (FHSyncDataRecord*) objectFromJSONData:(NSDictionary*) jsonData;
- (NSString*) JSONString;
+ (FHSyncDataRecord*) objectFromJSONString:(NSString*) jsonStr;
@end

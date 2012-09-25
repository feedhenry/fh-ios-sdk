//
//  FHSyncNotificationMessage.h
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHSyncNotificationMessage : NSObject
{
  NSString* _dataId;
  NSString* _uid;
  NSString* _codeMessage;
  NSString* _extraMessage;
}

- (id) initWithDataId:(NSString*) dataId AndUID:(NSString*) uid AndCode:(NSString*) code AndMessage:(NSString*) message;
- (NSString*) getDataId;
- (NSString*) getUID;
- (NSString*) getCode;
- (NSString*) getMessage;
- (NSString*) description;

@end

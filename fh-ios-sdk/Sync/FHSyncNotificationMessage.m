//
//  FHSyncNotificationMessage.m
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHSyncNotificationMessage.h"

@implementation FHSyncNotificationMessage

- (id) initWithDataId:(NSString *)dataId AndUID:(NSString *)uid AndCode:(NSString *)code AndMessage:(NSString *)message
{
  self = [super init];
  if(self){
    _dataId = dataId;
    _uid = uid;
    _codeMessage = code;
    _extraMessage = message;
  }
  return self;
}

- (NSString*) getDataId
{
  return _dataId;
}

- (NSString*) getUID
{
  return _uid;
}

- (NSString*) getCode
{
  return _codeMessage;
}

-(NSString*) getMessage
{
  return _extraMessage;
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"dataId:%@-uid:%@-code:%@-message:%@", _dataId, _uid, _codeMessage, _extraMessage];
}
@end

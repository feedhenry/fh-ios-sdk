//
//  FHSyncNotificationMessage.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncNotificationMessage.h"

@implementation FHSyncNotificationMessage

- (instancetype)initWithDataId:(NSString *)dataId
                        AndUID:(NSString *)uid
                       AndCode:(NSString *)code
                    AndMessage:(NSString *)message {
    self = [super init];
    if (self) {
        _dataId = dataId;
        _UID = uid;
        _code = code;
        _message = message;
    }
    return self;
}

- (NSString *)description {
    return [NSString
        stringWithFormat:@"dataId:%@-uid:%@-code:%@-message:%@", _dataId, _UID, _code, _message];
}

@end

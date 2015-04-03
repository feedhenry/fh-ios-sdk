//
//  FHSyncDelegate.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncNotificationMessage.h"

@protocol FHSyncDelegate <NSObject>

@required

- (void)onSyncStarted:(FHSyncNotificationMessage *)message;

- (void)onSyncCompleted:(FHSyncNotificationMessage *)message;

- (void)onUpdateOffline:(FHSyncNotificationMessage *)message;

- (void)onCollisionDetected:(FHSyncNotificationMessage *)message;

- (void)onUpdateFailed:(FHSyncNotificationMessage *)message;

- (void)onUpdateApplied:(FHSyncNotificationMessage *)message;

- (void)onDeltaReceived:(FHSyncNotificationMessage *)message;

- (void)onClientStorageFailed:(FHSyncNotificationMessage *)message;

@end

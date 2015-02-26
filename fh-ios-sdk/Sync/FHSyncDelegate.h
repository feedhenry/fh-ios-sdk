//
//  FHSyncDelegate.h
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncNotificationMessage"

@protocol FHSyncDelegate <NSObject>

@required

- (void) onSyncStarted:(FHSyncNotificationMessage *) message;
- (void) onSyncCompleted:(FHSyncNotificationMessage *) message;
- (void) onUpdateOffline:(FHSyncNotificationMessage *) message;
- (void) onCollisionDetected:(FHSyncNotificationMessage *) message;
- (void) onUpdateFailed:(FHSyncNotificationMessage* ) message;
- (void) onUpdateApplied:(FHSyncNotificationMessage* ) message;
- (void) onDeltaReceived:(FHSyncNotificationMessage *) message;
- (void) onClientStorageFailed:(FHSyncNotificationMessage *) message;
@end

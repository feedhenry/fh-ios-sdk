//
//  FHCloudRequest.h
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

/** Calling cloud side functions on FeedHenry */

#import "FHAct.h"

@interface FHActRequest : FHAct{
  NSString * remoteAction;
}

/** The cloud side function name */
@property(nonatomic,retain)NSString * remoteAction;

@end

//
//  FHCloudRequest.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHAct.h"

/**
 Calling cloud side functions on FeedHenry
 */
@interface FHActRequest : FHAct

/** The cloud side function name */
@property (nonatomic, strong) NSString *remoteAction;

@end

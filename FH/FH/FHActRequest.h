//
//  FHCloudRequest.h
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHAct.h"

@interface FHActRequest : FHAct{
  NSString * remoteAction;
}
@property(nonatomic,retain)NSString * remoteAction;
@end

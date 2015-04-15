//
//  FHCloudRequest.h
//  FH
//
//  Created by Wei Li on 28/04/2014.
//  Copyright (c) 2014 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHAct.h"

@interface FHCloudRequest : FHAct {
  NSString* path;
}

/** The path of the cloud API */
@property(nonatomic,retain)NSString * path;

- (id)initWithProps:(FHCloudProps *) props;

@end

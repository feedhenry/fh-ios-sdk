//
//  FHRemote.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHAct.h"
@interface FHRemote : FHAct{
    NSURL * url;
    NSDictionary * appProperties;
    NSString * remoteAction;
}
@property(nonatomic,retain)NSURL * url;
@property(nonatomic,retain)NSString * remoteAction;

- (id)initWithRemoteAction:(NSString *)act;
- (void)buildURL;

@end

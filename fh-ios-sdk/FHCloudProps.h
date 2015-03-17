//
//  FHCloudProps.h
//  FH
//
//  Created by Wei Li on 28/04/2014.
//  Copyright (c) 2014 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHCloudProps : NSObject {
  NSDictionary* cloudProps;
  NSString* cloudHost;
}

@property (strong) NSDictionary* cloudProps;
@property (strong) NSString* cloudHost;

- (instancetype) initWithCloudProps:(NSDictionary*) aCloudProps;

- (NSString*) getCloudHost;


@end

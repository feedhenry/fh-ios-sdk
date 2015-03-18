//
//  FHCloudProps.h
//  FH
//
//  Created by Wei Li on 28/04/2014.
//  Copyright (c) 2014 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHCloudProps : NSObject

@property (nonatomic, strong, readonly) NSDictionary* cloudProps;
@property (nonatomic, strong, readonly) NSString* cloudHost;

- (instancetype) initWithCloudProps:(NSDictionary*) aCloudProps;

@end

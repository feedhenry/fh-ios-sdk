//
//  FHCloudProps.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

@interface FHCloudProps : NSObject

@property (nonatomic, strong, readonly) NSDictionary *cloudProps;
@property (nonatomic, strong, readonly) NSString *cloudHost;
@property (nonatomic, strong, readonly) NSString *env;

- (instancetype)initWithCloudProps:(NSDictionary *)aCloudProps;

@end

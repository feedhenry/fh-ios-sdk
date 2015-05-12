//
//  FHPushConfig.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#ifndef Pods_FHPushConfig_h
#define Pods_FHPushConfig_h

/**
 A utility class to get the unified push configurations.
 */
@interface FHPushConfig : NSObject

/** Access categories */
@property (nonatomic, strong) NSArray *categories;
/** Return vendorIdentifier */
@property (nonatomic, strong) NSString *alias;

@end

#endif



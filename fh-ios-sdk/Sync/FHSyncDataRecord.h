//
//  FHSyncDataRecord.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

@interface FHSyncDataRecord : NSObject

@property (nonatomic, strong) NSString *hashValue;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *uid;

- (instancetype)init;

- (instancetype)initWithData:(NSDictionary *)data;

- (NSDictionary *)JSONData;

+ (FHSyncDataRecord *)objectFromJSONData:(NSDictionary *)jsonData;

- (NSString *)JSONString;

+ (FHSyncDataRecord *)objectFromJSONString:(NSString *)jsonStr;

@end

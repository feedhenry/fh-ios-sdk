//
//  ShoppingItem.m
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import "ShoppingItem.h"


@implementation ShoppingItem

@dynamic created;
@dynamic name;
@dynamic uid;

- (NSString*) description
{
  return [NSString stringWithFormat:@"uid=%@::name=%@::created=%@", self.uid, self.name, self.created];
}
@end

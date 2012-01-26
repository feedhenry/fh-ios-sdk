//
//  FH.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FH.h"
#import "FHAct.h"
static FH * shared;
@implementation FH

+(FH * )shared{
    @synchronized(self)
    {
        if (shared == NULL)
            shared = [[FH alloc] init];
    }
    
    return(shared);
}

- (void)makeRemoteCall{
    
}

- (void)makeRemoteCallWithSuccess:(void (^)(id success))suc AndFailure:(void (^)(id failed))fail{

}

- (void)delegateResponse{
    
}

- (FHAct *)act:(NSString *)act WithResponseDelegate:(id<FHResponseDelegate>)del{
    FH * fh     = [[[FHAct alloc]init] autorelease];
    fh.method   = act;
    fh.del      = del;
    return fh;
}

@end

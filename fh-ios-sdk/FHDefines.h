//
//  FHDefines.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 30/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//


typedef enum{
    FH_ACTION_ACT,
    FH_ACTION_AUTH,
    FH_ACTION_LOCAL_DATA_STORE,
    FH_ACTION_RETRIEVE_LOCAL_DATA,
    FH_ACTION_PERSISTANT_DATA_STORE,
    FH_ACTION_RETRIEVE_PERSISTANT_DATA
}FH_ACTION;

typedef enum{
    FH_LOCATION_REMOTE,
    FH_LOCATION_DEVICE   
}FH_LOCATION;

#define FH_ACT @"act"
#define FH_AUTH @"auth"
#define FH_DATA @"data"
#define FH_REMOTE_DATA @"remotedata"
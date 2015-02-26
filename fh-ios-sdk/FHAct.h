//
//  FHAct.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

//TODO: need to review this to see which properties and methos should be private

/** Base class for all API request classes */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FHDefines.h"
#import "FHResponseDelegate.h"
#import "FHCloudProps.h"

@class FHHttpClient;

@interface FHAct : NSObject{
  NSString * method;
  NSMutableDictionary * args;
  id<FHResponseDelegate> __weak delegate;
  NSUInteger cacheTimeout;
  FHCloudProps * cloudProps;
  BOOL async;
  FHHttpClient * httpClient;
  NSDictionary* headers;
  NSString* requestMethod;
  NSTimeInterval requestTimeout;
}

/** The type of the request */
@property(strong)NSString * method;

/** The HTTP request method */
@property (retain) NSString* requestMethod;

/** The timeout value of the requesst. Default to 60 seconds */
@property (assign) NSTimeInterval requestTimeout;

/** The response delegate for this request.
 
 @see FHResponseDelegate
 */
@property(weak, readwrite)id<FHResponseDelegate> delegate;


/** The HTTP headers of the request */
@property(retain) NSDictionary* headers;

/** How long the response should be cached for.
 
 The response won't be cached if it's not set.
 
 */
@property NSUInteger cacheTimeout;

/** @name Set properties of the API request */


/** Create a new instance of the API request.
 */
- (id) init;

/** Set the parameters for the API request. 
 
 @param arguments The data that will be sent to the request
 */
- (void)setArgs:(NSDictionary *) arguments;

/** Get the parameters for the API request. 
 
 @return Returns the parameters.
 */
- (NSDictionary *)args;

/** Get the parameters for the API request as NSString.
 
 @return Returns the parameters as string.
 */
- (NSString *) argsAsString;

/** Get the URL of the API request 
 
 @return Returns the URL 
 */
- (NSURL *)buildURL;

/** Get the relative path of the API request 
 
 @return The API request's relative path
 */
- (NSString *) getPath;

/** Get default parameters for certain API requests.
 
 @return Pamaters for certain API requests
 */
- (NSMutableDictionary *) getDefaultParams;

/** If the API request will be running asynchronously.
 
 @return YES if it's asynchronous otherwise NO
 */
- (BOOL) isAsync;

/** Return the combined HTTP headers for the request */
- (NSDictionary *) buildHeaders;

/** @name Execute the API request*/

/** Excute the API request synchronously with the given success and failure blocks. 
 
 @warning This will block the application's main UI thread
 @param sucornil The block to be executed if the request is successful. If it's nil, the delegate's [FHResponseDelegate requestDidSucceedWithResponse:] will be exectued.
 @param failornil The block to be executed if the request is failed. If it's nil, the delegate's [FHResponseDelegate requestDidFailWithResponse:] will be exectued.
 @see FHResponseDelegate
 */
- (void) execWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

/** Excute the API request asynchronously with the given success and failure blocks. 
 
 This is the recommended way to execute the request. 
 
 @param sucornil The block to be executed if the request is successful. If it's nil, the delegate's [FHResponseDelegate requestDidSucceedWithResponse:] will be exectued.
 @param failornil The block to be executed if the request is failed. If it's nil, the delegate's [FHResponseDelegate requestDidFailWithResponse:] will be exectued.
 @see FHResponseDelegate
 */
- (void) execAsyncWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;



@end

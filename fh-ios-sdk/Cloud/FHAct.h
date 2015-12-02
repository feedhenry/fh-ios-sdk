/* * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <UIKit/UIKit.h>

#import "FHResponseDelegate.h"
#import "FHCloudProps.h"

@class FHHttpClient;

/**
 Base class for all API request classes
 */
@interface FHAct : NSObject {
  @protected
    NSMutableDictionary *_args;
    NSMutableDictionary *_headers;
    FHCloudProps *_cloudProps;
    BOOL _async;
    FHHttpClient *_httpClient;
}

/** The type of the request */
@property (nonatomic, strong) NSString *method;

/** The HTTP request method */
@property (nonatomic, strong) NSString *requestMethod;

/** The timeout value of the request  Default to 60 seconds */
@property (nonatomic, assign) NSTimeInterval requestTimeout;

/** The response delegate for this request.

@see FHResponseDelegate
*/
@property (nonatomic, weak) id<FHResponseDelegate> delegate;

/** The HTTP headers of the request */
@property (nonatomic, strong) NSDictionary *headers;

/** How long the response should be cached for. The response won't be cached if it's not set.
*/
@property (nonatomic, assign) NSUInteger cacheTimeout;

/** Set/Get the parameters for the API request.

@return Returns the parameters.
*/
@property (nonatomic, strong) NSDictionary *args;

/** Get the parameters for the API request as NSString.

@return Returns the parameters as string.
*/
- (NSString *)argsAsString;

/** Get the URL of the API request

@return Returns the URL
*/
@property (nonatomic, strong, readonly) NSURL *buildURL;

/** The relative path of the API request

@return The API request's relative path
*/
@property (nonatomic, strong) NSString *path;

/** Get default parameters for certain API requests.

@return Pamaters for certain API requests
*/
@property (nonatomic, strong, readonly) NSDictionary *defaultParams;

/** Init a new request and set the FHCloudProps
 @param props the cloud app details
 */
- (instancetype)initWithProps:(FHCloudProps *)props;

/** Excute the API request synchronously with the given success and failure
blocks.

@warning This will block the application's main UI thread
@param sucornil The block to be executed if the request is successful. If it's
nil, the delegate's [FHResponseDelegate requestDidSucceedWithResponse:] will be
exectued.
@param failornil The block to be executed if the request is failed. If it's nil,
the delegate's [FHResponseDelegate requestDidFailWithResponse:] will be
exectued.

@see FHResponseDelegate
*/
- (void)execWithSuccess:(void (^)(FHResponse *success))sucornil AndFailure:(void (^)(FHResponse *failed))failornil;

/** Excute the API request asynchronously with the given success and failure
blocks.

This is the recommended way to execute the request.

@param sucornil The block to be executed if the request is successful. If it's
nil, the delegate's [FHResponseDelegate requestDidSucceedWithResponse:] will be
exectued.
@param failornil The block to be executed if the request is failed. If it's nil,
the delegate's [FHResponseDelegate requestDidFailWithResponse:] will be
exectued.
@see FHResponseDelegate
*/
- (void)execAsyncWithSuccess:(void (^)(FHResponse *success))sucornil
                  AndFailure:(void (^)(FHResponse *failed))failornil;

@end

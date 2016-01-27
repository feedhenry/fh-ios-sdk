/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
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

typedef NS_ENUM(NSInteger, FH_ACTION) {
    FH_ACTION_ACT,
    FH_ACTION_AUTH,
    FH_ACTION_INIT,
    FH_ACTION_CLOUD
};

#define FH_ACT @"act"
#define FH_CLOUD @"cloud"
#define FH_AUTH @"auth"
#define FH_INIT @"init"
#define FH_SDK_VERSION @"3.1.1"
#define SESSION_TOKEN_KEY @"sessionToken"
#define VERIFY_SESSION_PATH @"/box/srv/1.1/admin/authpolicy/verifysession"
#define REVOKE_SESSION_PATH @"/box/srv/1.1/admin/authpolicy/revokesession"

// cater for debug/release mode of logging
#ifdef DEBUG
#define DLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLog(...) /* */
#endif

/*
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

#import "FHJSON.h"

@implementation NSString (JSON)

- (id)objectFromJSONString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data objectFromJSONData];
}

@end

@implementation NSData (JSON)

- (id)objectFromJSONData {
    return
        [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:nil];
}

@end

@implementation NSArray (JSON)

- (NSString *)JSONString {
    NSData *data = [self JSONData];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return nil;
}

- (NSData *)JSONData {
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
}

@end

@implementation NSDictionary (JSON)

- (NSString *)JSONString {
    NSData *data = [self JSONData];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return nil;
}

- (NSData *)JSONData {
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
}

@end
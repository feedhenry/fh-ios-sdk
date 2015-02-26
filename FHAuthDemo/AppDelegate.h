//
//  AppDelegate.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UITabBarController * tabBar;
}

@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic) UITabBarController *tabBar;
@end

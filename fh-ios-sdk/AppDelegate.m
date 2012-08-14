//
//  AppDelegate.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "AppDelegate.h"
#import "EventsViewController.h"
#import "FH.h"
#import "RootViewController.h"
#import "AuthViewController.h"
@implementation AppDelegate

@synthesize window = _window , tabBar;

- (void)dealloc
{
  [_window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [FH init];
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
  
  
  
  
  UITabBarController * tabBarController = [[UITabBarController alloc]init];
  self.tabBar = tabBarController;
  [tabBarController release];
  RootViewController * actTab     = [[[RootViewController alloc]initWithNibName:nil bundle:nil] autorelease];
  
  actTab.tabBarItem.title     = @"FHCloud";
  actTab.tabBarItem.tag       = 101;
  
  RootViewController * authTab     = [[[RootViewController alloc]initWithNibName:nil bundle:nil] autorelease];
  authTab.tabBarItem.title = @"FHAuth";
  authTab.tabBarItem.tag = 102;
  
  self.tabBar.viewControllers = [NSArray arrayWithObjects:actTab, authTab, nil];
  
  
  [self.window setRootViewController:self.tabBar];
  
  [self.window makeKeyAndVisible];
  
  
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

@end

//
//  AuthViewController.h
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
  UITableView* authList;
  NSArray* authMethods;
}

@property(nonatomic, retain) IBOutlet UITableView* authList;
@property(nonatomic, retain) NSArray* authMethods;
@end

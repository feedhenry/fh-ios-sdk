//
//  EventsViewController.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    UITableView * eventsTable;
    NSArray * events;
}
@property(nonatomic,retain)IBOutlet UITableView * eventsTable;
@property(nonatomic,retain)NSArray * events;

@end

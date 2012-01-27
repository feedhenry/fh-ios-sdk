//
//  EventsViewController.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHResponseDelegate.h"
@interface EventsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FHResponseDelegate>{
    UITableView * eventsTable;
    NSArray * events;
}
@property(nonatomic,retain)IBOutlet UITableView * eventsTable;


@end

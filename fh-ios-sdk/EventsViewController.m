//
//  EventsViewController.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "EventsViewController.h"
#import "FH.h"
#import "LoginController.h"
@implementation EventsViewController
@synthesize eventsTable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   
    self.navigationItem.title = @"Local Events";
    
    events = [NSArray array];
    void (^success)(FHResponse *)=^(FHResponse * res){
        
        NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
        events = (NSArray *) res.parsedResponse;
        [eventsTable reloadData];
    };
    
    void (^failure)(id)=^(id res){
        NSLog(@"failed");  
    };
    [super viewDidLoad];
    
     
    
    // Do any additional setup after loading the view from its nib.
    FHRemote * action = (FHRemote *) [FH buildAction:FH_ACTION_ACT];
    action.remoteAction = @"getEventsByLocation";
    action.cacheTimeout = (60 * 60 * 2); //2 hours
    [action setArgs:[NSDictionary dictionaryWithObjectsAndKeys:@"-7.127205999999999",@"longi",@"52.25227",@"lati", nil]];
    [FH act:action WithSuccess:success AndFailure:failure];
    
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [events count];
}

#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellid = @"cellid";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell == nil){
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
    }
    NSLog(@"event = %@",[events objectAtIndex:[indexPath row]]);
    cell.textLabel.text = (NSString *)[[events objectAtIndex:[indexPath row]]objectForKey:@"title"];
    return cell;
}

#pragma mark memory

- (void)dealloc{
    eventsTable = nil;
    [eventsTable release];
    events = nil;
    [events release];
    [super dealloc];
}

#pragma mark FHResponseDelegate

- (void)requestDidSucceedWithResponse:(FHResponse *)res{
    NSLog(@"delegate method called with response %@",res.parsedResponse);
    events = (NSArray *) res.parsedResponse;
    [eventsTable reloadData];
}


- (void)requestDidFailWithError:(NSError *)er{
    
}

@end

//
//  RootViewCotroller.m
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import "RootViewCotroller.h"
#import <CoreData/CoreData.h>
#import "ShoppingItem.h"
#import "DetailsViewController.h"

@interface RootViewCotroller ()

@end

@implementation RootViewCotroller

@synthesize items;
@synthesize addButton;
@synthesize dataManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  self.editButtonItem.enabled = NO;
  self.navigationItem.leftBarButtonItem = self.addButton;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataUpdated:) name:kAppDataUpdatedNotification object:nil];
}

- (void) viewDidUnload
{
  self.items = nil;
  self.addButton = nil;
}

- (void) onDataUpdated:(NSNotification*) note
{
  self.items = [dataManager listItems];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onAddButtonTap:(id) sender
{
  NSLog(@"add button tapped");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSDateFormatter *dateFormatter = nil;
  if (dateFormatter == nil) {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  }
  
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
    ShoppingItem* item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", item.name, [dateFormatter stringFromDate:item.created]];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ShoppingItem* item = nil;
  if ([[segue identifier] isEqualToString:@"showExistingItemDetails"]) {
    item = [self.items objectAtIndex:[self.tableView indexPathForCell:sender].row];
    DetailsViewController* dest = [segue destinationViewController];
    dest.item = item;
    dest.dataManager = self.dataManager;
    dest.action = @"update";
  } else if ([[segue identifier] isEqualToString:@"showNewItemDetails"]) {
    item = [dataManager getItem];
    DetailsViewController* dest = [segue destinationViewController];
    dest.item = item;
    dest.dataManager = self.dataManager;
    dest.action = @"create";
  }
  
}

@end

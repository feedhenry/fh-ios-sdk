//
//  ViewController.m
//  FHSyncTestApp
//
//  Created by Wei Li on 25/09/2012.
//  Copyright (c) 2012 Wei Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "FH.h"
#import "FHSyncClient.h"
#import "FHSyncNotificationMessage.h"
#import "FHResponse.h"

@interface ViewController ()
{
  FHSyncClient* _fhSyncClient;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  [FH initWithSuccess:^(FHResponse* fhres){
    [self startSyncClient];
    
    
  } AndFailure:^(FHResponse* fhres){
    NSLog(@"Init Failed. Error: %@", fhres.error);
    [self startSyncClient];
  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startSyncClient
{
  _fhSyncClient = [[FHSyncClient getInstance] retain];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncMessage:) name:kFHSyncStateChangedNotification object:nil];
  FHSyncConfig* conf = [[FHSyncConfig alloc] init];
  conf.notifySyncStarted = YES;
  conf.notifySyncCompleted = YES;
  [_fhSyncClient initWithConfig:conf];
  [conf release];
  [_fhSyncClient manageWithDataId:@"foo" AndQuery:[NSMutableDictionary dictionary]];
}

- (void) onSyncMessage:(NSNotification*) note
{
  FHSyncNotificationMessage* msg = (FHSyncNotificationMessage*) [note object];
  NSLog(@"Got notification %@", msg);
  NSString* code = [msg getCode];
  if([code isEqualToString:SYNC_COMPLETE_MESSAGE]){
    NSDictionary* data = [_fhSyncClient listWithDataId:@"foo"];
    [self performSelectorOnMainThread:@selector(setResultText:) withObject:data waitUntilDone:NO];
  }
}

- (void) setResultText:(NSDictionary*) data
{
  if(data){
    resultView.text = [NSString stringWithFormat:@"%f \n %@", [[NSDate date] timeIntervalSince1970], [data JSONString]];
  }
}

- (IBAction)selectCreateButton:(id)sender
{
  NSMutableDictionary* data = [NSMutableDictionary dictionary];
  NSString* str = [NSString stringWithFormat:@"Data created by ios client %f", [[NSDate date] timeIntervalSince1970]];
  [data setObject:str forKey:@"ios"];
  [_fhSyncClient createWithDataId:@"foo" AndData:data];
}

- (IBAction)selectReadButton:(id)sender
{
  NSString* uid = uidField.text;
  if(![uid isEqualToString:@""]){
    NSDictionary* data = [_fhSyncClient readWidthDataId:@"foo" AndUID:uid];
    [self setResultText:data];
  }
}

- (IBAction)selectUpdateButton:(id)sender
{
  NSString* uid = uidField.text;
  if(![uid isEqualToString:@""]){
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    NSString* str = [NSString stringWithFormat:@"Data updated by ios client %f", [[NSDate date] timeIntervalSince1970]];
    [data setObject:str forKey:@"ios"];
    [_fhSyncClient updateWithDataId:@"foo" AndUID:uid AndData:data];
  }
}

- (IBAction)selectDeleteButton:(id)sender
{
  NSString* uid = uidField.text;
  if(![uid isEqualToString:@""]){
    [_fhSyncClient deleteWithDataId:@"foo" AndUID:uid];
  }
}

@end

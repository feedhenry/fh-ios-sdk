#import "ViewController.h"
#import <FH/FH.h>

static NSString * const MessageCellIdentifier = @"MessageCell";

@interface ViewController ()

@end

@implementation ViewController

NSMutableArray* _messages;

- (void)viewDidLoad {
    _messages = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:@"message_received" object:nil];
    void (^success)(FHResponse *)=^(FHResponse * res){
        NSLog(@"FH init succeeded. Response = %@", res.rawResponse);
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSLog(@"FH init failed. Response = %@", res.rawResponse);
    };
    
    //View loaded, you can uncomment the following code to init FH object
    [FH initWithSuccess:success AndFailure:failure];
}

- (void)messageReceived:(NSNotification*)notification {
    NSLog(@"received %@", notification.object);
    [_messages addObject:notification.object];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: MessageCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _messages[indexPath.row];
    return cell;
}

@end

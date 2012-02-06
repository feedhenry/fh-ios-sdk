# FeedHenry iOS SDK

This SDK should provide you with all you'll need to start developing cloud-connected apps with the FeedHenry platform.

### Examples

FeedHenry Action Call:

	void (^success)(FHResponse *)=^(FHResponse * res){
	    NSLog(@"%@", res.parsedResponse);
	};
	    
	void (^failure)(id)=^(id res){
	    NSLog(@"%@", res.parsedResponse);  
	};
	    
	FHRemote * action = (FHRemote *) [FH buildAction:FH_ACTION_ACT];

	action.remoteAction = @"getEventsByLocation";
	[action setArgs:[NSDictionary dictionaryWithObjectsAndKeys:@"-7.12", @"lon", @"52.25", @"lat", nil]];
	    
	[FH act:action WithSuccess:success AndFailure:failure];

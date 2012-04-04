# FeedHenry iOS SDK (Alpha)

This SDK should provide you with all you'll need to start developing cloud-connected apps with the FeedHenry platform. The SDK provides access to cloud action calls.

### Installation

To install the iOS SDK, you'll need to:

* Unpack the provided package
* Open **fh-ios-sdk.xcodeproj** Project in Xcode. This project includes a sample of an Cloud action call.
* In the file pane, you'll see an **fh-ios-sdk** folder - this folder contains the base iOS SDK including it's dependencies (JSONKit & ASIHTTPRequest).
* To install the SDK into your project, simply drag the **fh-ios-sdk** folder to your own project. You may need to reconfigure your project to link against additional frameworks to compile the *JSONKit* and *ASIHttpRequest* libraries - please see the links section below for information on how to install these dependencies. These dependencies are already setup in the SDK example project.

### Usage

To use the iOS SDK with your app, you'll need to configure the SDK by editing the fhconfig.plist file:

* **apiurl** - this is the base SDK URL, by default this is *http://apps.feedhenry.com* - change this if your app lives on another domain.
* **domain** - the domain is a shortened version of the apiurl - it's name which proceeds *.feedhenry.com* (e.g. the domain for http://**apps**.feedhenry.com is **apps**)
* **app** & **inst** - these is the app's identifiers (**app** being an app's unique ID, an **inst** being an identifier for a particular version of an app). These can be obtained by logging into the Studio, opening your app and pressing **CTRL+ALT+G**
* With these configured, you can now make Cloud action calls with the FeedHenry iOS SDK. Examples of Cloud calls are included in the SDK, as well as below. Developers may choose to either use callbacks via *blocks* or *delegate method*s. FHRemote *remoteActions* refer to the Cloud actions you have setup in your main.js on FeedHenry's cloud. Please refer to the links below for more information regarding how to create server-side Cloud actions.

### Examples

FeedHenry Action Call (with blocks):

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
	
### Links
* [FeedHenry Documentation](http://docs.feedhenry.com)
* [FeedHenry Cloud Actions](http://docs.feedhenry.com/api-reference/actions/)
* [ASIHttpRequest](http://allseeing-i.com/ASIHTTPRequest/)
* [JSONKit](https://github.com/johnezang/JSONKit)
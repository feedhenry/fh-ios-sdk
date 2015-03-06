## Build

* Invoke the ```build.sh``` shell script from the command line. This will generate the zip file for the framework and template app in the ```/dist``` directory.

## Update Docs

* Install [appledoc](https://github.com/tomaz/appledoc)
* Clone the repo, checkout master branch.
* Make the changes to the docs comments in the code.
* Go to *FH* directory, open the project in Xcode, run build target "Documentation".
* Commit the changes.
* Checkout gh-pages branch. Rebase it to master.
* Push both branches to the remote.

## Usage

See [iOS SDK Guide](http://docs.feedhenry.com/v2/sdk_ios.html).
	
### Links
* [FeedHenry Documentation](http://docs.feedhenry.com)
* [ASIHttpRequest](http://allseeing-i.com/ASIHTTPRequest/)
* [JSONKit](https://github.com/johnezang/JSONKit)
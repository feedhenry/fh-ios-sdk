# FeedHenry iOS SDK
The iOS Software Development Kit to connect to the [FeedHenry platform.](http://www.feedhenry.com)

## Release Process

The project relies on [Cocoapods](http://cocoapods.org) and it's respective plugins  ['cocoapods-packager'](https://github.com/CocoaPods/cocoapods-packager) and ['cocoapods-appledoc'](https://github.com/CocoaPods/cocoapods-appledoc), so please ensure that are installed in your system. If not, please execute the following:

```
sudo gem install cocoapods cocoapods-packager cocoapods-appledoc
```

### Common Actions

* Update the ```VERSION.txt``` and ```fh-ios-sdk/FHDefines.h ``` with the new version number.

### a) Release on Cocoapods  [Required Step]
* Update ```FeedHenry.podspec``` with the new version number.
* Tag the repository with the new version number.
* Push the new release tag on GitHub
* Publish the ```FeedHenry.podspec``` on the [Cocoapods](http://cocoapods.org) repo with:

	```
 	pod trunk push --allow-warnings
	```

>	```--allow-warnings``` is required to skip some deprecation warnings from a underlying dependency library. This will be circumvented in a future release.

### b) Release on GitHub
* Once you have published on Cocoapods it's time to do a GitHub release. To do so invoke the following command to produce the binary ```framework artifact```:

```
pod package FeedHenry.podspec
```

This will produce a ```FeedHenry.framework``` binary artifact on ```FeedHenry-{VERSION}/ios/``` folder,  that you can then attach on the [GitHub release page](https://help.github.com/articles/creating-releases/).

### c) Generate API Documentation

To produce API documentation invoke the following command:

```
pod appledoc FeedHenry
```
The resulting documentation will reside in ```FeedHenry-{VERSION}/html/``` folder.

## Usage

See [iOS SDK Guide](http://docs.feedhenry.com/v2/sdk_ios.html).

### Links
* [FeedHenry Documentation](http://docs.feedhenry.com)
* [ASIHttpRequest](http://allseeing-i.com/ASIHTTPRequest/)
* [JSONKit](https://github.com/johnezang/JSONKit)

# FeedHenry iOS SDK

[![Build Status](https://travis-ci.org/feedhenry/fh-ios-sdk.svg?branch=master)](https://travis-ci.org/feedhenry/fh-ios-sdk)
[![Coverage Status](https://coveralls.io/repos/github/feedhenry/fh-ios-sdk/badge.svg?branch=master)](https://coveralls.io/github/feedhenry/fh-ios-sdk?branch=master)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FH.svg)](https://img.shields.io/cocoapods/v/FH.svg)
[![Platform](https://img.shields.io/cocoapods/p/FH.svg?style=flat)](http://cocoadocs.org/docsets/FH)

The iOS Software Development Kit to connect to the [FeedHenry platform.](http://www.feedhenry.com)

## Usage

See [iOS SDK Guide](http://docs.feedhenry.com/v2/sdk_ios.html).

### Links
* [FeedHenry Documentation](http://docs.feedhenry.com)
* [Reachability](https://github.com/tonymillion/Reachability)
* [AeroGear iOS Push](https://github.com/aerogear/aerogear-ios-push)


## Developing

The project relies on [CocoaPods](http://cocoapods.org) and it's respective plugins  ['cocoapods-packager'](https://github.com/CocoaPods/cocoapods-packager) and ['cocoapods-appledoc'](https://github.com/CocoaPods/cocoapods-appledoc), so please ensure that are installed in your system. If not, please execute the following:

```
[sudo] gem install cocoapods cocoapods-packager cocoapods-appledoc
```
Then, install cocoapods dependencies.  
```
pod install
open fh-ios-sdk.xcworkspace
```
**Note:** Do not open `fh-ios-sdk.xcodeproj`, work with xcworkspace ensures both the iOS SDK project and the cocoapods dependencies are included in Xcode.

## Running Tests
Tests can be run in Xcode by navigating to Product -> Test.

## Working with templates app

fh-ios-sdk is used by template app like [sync-ios-app]() to scaffold and demo synchronization feature. You can run a template app with **dev pod** by:

```
source 'https://github.com/CocoaPods/Specs.git'
project 'sync-ios-app.xcodeproj'
platform :ios, '7.0'
target 'sync-ios-app' do
    pod 'FH', :path => '../fh-ios-sdk/'
end
```
Given that ```:path``` point to the relative path holding your sdk code source.

## Common Actions

* Update the ```VERSION.txt``` and ```fh-ios-sdk/FHDefines.h ``` with the new version number.
* Update ```CHANGELOG.md`` with the new release and content.

### a) Release on CocoaPods  [Required Step]
* Update ```FH.podspec```, ```s.version``` attribute with the new version number.
* Tag the repository with the new version number:

```
git tag -s -a {VERSION} -m 'version {VERSION}'   // e.g. {VERSION} format is  '2.2.5'
```

* Push the new release tag on GitHub:

```
git push origin {TAG}
```

* Publish the ```FH.podspec``` on the [CocoaPods](http://cocoapods.org) repo with:

```
 	pod trunk push --allow-warnings
```

>	```--allow-warnings``` is required to skip some deprecation warnings from a underlying dependency library. This will be circumvented in a future release.

### b) Release on GitHub
* Once you have published on CocoaPods it's time to do a GitHub release. To do so run the script:

```
./github-release.sh
```

This will produce two files in the ``Releases-{version}`` directory.  You can then attach them on the [GitHub release page](https://help.github.com/articles/creating-releases/).

### c) Generate API Documentation

To generate API documentation and sync with the [GitHub pages placeholder](http://feedhenry.github.io/fh-ios-sdk/FH/docset/Contents/Resources/Documents/index.html), switch to ['gh-pages'](https://github.com/feedhenry/fh-ios-sdk/tree/gh-pages) branch and follow the instructions there.

# FeedHenry iOS SDK [![Build Status](https://travis-ci.org//feedhenry/fh-ios-sdk.png)](https://travis-ci.org/feedhenry/fh-ios-sdk)
The iOS Software Development Kit to connect to the [FeedHenry platform.](http://www.feedhenry.com)

## Release Process

The project relies on [Cocoapods](http://cocoapods.org) and it's respective plugins  ['cocoapods-packager'](https://github.com/CocoaPods/cocoapods-packager) and ['cocoapods-appledoc'](https://github.com/CocoaPods/cocoapods-appledoc), so please ensure that are installed in your system. If not, please execute the following:

```
[sudo] gem install cocoapods cocoapods-packager cocoapods-appledoc
```

### Common Actions

* Update the ```VERSION.txt``` and ```fh-ios-sdk/FHDefines.h ``` with the new version number.
* Update ```CHANGELOG.md`` with the new release and content.

### a) Release on Cocoapods  [Required Step]
* Update ```FH.podspec```, ```s.version``` attribute with the new version number.
* Tag the repository with the new version number:

```
git tag -s -a {VERSION} -m 'version {VERSION}'   // e.g. {VERSION} format is  '2.2.5'
```

* Push the new release tag on GitHub:

```
git push origin {TAG}
```

* Publish the ```FH.podspec``` on the [Cocoapods](http://cocoapods.org) repo with:

```
 	pod trunk push --allow-warnings
```

>	```--allow-warnings``` is required to skip some deprecation warnings from a underlying dependency library. This will be circumvented in a future release.

### b) Release on GitHub
* Once you have published on Cocoapods it's time to do a GitHub release. To do so run the script:

```
./github-release.sh
```

This will produce two files in the ``Releases-{version}`` directory.  You can then attach them on the [GitHub release page](https://help.github.com/articles/creating-releases/).

### c) Generate API Documentation

To generate API documentation and sync with the [GitHub pages placeholder](http://feedhenry.github.io/fh-ios-sdk/FH/docset/Contents/Resources/Documents/index.html), switch to ['gh-pages'](https://github.com/feedhenry/fh-ios-sdk/tree/gh-pages) branch and follow the instructions there.

## Usage

See [iOS SDK Guide](http://docs.feedhenry.com/v2/sdk_ios.html).

### Links
* [FeedHenry Documentation](http://docs.feedhenry.com)
* [ASIHttpRequest](http://allseeing-i.com/ASIHTTPRequest/)
* [JSONKit](https://github.com/johnezang/JSONKit)
* [AeroGear iOS Push](https://github.com/aerogear/aerogear-ios-push)

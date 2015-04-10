# GitHub pages for [FeedHenry API](http://feedhenry.github.io/fh-ios-sdk/FH/docset/Contents/Resources/Documents/index.html)

> As part of [FHMOBSDK-61](https://issues.jboss.org/browse/FHMOBSDK-61) this branch will be eventually removed .

## Update Docs

>To generate API documentation, ensure the release has been published in [Cocoapods](https://cocoapods.org) repository first.

Invoke the following command, replacing {VERSION} as appropriate:

```
pod appledoc FH && rm -rf FH/docset/ && mv -f FH-{VERSION}/docset ./FH/
```

The command will fetch latest Cocoapod spec, compile the API documentation and update local copy. Once that is done,  sync with remote repo:

```
git commit -a -m "sync docset"
git push origin gh-pages
```

Access the  [FeedHenry API GitHub page](http://feedhenry.github.io/fh-ios-sdk/FH/docset/Contents/Resources/Documents/index.html) and ensure any changes have been propagated.

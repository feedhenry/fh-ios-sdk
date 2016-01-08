# CHANGELOG - FeedHenry iOS SDK

## 3.0.0 - 2016-01-08

## 3.0.0-rc2 - 2016-01-05
* RHMAP-2925: add force sync feature
* RHMAP-1155: module map to remove warning in iOs app using FH.framework

## 3.0.0-beta3 - 2015-12-28
* RHMAP-3578: stale record, no update sent

## 3.0.0-beta2 - 2015-12-11
* RHMAP-3298: http failure not reported in sync
* RHMAP-2737: remove sync dead code on reset dataset

## 3.0.0-beta1 - 2015-11-17
* RHMAP-1994 - more unit test coverage
* RHMAP-2577 - remove deprecated library ASIHTTPRequest and remove synchronous http support (breaking API change).
* RHMAP-2703 - sync complete message only on success
* RHMAP-1965 - introduce coverall coverage report in travis

## 2.2.19 - 2015-10-19
* Make sure do not remove object from a dictionary while iterating

## 2.2.18
* RHMAP-2550 - Fix hash issue
* RHMAP-2526 - Apply similar strategy for server side recovery (delay/waitFor)
* Code clean-up: remove changeHistory and unsued code

## 2.2.18-beta2 - 2015-10-13
* Fix an issue with wrong hash value is generated on iOS for the sync framework

## 2.2.18-beta1 - 2015-10-09
* RHMAP-2455 - Further Sync Framework concurrency issues (server latency issues)

## 2.2.17 - 2015-10-09
* RHMAP-2455 - Sync Framework concurrency issues (server latency issues)
* FH-2659 iOS9 enable bitcode

## 2.2.16 - 2015-10-05
* FH-2262 - Fix wronlgy squashed sync operation

## 2.2.15 - 2015-09-22
* PR 44 - Return the temp uid of a new data record once it's synced

## 2.2.14 - 2015-09-21
* PR 42 - Add metadata to datasets

## 2.2.13 - 2015-09-16
*PR 43 - Rewrite HTTP unit tests to no longer mock a HTTP client but use Nocilla. Fix bug in init calling succ and fail, fix status check crashes.

## 2.2.12 - 2015-08-14
* PR 40 - Fix build errors

## 2.2.11 - 2015-08-14
* PR 37 - downgrade cocoapods version
* PR 38 - Added a check for null response (otherwise App crashes on SSL Handshake error) 
* PR 39 - ensure we are loading from the main bundle for the config file

## 2.2.10 - 2015-07-27 - Wei Li
* Fix an uncaught exception thrown by the sync framework when the cloud app is not running.

## 2.2.9 - 2015-06-23 - Corinne Krych
* Add AeroGear UnifiedPush support for push notification

## 2.2.8 - 2015-04-20 - Christos Vasilakis
* Refactor constructor

## 2.2.7 - 2015-04-16 - Wei Li
* Add environment to the auth API requests if it's available

## 2.2.6 - 2015-04-14 - Wei Li
* Add new auth APIs

## 2.2.5 - 2015-03-08 - Christos Vasilakis
* added cocoapods support

## 2.2.4 - 2015-03-05 - Christos Vasilakis
* extract SDK to be a standalone library target

## 2.2.3 - 2015-02-27 - Wei Li
* Fix failed sync test

## 2.2.2 - 2014-10-02 - Cian Clarke

* Fix oAuth view controller mistaking oAuth page redirect with no query string for success

## 2.2.1 - 2014-09-19 - Wei Li

* 7988 - Update Sync framework to use mBAAS service

## 2.2.0 - 2014-09-04 - Jason Madigan

* 7920 - Removing advertisingIdentifier

## 2.1.0 - 2014-07-01 - Jason Madigan

* 7545 - Tweaks to SDK to fix cloud path

## 2.0.0 - 2014-04-29 - Wei Li

* 6995 - Add support for FH.cloud API

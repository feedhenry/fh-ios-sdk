Pod::Spec.new do |s|
  s.name         = 'FH'
  s.version      = '3.1.1'
  s.summary      = 'FeedHenry iOS Software Development Kit'
  s.homepage     = 'https://www.feedhenry.com'
  s.social_media_url = 'https://twitter.com/feedhenry'
  s.license      = 'FeedHenry'
  s.author       = 'Red Hat, Inc.'
  s.source       = { :git => 'https://github.com/feedhenry/fh-ios-sdk.git', :tag => s.version }
  s.platform     = :ios, 8.0
  s.source_files = 'fh-ios-sdk/**/*.{h,m}'
  s.public_header_files =  'fh-ios-sdk/FHDefines.h', 'fh-ios-sdk/FeedHenry.h', 'fh-ios-sdk/FH.h', 'fh-ios-sdk/Cloud/FHAct.h', 'fh-ios-sdk/Cloud/FHActRequest.h', 'fh-ios-sdk/Cloud/FHAuthRequest.h', 'fh-ios-sdk/Config/FHCloudProps.h', 'fh-ios-sdk/Cloud/FHCloudRequest.h', 'fh-ios-sdk/Config/FHPushConfig.h', 'fh-ios-sdk/Config/FHConfig.h',  'fh-ios-sdk/Cloud/FHResponse.h', 'fh-ios-sdk/Cloud/FHResponseDelegate.h', 'fh-ios-sdk/Sync/FHSyncClient.h', 'fh-ios-sdk/Sync/FHSyncConfig.h', 'fh-ios-sdk/Sync/FHSyncNotificationMessage.h', 'fh-ios-sdk/Sync/FHSyncDelegate.h', 'fh-ios-sdk/Sync/FHSyncDataset.h','fh-ios-sdk/Categories/JSON/FHJSON.h', 'fh-ios-sdk/Data/FHDataManager.h'
  s.module_map = 'fh-ios-sdk/module.modulemap'
  s.requires_arc = true
  s.libraries = 'xml2', 'z'
  s.dependency 'Reachability', '3.2'
  s.dependency 'AeroGear-Push', '1.2.0'
end

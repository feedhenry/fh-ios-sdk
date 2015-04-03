#!/bin/bash

BUILD_DIR="./build"
DIST_DIR="./dist"
FH_SDK_VERSION=`head -1 VERSION.txt`

rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR/*.zip"

rm -rf "$DIST_DIR"
if [ ! -d $DIST_DIR ]; then
  mkdir "$DIST_DIR"
fi

# build framework distribution
echo 
echo "Building framework distribution, please wait.."
pod package FeedHenry.podspec

cd "FeedHenry-$FH_SDK_VERSION/ios"
zip -9ry "../../$DIST_DIR/FeedHenry-framework-$FH_SDK_VERSION.zip" "FeedHenry.framework"
echo "done"

# update 'demo projects' with the new framework build
echo 
echo "Updating demos/ with framework build, please wait.."
cd "../../demos/"
rm -rf "FHStarterProject/FeedHenry.framework"
cp -R "../FeedHenry-$FH_SDK_VERSION/ios/FeedHenry.framework" "FHStarterProject/"
rm -rf "FHStarterProject/FHStarterProject.xcodeproj/xcuserdata"
rm -rf "FHStarterProject/FHStarterProject.xcodeproj/project.xcworkspace"

rm -rf "FHAuthDemo/FeedHenry.framework"
cp -R "../FeedHenry-$FH_SDK_VERSION/ios/FeedHenry.framework" "FHAuthDemo/"
rm -rf "FHAuthDemo/FHAuthDemo.xcodeproj/xcuserdata"
rm -rf "FHAuthDemo/FHAuthDemo.xcodeproj/project.xcworkspace"

rm -rf "FHSyncTestApp/FeedHenry.framework"
cp -R "../FeedHenry-$FH_SDK_VERSION/ios/FeedHenry.framework" "FHSyncTestApp/"
rm -rf "FHSyncTestApp/FHSyncTestApp.xcodeproj/xcuserdata"
rm -rf "FHSyncTestApp/FHSyncTestApp.xcodeproj/project.xcworkspace"
echo "done"

# create demos/FHStarterProject distribution
echo 
echo "Creating demos/FHStarterProject distribution, please wait.."
rm -rf "FHStarterProject/build"
zip -9ry "../$DIST_DIR/fh-starter-project-$FH_SDK_VERSION.zip" "FHStarterProject/."
echo "done"
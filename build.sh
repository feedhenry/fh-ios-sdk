#!/bin/bash

BUILD_DIR="./build"
DIST_DIR="./dist"
rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR/*.zip"

BUILD_PROJECT_NAME="fh-ios-sdk.xcodeproj"
BUILD_TARGET_NAME="framework"
BUILD_CONFIGURATION="Release"

XC_BUILD="xcodebuild"

$XC_BUILD VALID_ARCHS="i386 armv7 armv7s arm64 x86_64" -project "$BUILD_PROJECT_NAME" -target "$BUILD_TARGET_NAME" -configuration "$BUILD_CONFIGURATION" clean build
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi

FH_SDK_VERSION=`head -1 VERSION.txt`
rm -rf "$DIST_DIR"
if [ ! -d $DIST_DIR ]; then
  mkdir "$DIST_DIR"
fi

# build framework distribution
echo 
echo "Building framework distribution, please wait.."
cd "build/Release-iphoneos/"
zip -9ry "../../$DIST_DIR/fh-framework-$FH_SDK_VERSION.zip" "FH.framework"
echo "done"

# update 'demo projects' with the new framework build
echo 
echo "Updating demos/ with framework build, please wait.."
cd "../../demos/"
rm -rf "FHStarterProject/FH.framework"
cp -R "../build/Release-iphoneos/FH.framework" "FHStarterProject/"
rm -rf "FHStarterProject/FHStarterProject.xcodeproj/xcuserdata"
rm -rf "FHStarterProject/FHStarterProject.xcodeproj/project.xcworkspace"

rm -rf "FHAuthDemo/FH.framework"
cp -R "../build/Release-iphoneos/FH.framework" "FHAuthDemo/"
rm -rf "FHAuthDemo/FHAuthDemo.xcodeproj/xcuserdata"
rm -rf "FHAuthDemo/FHAuthDemo.xcodeproj/project.xcworkspace"

rm -rf "FHSyncTestApp/FH.framework"
cp -R "../build/Release-iphoneos/FH.framework" "FHSyncTestApp/"
rm -rf "FHSyncTestApp/FHSyncTestApp.xcodeproj/xcuserdata"
rm -rf "FHSyncTestApp/FHSyncTestApp.xcodeproj/project.xcworkspace"
echo "done"

# create demos/FHStarterProject distribution
echo 
echo "Creating demos/FHStarterProject distribution, please wait.."
rm -rf "FHStarterProject/build"
zip -9ry "../$DIST_DIR/fh-starter-project-$FH_SDK_VERSION.zip" "FHStarterProject/."
echo "done"
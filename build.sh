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

cd "build/Release-iphoneos/"
zip -9ry "../../$DIST_DIR/fh-framework-$FH_SDK_VERSION.zip" "FH.framework"

# update 'starter project' with the new framework build
cd "../../demos/FHStarterProject/"
rm -rf "FH.framework"
cp -R "../../build/Release-iphoneos/FH.framework" "."
rm -rf "FHStarterProject.xcodeproj/xcuserdata"
rm -rf "FHStarterProject.xcodeproj/project.xcworkspace"
rm -rf "build"
zip -9ry "../../$DIST_DIR/fh-starter-project-$FH_SDK_VERSION.zip" "."



#!/bin/bash

BUILD_DIR="./build"
DIST_DIR="./dist"
rm -rf "$BUILD_DIR"
rm -rf "DIST_DIR/*.zip"

BUILD_PROJECT_NAME="FH.xcodeproj"
BUILD_TARGET_NAME="framework"
BUILD_CONFIGURATION="Release"
BUILD_SDK="iphoneos"
BUILD_SDK_VERSION="5.0"
ARCHS="armv6 armv7"
VALID_ARCHS="i386 armv6 armv7"

XC_BUILD="xcodebuild"

$XC_BUILD VALID_ARCHS="i386 armv6 armv7" -project "$BUILD_PROJECT_NAME" -target "$BUILD_TARGET_NAME" -configuration "$BUILD_CONFIGURATION" clean build
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi

FH_SDK_VERSION=`head -1 VERSION.txt`
if [ ! -d $DIST_DIR ]; then
  mkdir "$DIST_DIR"
fi
cd "build/Release-iphoneos/"
zip -9ry "../../$DIST_DIR/fh-framework-$FH_SDK_VERSION.zip" "FH.framework"

cp -R "FH.framework" "../../../FHStarterProject/"
cd "../../../"
rm -rf "FHStarterProject/FHStarterProject.xcodeproj/xcuserdata"
rm -rf "FHStarterProject/FHStarterProject.xcodeproj/project.xcworkspace"
zip -9ry "FH/dist/fh-starter-project-$FH_SDK_VERSION.zip" "FHStarterProject"


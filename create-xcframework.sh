#!/bin/bash

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null

DERIVED_DATA_PATH=".DerivedData-Archive.noindex"
ARCHIVES_ROOT_PATH="Archives"

rm -rf "$DERIVED_DATA_PATH"
rm -rf "$ARCHIVES_ROOT_PATH"

mkdir -p "$ARCHIVES_ROOT_PATH"

CREATE_XCFRAMEWORK_ARGUMENTS=()

for PLATFORM in "macOS" "macOS,variant=Mac Catalyst" "iOS" "iOS Simulator" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator"; do
	case $PLATFORM in
	"macOS")
	ARCHIVE_NAME="Release-macos"
	SCHEME="TypedNotificationCenter macOS"
	;;
	"macOS,variant=Mac Catalyst")
	ARCHIVE_NAME="Release-maccatalyst"
	SCHEME="TypedNotificationCenter iOS"
	;;
	"iOS")
	ARCHIVE_NAME="Release-iphoneos"
	SCHEME="TypedNotificationCenter iOS"
	;;
	"iOS Simulator")
	ARCHIVE_NAME="Release-iphonesimulator"
	SCHEME="TypedNotificationCenter iOS"
	;;
	"tvOS")
	ARCHIVE_NAME="Release-tvos"
	SCHEME="TypedNotificationCenter tvOS"
	;;
	"tvOS Simulator")
	ARCHIVE_NAME="Release-tvossimulator"
	SCHEME="TypedNotificationCenter tvOS"
	;;
	"watchOS")
	ARCHIVE_NAME="Release-watchos"
	SCHEME="TypedNotificationCenter watchOS"
	;;
	"watchOS Simulator")
	ARCHIVE_NAME="Release-watchsimulator"
	SCHEME="TypedNotificationCenter watchOS"
	;;
	esac

   ARCHIVE_PATH="$ARCHIVES_ROOT_PATH/$ARCHIVE_NAME.xcarchive"
   LOG_PATH="$ARCHIVES_ROOT_PATH/$ARCHIVE_NAME.log"

	xcodebuild archive \
		-project "TypedNotificationCenter.xcodeproj" \
		-scheme "$SCHEME" \
		-destination "generic/platform=$PLATFORM" \
		-configuration "Release" \
		-archivePath "$ARCHIVE_PATH" \
		-derivedDataPath "$DERIVED_DATA_PATH" \
		-IDEBuildLocationStyle=Unique \
		SKIP_INSTALL=NO \
		SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		| tee "$LOG_PATH"
	
	CREATE_XCFRAMEWORK_ARGUMENTS+=( "-archive" "$PWD/$ARCHIVE_PATH" )
	CREATE_XCFRAMEWORK_ARGUMENTS+=( "-framework" "TypedNotificationCenter.framework" )
done

xcodebuild -create-xcframework \
	"${CREATE_XCFRAMEWORK_ARGUMENTS[@]}" \
	-output "$ARCHIVES_ROOT_PATH/TypedNotificationCenter.xcframework"

# https://developer.apple.com/forums/thread/123253
find "$ARCHIVES_ROOT_PATH/TypedNotificationCenter.xcframework" -name "*.swiftinterface" -exec sed -i -e 's/ TypedNotificationCenter\./ /g' {} \;

#!/bin/bash

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null

DERIVED_DATA_PATH=".DerivedData-Archive.noindex"
ARCHIVES_ROOT_PATH="Archives"

rm -rf "$DERIVED_DATA_PATH"
rm -rf "$ARCHIVES_ROOT_PATH"

mkdir -p "$ARCHIVES_ROOT_PATH"

CREATE_XCFRAMEWORK_ARGUMENTS=()

for idx in {1..8}; do
	case $idx in
	1)
		PLATFORM="macOS"
		ARCHIVE_NAME="Release-macos"
		SCHEME="TypedNotificationCenter macOS"
	;;
	2)
		PLATFORM="macOS,variant=Mac Catalyst"
		ARCHIVE_NAME="Release-maccatalyst"
		SCHEME="TypedNotificationCenter iOS"
	;;
	3)
		PLATFORM="iOS"
		ARCHIVE_NAME="Release-iphoneos"
		SCHEME="TypedNotificationCenter iOS"
	;;
	4)
		PLATFORM="iOS Simulator"
		ARCHIVE_NAME="Release-iphonesimulator"
		SCHEME="TypedNotificationCenter iOS"
	;;
	5)
		PLATFORM="tvOS"
		ARCHIVE_NAME="Release-tvos"
		SCHEME="TypedNotificationCenter tvOS"
	;;
	6)
		PLATFORM="tvOS Simulator"
		ARCHIVE_NAME="Release-tvossimulator"
		SCHEME="TypedNotificationCenter tvOS"
	;;
	7)
		PLATFORM="watchOS"
		ARCHIVE_NAME="Release-watchos"
		SCHEME="TypedNotificationCenter watchOS"
	;;
	8)
		PLATFORM="watchOS Simulator"
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
		SKIP_INSTALL=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		| tee "$LOG_PATH"

	FRAMEWORK_PATH=$(find "$ARCHIVE_PATH" -name "*.framework" -print -quit)
	if [ -n "$FRAMEWORK_PATH" ]; then
		CREATE_XCFRAMEWORK_ARGUMENTS+=( "-framework" "$PWD/$FRAMEWORK_PATH" )
	fi
	DSYM_PATH=$(find "$ARCHIVE_PATH" -name "*.framework.dSYM" -print -quit)
	if [ -n "$DSYM_PATH" ]; then
		CREATE_XCFRAMEWORK_ARGUMENTS+=( "-debug-symbols" "$PWD/$DSYM_PATH" )
	fi
	BCSYMBOLMAP_PATHS=$(find "$ARCHIVE_PATH" -name "*.bcsymbolmap")
	for BCSYMBOLMAP_PATH in $BCSYMBOLMAP_PATHS; do
		CREATE_XCFRAMEWORK_ARGUMENTS+=( "-debug-symbols" "$PWD/$BCSYMBOLMAP_PATH" )
	done
done

xcodebuild -create-xcframework \
	"${CREATE_XCFRAMEWORK_ARGUMENTS[@]}" \
	-output "$ARCHIVES_ROOT_PATH/TypedNotificationCenter.xcframework"

# TypedNotificationCenter
Typed version of Apple's NotificationCenter to avoid forgetting setting parameters in the userInfo dictionary and needing to handle not having those parameters.

## Goals
- [x] Create initial version for iOS
- [x] Add support for other platforms
- [ ] Add license to github
- [ ] Write unit tests
- [ ] Run tests on CI with code coverage
- [ ] Translate UIKit/AppKit/etc. notifications into TypedNotifications with error handling (default is print, customizable through public API)
- [ ] Add UI tests for the translated notifications
- [ ] Write performance test for having a bunch of types and observations
- [ ] Measure performance of array vs hash based separation of notification types

# TypedNotificationCenter

[![Build Status](https://travis-ci.org/Cyberbeni/TypedNotificationCenter.svg?branch=master)](https://travis-ci.org/Cyberbeni/TypedNotificationCenter) [![Code coverage](https://codecov.io/github/Cyberbeni/TypedNotificationCenter/coverage.svg?branch=master)](https://codecov.io/github/Cyberbeni/TypedNotificationCenter?branch=master)

This framework is about rethinking Apple's NotificationCenter to be more typesafe and about removing uncertainity of the needed value being present in the userInfo dictionary.

## Example usage

```
// SampleNotification.swift
import TypedNotificationCenter

enum SampleNotification: TypedNotification {
    struct Payload {
        let type = "test"
    }
    typealias Sender = MyCustomView
}
```

```
// OtherFile.swift
// Observe a notification and execute a block with the sender and the payload
var observations = [TypedNotificationObservation]()
observations.append(TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, block: { (sender, payload) in
    print(sender, payload)
}))

// Post a notification
TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())

// Stop observing the notification, this is also called when the observation object deinitializes
observation?.invalidate()
```

## Goals
- [x] Create initial version for iOS
- [x] Add support for other platforms
- [x] Add example usage to readme
- [x] Add license to github
- [x] Write unit tests
- [x] Run tests on CI with code coverage
- [x] Write performance test for having a bunch of types and observations
- [x] Measure performance of array vs hash based separation of notification types (Most likely ObjectIdentifier is the best solution for doing it since it provides a pointer based hash to types and objects - https://github.com/apple/swift/blob/b8722fd7d4fc070d685dee2e1173ce180b4896c6/stdlib/public/core/ObjectIdentifier.swift#L18 )
- [x] Create a workflow to translate UIKit/AppKit/etc. notifications (with 1 class for example) into TypedNotifications with error handling (default is print, customizable through public API)
- [x] Add UI tests for the translated notifications
- [x] Make the example usage section more detailed/useful
- [x] v1.0
- [ ] Add Linux + SPM support
- [ ] Add Cocoapods support
- [ ] Translate other notifications and add unit/UI tests for them (also improve UI testing structure)

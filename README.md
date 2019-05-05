# TypedNotificationCenter
Typed version of Apple's NotificationCenter to avoid forgetting setting parameters in the userInfo dictionary and needing to handle not having those parameters.

## Example usage

```
// SampleNotification.swift
import TypedNotificationCenter

enum SampleNotification: TypedNotification {
    struct Payload {
        let type = "test"
    }
    typealias Sender = AnyObject
}
```

```
// OtherFile.swift
var observation: TypedNotificationObservation?
observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, block: { (sender, payload) in
            print(sender, payload)
        })

TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
```

## Goals
- [x] Create initial version for iOS
- [x] Add support for other platforms
- [x] Add example usage to readme
- [x] Add license to github
- [x] Write unit tests
- [ ] Run tests on CI with code coverage
- [ ] Translate UIKit/AppKit/etc. notifications into TypedNotifications with error handling (default is print, customizable through public API)
- [ ] Add UI tests for the translated notifications
- [ ] Write performance test for having a bunch of types and observations
- [ ] Measure performance of array vs hash based separation of notification types

# TypedNotificationCenter

[![Build Status](https://github.com/Cyberbeni/TypedNotificationCenter/workflows/Test%20latest%20OSs/badge.svg)](https://github.com/Cyberbeni/TypedNotificationCenter/actions) [![Code coverage](https://codecov.io/github/Cyberbeni/TypedNotificationCenter/coverage.svg?branch=master)](https://codecov.io/github/Cyberbeni/TypedNotificationCenter?branch=master) [![codebeat badge](https://codebeat.co/badges/a94b1565-4033-4efb-b60b-76ba952ff4ad)](https://codebeat.co/projects/github-com-cyberbeni-typednotificationcenter-master) [![GitHub release](https://img.shields.io/github/release/Cyberbeni/TypedNotificationCenter.svg)](https://GitHub.com/Cyberbeni/TypedNotificationCenter/releases/)
 [![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

 ![Platforms](https://img.shields.io/badge/platform-iOS%20%7C%20Linux%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Swift Package Manager Compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) [![CocoaPods Compatible](https://cocoapod-badges.herokuapp.com/v/TypedNotificationCenter/badge.png)](https://cocoapods.org/pods/TypedNotificationCenter) 

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

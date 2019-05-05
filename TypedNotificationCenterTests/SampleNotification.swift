//
//  SampleNotification.swift
//  TypedNotificationCenterTests
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation
@testable import TypedNotificationCenter

enum SampleNotification: TypedNotification {
    struct Payload {
        let type = "test"
    }
    typealias Sender = AnyObject
}

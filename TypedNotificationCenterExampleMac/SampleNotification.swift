//
//  SampleNotification.swift
//  TypedNotificationCenterExampleMac
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation
import TypedNotificationCenter

class SampleNotification: TypedNotification {
    struct Payload {
        let type = "desktop"
    }
    typealias Sender = NSObject
}

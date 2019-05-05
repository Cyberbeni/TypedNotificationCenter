//
//  SampleNotification.swift
//  TypedNotificationCenterExampleWatch Extension
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation
import TypedNotificationCenter
import WatchKit

class SampleNotification: TypedNotification {
    struct Payload {
        let type = "watch"
    }
    typealias Sender = WKInterfaceController
}

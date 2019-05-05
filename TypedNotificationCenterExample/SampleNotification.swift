//
//  SampleNotification.swift
//  TypedNotificationCenterExample
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import UIKit
import Foundation
import TypedNotificationCenter

enum SampleNotification: TypedNotification {
    struct Payload {
        let asd = "1"
    }
    typealias Sender = UIViewController
}

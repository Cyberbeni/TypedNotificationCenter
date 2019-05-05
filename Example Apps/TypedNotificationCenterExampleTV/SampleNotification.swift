//
//  SampleNotification.swift
//  TypedNotificationCenterExampleTV
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation
import TypedNotificationCenter
import UIKit

enum SampleNotification: TypedNotification {
    struct Payload {
        let type = "tv"
    }
    typealias Sender = UIViewController
}

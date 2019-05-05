//
//  TypedNotification.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation

public protocol TypedNotification {
    typealias ObservationBlock = (Self.Sender, Self.Payload) -> ()
    associatedtype Payload
    associatedtype Sender: AnyObject
}

//
//  TypedNotificationObservation.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation

public protocol TypedNotificationObservation: AnyObject {
    func invalidate()
    var isValid: Bool { get }
}

final class _TypedNotificationObservation<T: TypedNotification>: TypedNotificationObservation {
    init(notificationCenter: TypedNotificationCenter, sender: T.Sender?, queue: OperationQueue?, block: @escaping T.ObservationBlock) {
        self.notificationCenter = notificationCenter
        self.sender = sender
        senderWasNil = sender == nil
        self.queue = queue
        self.block = block
    }
    
    private weak var notificationCenter: TypedNotificationCenter?
    weak var sender: T.Sender?
    private let senderWasNil: Bool
    var queue: OperationQueue?
    var block: T.ObservationBlock?
    
    private var isRemoved = false
    
    public var isValid: Bool {
        return !isRemoved && (notificationCenter != nil) && !(!senderWasNil && sender == nil)
    }
    
    public func invalidate() {
        guard !isRemoved else { return }
        isRemoved = true
        notificationCenter?.remove(observer: self)
        block = nil
        queue = nil
    }
    
    deinit {
        invalidate()
    }
}

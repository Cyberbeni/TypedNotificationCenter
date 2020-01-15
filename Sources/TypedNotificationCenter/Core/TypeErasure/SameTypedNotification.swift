//
//  SameTypedNotification.swift
//  TypedNotificationCenter
//
//  Created by Kozma Benedek on 2019. 12. 01.
//  Copyright (c) 2019. Benedek Kozma
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

// MARK: Same Sender and Payload type

public extension TypedNotification {
    static func eraseNotificationName() -> SameTypedNotification<Sender, Payload> {
        SameTypedNotification<Sender, Payload>(self)
    }
}

public final class SameTypedNotification<Sender, Payload> {
    fileprivate let observeBlock: (TypedNotificationCenter, Sender?, OperationQueue?, @escaping (Sender, Payload) -> Void) -> TypedNotificationObservation
    fileprivate let postBlock: (TypedNotificationCenter, Sender, Payload) -> Void
    init<T: TypedNotification>(_: T.Type) where T.Sender == Sender, T.Payload == Payload {
        observeBlock = { notificationCenter, sender, queue, notificationBlock in
            notificationCenter.observe(T.self, object: sender, queue: queue) { sender, payload in
                notificationBlock(sender, payload)
            }
        }
        postBlock = { notificationCenter, sender, payload in
            notificationCenter.post(T.self, sender: sender, payload: payload)
        }
    }
}

public extension TypedNotificationCenter {
    func observe<Sender, Payload>(_ proxy: SameTypedNotification<Sender, Payload>, object: Sender?, queue: OperationQueue? = nil, block: @escaping (Sender, Payload) -> Void) -> TypedNotificationObservation {
        proxy.observeBlock(self, object, queue, block)
    }

    func post<Sender, Payload>(_ proxy: SameTypedNotification<Sender, Payload>, sender: Sender, payload: Payload) {
        proxy.postBlock(self, sender, payload)
    }
}

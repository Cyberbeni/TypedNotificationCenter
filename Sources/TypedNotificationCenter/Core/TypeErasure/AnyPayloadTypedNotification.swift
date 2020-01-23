//
//  AnyPayloadTypedNotification.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 12. 01.
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

// MARK: Same Sender type

public extension TypedNotification {
    static func erasePayloadType() -> AnyPayloadTypedNotification<Sender> {
        AnyPayloadTypedNotification<Sender>(self)
    }
}

public final class AnyPayloadTypedNotification<Sender> {
    fileprivate let observeBlock: (TypedNotificationCenter, Sender?, OperationQueue?, @escaping (Sender) -> Void) -> TypedNotificationObservation
    init<T: TypedNotification>(_: T.Type) where T.Sender == Sender {
        observeBlock = { notificationCenter, sender, queue, notificationBlock in
            notificationCenter.observe(T.self, object: sender, queue: queue) { sender, _ in
                notificationBlock(sender)
            }
        }
    }
}

public extension TypedNotificationCenter {
    func observe<Sender>(_ proxy: AnyPayloadTypedNotification<Sender>, object: Sender?, queue: OperationQueue? = nil, block: @escaping (Sender) -> Void) -> TypedNotificationObservation {
        proxy.observeBlock(self, object, queue, block)
    }
}

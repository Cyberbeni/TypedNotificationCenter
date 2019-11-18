//
//  TypeErasure.swift
//  TypedNotificationCenter
// 
//  Created by Benedek Kozma on 2019. 11. 18.
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

// MARK: - Same Sender type
public extension TypedNotification {
    static func erasePayloadType() -> AnyPayloadTypedNotification<Sender> {
        return AnyPayloadTypedNotification<Sender>(self)
    }
}

public final class AnyPayloadTypedNotification<Sender> {
    let observeBlock: (TypedNotificationCenter, Sender?, @escaping (Sender) -> Void) -> TypedNotificationObservation
    init<T: TypedNotification>(_ notification: T.Type) where T.Sender == Sender {
        observeBlock = { notificationCenter, sender, notificationBlock in
            return notificationCenter.observe(T.self, object: sender) { sender, _ in
                notificationBlock(sender)
            }
        }
    }
}

public extension TypedNotificationCenter {
    func observe<Sender>(_ proxy: AnyPayloadTypedNotification<Sender>, object: Sender?, queue: OperationQueue? = nil, block: @escaping (Sender) -> Void) -> TypedNotificationObservation {
        return proxy.observeBlock(self, object, block)
    }
}

// MARK: - Unrelated types
public extension TypedNotification {
    static func eraseTypes() -> AnyTypedNotification {
        return AnyTypedNotification(self)
    }
}

public final class AnyTypedNotification {
    let observeBlock: (TypedNotificationCenter, @escaping () -> Void) -> TypedNotificationObservation
    init<T: TypedNotification>(_ notification: T.Type) {
        observeBlock = { notificationCenter, notificationBlock in
            return notificationCenter.observe(T.self, object: nil) { _, _ in
                notificationBlock()
            }
        }
    }
}

public extension TypedNotificationCenter {
    func observe(_ proxy: AnyTypedNotification, queue: OperationQueue? = nil, block: @escaping () -> Void) -> TypedNotificationObservation {
        return proxy.observeBlock(self, block)
    }
}

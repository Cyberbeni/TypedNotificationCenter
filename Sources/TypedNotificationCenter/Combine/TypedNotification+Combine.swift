//
//  TypedNotification+Combine.swift
//  TypedNotificationCenter
// 
//  Created by Kozma Benedek on 2019. 08. 29.
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

#if canImport(Combine)

import Combine
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TypedNotificationSubscription<SubscriberType: Subscriber, T:TypedNotification>: Subscription where SubscriberType.Input == T.Payload {
    var observation: TypedNotificationObservation?
    
    init(subscriber: SubscriberType, notificationType: T.Type, sender: T.Sender) {
        observation = TypedNotificationCenter.default.observe(T.self, object: sender) { _, payload in
            _ = subscriber.receive(payload)
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        
    }
    
    func cancel() {
        observation?.invalidate()
        observation = nil
    }
    
    var combineIdentifier = CombineIdentifier()
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class TypedNotifier<T: TypedNotification>: Publisher {
    public typealias Output = T.Payload
    public typealias Failure = Never
    
    weak var sender: T.Sender?
    
    init(sender: T.Sender) {
        self.sender = sender
    }

    public func receive<S>(subscriber: S) where S : Subscriber, TypedNotifier.Output == S.Input {
        guard let sender = sender else { return }
        subscriber.receive(subscription: TypedNotificationSubscription(subscriber: subscriber, notificationType: T.self, sender: sender))
    }
    
    public func publish(_ value: T.Payload) {
        guard let sender = sender else { return }
        TypedNotificationCenter.default.post(T.self, sender: sender, payload: value)
    }
}

#endif

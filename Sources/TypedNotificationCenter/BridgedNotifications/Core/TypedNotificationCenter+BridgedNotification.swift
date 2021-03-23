//
//  TypedNotificationCenter+BridgedNotification.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 06. 06.
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

extension TypedNotificationCenter {
	func _bridgeObserve<T: BridgedNotification>(_: T.Type, object: T.Sender?, queue: OperationQueue? = nil, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
		let object = T.Sender.self is NSNull.Type ? nil : object
        
        let observation = _TypedNotificationObservation<T>(notificationCenter: self, sender: object, queue: queue, block: block)

        let notificationIdentifier = NotificationIdentifier(T.self)
        let senderIdentifier = observation.senderIdentifier
        let observerIdentifier = ObjectIdentifier(observation)
        let boxedObservation = WeakBox(observation)

        observerLock.lock()
        if !bridgedObservers.keys.contains(T.notificationName) {
            bridgedObservers[T.notificationName] = _BridgedNotificationObservation<T>(sender: nil, queue: nil, block: { [weak self] (sender, payload) in
                self?.forwardPost(T.self, sender: sender, payload: payload)
            })
        }
        observers[notificationIdentifier, default: [:]][senderIdentifier, default: [:]][observerIdentifier] = boxedObservation
        observerLock.unlock()

		return observation
	}
    
    func forwardPost<T: BridgedNotification>(_: T.Type, sender: T.Sender, payload: T.Payload) {
        _post(T.self, sender: sender, payload: payload)
    }

	func _bridgePost<T: BridgedNotification>(_: T.Type, sender: T.Sender, payload: T.Payload) {
		NotificationCenter.default.post(name: T.notificationName, object: sender, userInfo: payload.asDictionary())
	}
}

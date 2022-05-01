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
	func _bridgeObserve<T: BridgedNotification>(_: T.Type, object: T.Sender?, queue: OperationQueue?, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
		_bridgeObserve(T.self, T.self)
		return _observe(T.self, object: object, queue: queue, block: block)
	}

	func _bridgeObserve<T: TypedNotification>(_: T.Type, _ U: any BridgedNotification.Type) {
		assert(T.self == U.self)
		observerLock.lock()
		if !bridgedNsnotificationObservers.keys.contains(U.notificationName) {
			bridgedNsnotificationObservers[U.notificationName] = _NsNotificationObservation<T>(nsNotificationCenter: nsNotificationCenterForBridging, type: U.self,
			                                                                                   block: { [weak self] sender, payload in
			                                                                                   	self?._post(T.self, sender: sender, payload: payload)
			                                                                                   })
		} else {
			assert(
				bridgedNsnotificationObservers[U.notificationName] is _NsNotificationObservation<T>,
				"Two BridgedNotification types (\(String(describing: T.self)) and \(String(describing: type(of: bridgedNsnotificationObservers[U.notificationName])))) are using the same name: \(U.notificationName)"
			)
		}
		observerLock.unlock()
	}

	func _bridgePost<T: BridgedNotification>(_: T.Type, sender: T.Sender, payload: T.Payload) {
		nsNotificationCenterForBridging.post(name: T.notificationName, object: sender, userInfo: payload.asDictionary())
	}

	func _bridgePost<T: TypedNotification>(_: T.Type, _ U: any BridgedNotification.Type, sender: T.Sender, payload: T.Payload) {
		assert(T.self == U.self)
		nsNotificationCenterForBridging.post(name: U.notificationName, object: sender, userInfo: (payload as! DictionaryRepresentable).asDictionary())
	}
}

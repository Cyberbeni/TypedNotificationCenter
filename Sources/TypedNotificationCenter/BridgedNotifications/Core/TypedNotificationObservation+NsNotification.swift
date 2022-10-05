//
//  TypedNotificationObservation+NsNotification.swift
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

final class _NsNotificationObservation<T: TypedNotification>: TypedNotificationObservation {
	private let observation: Any
	private weak var nsNotificationCenter: NotificationCenter?

	init(typedNotificationCenter: TypedNotificationCenter, type: any BridgedNotification.Type) {
		assert(T.self == type.self)
		let nsNotificationCenter = typedNotificationCenter.nsNotificationCenterForBridging
		self.nsNotificationCenter = nsNotificationCenter
		observation = nsNotificationCenter.addObserver(forName: type.notificationName, object: nil, queue: nil, using: { [weak typedNotificationCenter] notification in
			guard let sender = (notification.object ?? NSNull()) as? T.Sender else {
				TypedNotificationCenter.invalidSenderBlock(notification.object, type.notificationName)
				return
			}
			do {
				let PayloadType = T.Payload.self as! DictionaryRepresentable.Type
				let payload = try PayloadType.init(notification.userInfo ?? [:]) as! T.Payload
				typedNotificationCenter?._post(T.self, sender: sender, payload: payload)
			} catch {
				TypedNotificationCenter.invalidPayloadBlock(error, notification.userInfo, type.notificationName)
				return
			}
		})
	}

	// MARK: - TypedNotificationObservation conformance

	override func invalidate() {
		_isValid = false
		nsNotificationCenter?.removeObserver(observation)
	}

	private var _isValid = true
	override var isValid: Bool { _isValid }
}

//
//  TypedNotificationObservation+GenericNsNotification.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2021. 03. 23.
//  Copyright (c) 2021. Benedek Kozma
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

final class _GenericNsNotificationObservation: TypedNotificationObservation {
	private let observation: Any
	private weak var typedNotificationCenter: TypedNotificationCenter?

	init(typedNotificationCenter: TypedNotificationCenter, notificationName: Notification.Name) {
		self.typedNotificationCenter = typedNotificationCenter
		#if canImport(ObjectiveC)
		observation = typedNotificationCenter.nsNotificationCenterForBridging.addObserver(self, selector: #selector(forward(notification:)), name: notificationName, object: nil)
		#else
		observation = typedNotificationCenter.nsNotificationCenterForBridging.addObserver(forName: notificationName, object: nil, queue: nil, using: { [weak typedNotificationCenter] notification in
			typedNotificationCenter?.forwardGenericPost(
				notification.name,
				sender: notification.object as AnyObject?,
				payload: notification.userInfo
			)
		})
		#endif
	}

	#if canImport(ObjectiveC)
	@objc private func forward(notification: Notification) {
		typedNotificationCenter?.forwardGenericPost(
			notification.name,
			sender: notification.object as AnyObject?,
			payload: notification.userInfo
		)
	}
	#endif

	// MARK: - TypedNotificationObservation conformance

	override func invalidate() {
		_isValid = false
		typedNotificationCenter?.nsNotificationCenterForBridging.removeObserver(observation)
	}

	private var _isValid = true
	override var isValid: Bool { _isValid }
}

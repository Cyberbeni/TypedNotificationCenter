//
//  TypedNotificationObservation+GenericBridgedNotification.swift
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

final class _GenericBridgedNotificationObservation: TypedNotificationObservation, @unchecked Sendable {
	init(notificationCenter: TypedNotificationCenter, notificationName: Notification.Name, sender: AnyObject?, queue: OperationQueue?, block: @escaping ObservationBlock) {
		self.notificationCenter = notificationCenter
		self.notificationName = notificationName
		self.sender = sender
		senderIdentifier = sender.map { SenderIdentifier($0) } ?? nilSenderIdentifier
		self.queue = queue
		self.block = block
	}

	typealias ObservationBlock = @Sendable (Notification) -> Void

	private weak var notificationCenter: TypedNotificationCenter?
	let notificationName: Notification.Name
	weak var sender: AnyObject?
	let senderIdentifier: SenderIdentifier
	var queue: OperationQueue?
	var block: ObservationBlock?

	private var isRemoved = false

	// MARK: - TypedNotificationObservation conformance

	override var isValid: Bool {
		!isRemoved && (notificationCenter != nil) && !(senderIdentifier != nilSenderIdentifier && sender == nil)
	}

	override func invalidate() {
		guard !isRemoved else { return }
		isRemoved = true
		notificationCenter?.remove(observation: self)
		block = nil
		queue = nil
	}
}

extension _GenericNsNotificationObservation {
	class ExecuteBlockOperation: Operation, @unchecked Sendable {
		var block: _GenericBridgedNotificationObservation.ObservationBlock?
		let notification: Notification

		init(block: @escaping _GenericBridgedNotificationObservation.ObservationBlock, notification: Notification) {
			self.block = block
			self.notification = notification
		}

		override func main() {
			block?(notification)
			block = nil
		}
	}
}

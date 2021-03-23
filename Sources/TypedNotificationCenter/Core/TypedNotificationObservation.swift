//
//  TypedNotificationObservation.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 05. 05.
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

public class TypedNotificationObservation {
	internal init() {}
	deinit {
		invalidate()
	}

	public func invalidate() {}
	public var isValid: Bool { false }
}

extension TypedNotificationObservation: Hashable {
	public final func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}

	public static func == (lhs: TypedNotificationObservation, rhs: TypedNotificationObservation) -> Bool {
		lhs === rhs
	}
}

let nilSenderIdentifier = ObjectIdentifier(WeakBox<AnyObject>.self)

final class _TypedNotificationObservation<T: TypedNotification>: TypedNotificationObservation {
	init(notificationCenter: TypedNotificationCenter, sender: T.Sender?, queue: OperationQueue?, block: @escaping T.ObservationBlock) {
		self.notificationCenter = notificationCenter
		self.sender = sender
		senderIdentifier = sender.map { SenderIdentifier($0) } ?? nilSenderIdentifier
		self.queue = queue
		self.block = block
	}

	private weak var notificationCenter: TypedNotificationCenter?
	weak var sender: T.Sender?
	let senderIdentifier: SenderIdentifier
	var queue: OperationQueue?
	var block: T.ObservationBlock?

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

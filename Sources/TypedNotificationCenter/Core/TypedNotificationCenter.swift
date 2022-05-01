//
//  TypedNotificationCenter.swift
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

typealias NotificationIdentifier = ObjectIdentifier
typealias SenderIdentifier = ObjectIdentifier

public final class TypedNotificationCenter {
	let observerLock = NSLock()
	var observers = [NotificationIdentifier: [SenderIdentifier: [ObjectIdentifier: WeakBox<AnyObject>]]]()
	let nsNotificationCenterForBridging: NotificationCenter
	var bridgedObservers = [Notification.Name: [SenderIdentifier: [ObjectIdentifier: WeakBox<_GenericBridgedNotificationObservation>]]]()
	var bridgedNsnotificationObservers = [Notification.Name: TypedNotificationObservation]()
	var genericNsnotificationObservers = [Notification.Name: _GenericNsNotificationObservation]()

	// MARK: - Utility functions

	private func filter<T: TypedNotification>(_: T.Type, sender: AnyObject)
		-> (nilObservations: Dictionary<ObjectIdentifier, WeakBox<AnyObject>>.Values?, objectObservations: Dictionary<ObjectIdentifier, WeakBox<AnyObject>>.Values?)
	{
		let notificationIdentifier = NotificationIdentifier(T.self)
		let senderIdentifier = SenderIdentifier(sender)

		let observationsForNotification = observers[notificationIdentifier]

		let nilObservations = observationsForNotification?[nilSenderIdentifier]?.values
		let objectObservations = observationsForNotification?[senderIdentifier]?.values

		return (nilObservations, objectObservations)
	}

	// MARK: - Internal functions

	func remove<T>(observation: _TypedNotificationObservation<T>) {
		let notificationIdentifier = NotificationIdentifier(T.self)
		let senderIdentifier = observation.senderIdentifier
		let observerIdentifier = ObjectIdentifier(observation)
		observerLock.lock()
		observers[notificationIdentifier]?[senderIdentifier]?.removeValue(forKey: observerIdentifier)
		if observers[notificationIdentifier]?[senderIdentifier]?.isEmpty == true {
			observers[notificationIdentifier]?.removeValue(forKey: senderIdentifier)
		}
		observerLock.unlock()
	}

	func _observe<T: TypedNotification>(_: T.Type, object: T.Sender?, queue: OperationQueue? = nil, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
		let object = T.Sender.self is NSNull.Type ? nil : object

		let observation = _TypedNotificationObservation<T>(notificationCenter: self, sender: object, queue: queue, block: block)

		let notificationIdentifier = NotificationIdentifier(T.self)
		let senderIdentifier = observation.senderIdentifier
		let observerIdentifier = ObjectIdentifier(observation)
		let boxedObservation = WeakBox<AnyObject>(observation)

		observerLock.lock()
		observers[notificationIdentifier, default: [:]][senderIdentifier, default: [:]][observerIdentifier] = boxedObservation
		observerLock.unlock()

		return observation
	}

	func _post<T: TypedNotification>(_: T.Type, sender: T.Sender, payload: T.Payload) {
		var nilObservations: Dictionary<ObjectIdentifier, WeakBox<AnyObject>>.Values?
		var objectObservations: Dictionary<ObjectIdentifier, WeakBox<AnyObject>>.Values?
		observerLock.lock()
		(nilObservations, objectObservations) = filter(T.self, sender: sender)
		observerLock.unlock()
		nilObservations?.forEach { observation in
			guard let observation = observation.object as? _TypedNotificationObservation<T> else { return }
			if let queue = observation.queue,
			   let block = observation.block
			{
				queue.addOperation {
					block(sender, payload)
				}
			} else {
				observation.block?(sender, payload)
			}
		}
		objectObservations?.forEach { observation in
			guard let observation = observation.object as? _TypedNotificationObservation<T>,
			      observation.sender != nil
			else { return }
			if let queue = observation.queue,
			   let block = observation.block
			{
				queue.addOperation {
					block(sender, payload)
				}
			} else {
				observation.block?(sender, payload)
			}
		}
	}

	// MARK: - Public interface

	public init(nsNotificationCenterForBridging: NotificationCenter = .default) {
		self.nsNotificationCenterForBridging = nsNotificationCenterForBridging
	}

	public static let `default` = TypedNotificationCenter()

	public func observe<T: TypedNotification>(_: T.Type, object: T.Sender?, queue: OperationQueue? = nil, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
		if let type = T.self as? any BridgedNotification.Type {
			_bridgeObserve(T.self, type.self)
		}
		return _observe(T.self, object: object, queue: queue, block: block)
	}

	public func post<T: TypedNotification>(_: T.Type, sender: T.Sender, payload: T.Payload) {
		if let type = T.self as? any BridgedNotification.Type {
			_bridgePost(T.self, type.self, sender: sender, payload: payload)
		} else {
			_post(T.self, sender: sender, payload: payload)
		}
	}
}

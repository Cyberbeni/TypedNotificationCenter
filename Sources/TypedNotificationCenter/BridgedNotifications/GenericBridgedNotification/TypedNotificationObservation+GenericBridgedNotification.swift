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

extension TypedNotificationCenter {
	// MARK: - Utility functions

	private func filter(_ notificationName: Notification.Name, sender: AnyObject)
		-> (nilObservations: Dictionary<ObjectIdentifier, WeakBox<_GenericBridgedNotificationObservation>>.Values?,
		    objectObservations: Dictionary<ObjectIdentifier, WeakBox<_GenericBridgedNotificationObservation>>.Values?)
	{
		let notificationIdentifier = notificationName
		let senderIdentifier = SenderIdentifier(sender)

		let observationsForNotification = bridgedObservers[notificationIdentifier]

		let nilObservations = observationsForNotification?[nilSenderIdentifier]?.values
		let objectObservations = observationsForNotification?[senderIdentifier]?.values

		return (nilObservations, objectObservations)
	}

	func forwardGenericPost(_ notificationName: Notification.Name, sender: AnyObject, payload: [AnyHashable: Any]) {
		var nilObservations: Dictionary<ObjectIdentifier, WeakBox<_GenericBridgedNotificationObservation>>.Values?
		var objectObservations: Dictionary<ObjectIdentifier, WeakBox<_GenericBridgedNotificationObservation>>.Values?
		observerLock.lock()
		(nilObservations, objectObservations) = filter(notificationName, sender: sender)
		observerLock.unlock()
		nilObservations?.forEach { observation in
			guard let observation = observation.object else { return }
			if let queue = observation.queue,
			   let block = observation.block
			{
				queue.addOperation {
					block(Notification(name: notificationName, object: sender, userInfo: payload))
				}
			} else {
				observation.block?(Notification(name: notificationName, object: sender, userInfo: payload))
			}
		}
		objectObservations?.forEach { observation in
			guard let observation = observation.object,
			      observation.sender != nil
			else { return }
			if let queue = observation.queue,
			   let block = observation.block
			{
				queue.addOperation {
					block(Notification(name: notificationName, object: sender, userInfo: payload))
				}
			} else {
				observation.block?(Notification(name: notificationName, object: sender, userInfo: payload))
			}
		}
	}

	// MARK: - Internal functions

	func remove(observation: _GenericBridgedNotificationObservation) {
		let notificationIdentifier = observation.notificationName
		let senderIdentifier = observation.senderIdentifier
		let observerIdentifier = ObjectIdentifier(observation)
		observerLock.lock()
		bridgedObservers[notificationIdentifier]?[senderIdentifier]?.removeValue(forKey: observerIdentifier)
		if bridgedObservers[notificationIdentifier]?[senderIdentifier]?.isEmpty == true {
			bridgedObservers[notificationIdentifier]?.removeValue(forKey: senderIdentifier)
		}
		observerLock.unlock()
	}

	// MARK: - Public interface

	public func observe(_ notificationName: Notification.Name, object: AnyObject?, queue: OperationQueue? = nil, block: @escaping (Notification) -> Void) -> TypedNotificationObservation {
		let observation = _GenericBridgedNotificationObservation(notificationCenter: self, notificationName: notificationName, sender: object, queue: queue, block: block)

		let notificationIdentifier = notificationName
		let senderIdentifier = observation.senderIdentifier
		let observerIdentifier = ObjectIdentifier(observation)
		let boxedObservation = WeakBox<_GenericBridgedNotificationObservation>(observation)

		observerLock.lock()
		if !nsnotificationObservers.keys.contains(notificationName) {
			nsnotificationObservers[notificationName] = _GenericNsNotificationObservation(notificationName: notificationName, sender: nil, queue: nil, block: { [weak self] notification in
				let sender = notification.object as AnyObject
				let payload = notification.userInfo ?? [:]
				self?.forwardGenericPost(notification.name, sender: sender, payload: payload)
			})
		}
		bridgedObservers[notificationIdentifier, default: [:]][senderIdentifier, default: [:]][observerIdentifier] = boxedObservation
		observerLock.unlock()

		return observation
	}
}

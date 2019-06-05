//
//  TypedNotificationCenter.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma.
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
    private let observerQueue: DispatchQueue
    private var observers = [NotificationIdentifier: [SenderIdentifier: [ObjectIdentifier: WeakBox]]]()
    
    // MARK: - Utility functions
    
    private func filter<T: TypedNotification>(sender: T.Sender, payload: T.Payload) -> (nilObservations: [_TypedNotificationObservation<T>]?, objectObservations: [_TypedNotificationObservation<T>]?) {
        let notificationIdentifier = NotificationIdentifier(T.self)
        let senderIdentifier = SenderIdentifier(sender)
        
        let observationsForNotification = observers[notificationIdentifier]
        let nilObservations = observationsForNotification?[nilSenderIdentifier]?.values.compactMap { $0.object as? _TypedNotificationObservation<T> }
        let objectObservations = observationsForNotification?[senderIdentifier]?.values.compactMap { (container) -> _TypedNotificationObservation<T>? in
            guard let observer = container.object as? _TypedNotificationObservation<T>,
                observer.isValid else {
                    return nil
            }
            return observer
        }
        
        return (nilObservations, objectObservations)
    }
    
    // MARK: - Internal functions
    
    func remove<T>(observation: _TypedNotificationObservation<T>) {
        let notificationIdentifier = NotificationIdentifier(T.self)
        let senderIdentifier = observation.senderIdentifier
        let observerIdentifier = ObjectIdentifier(observation)
        observerQueue.async {
            self.observers[notificationIdentifier]?[senderIdentifier]?.removeValue(forKey: observerIdentifier)
        }
    }
    
    // MARK: - Public interface
    
    public init(queueName: String = UUID().uuidString, queueQos: DispatchQoS = .userInitiated) {
        observerQueue = DispatchQueue(label: "TypedNotificationCenter.\(queueName)", qos: queueQos, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    }
    
    public static let `default` = TypedNotificationCenter(queueName: "default")
    
    public func observe<T: TypedNotification>(_ type: T.Type, object: T.Sender?, queue: OperationQueue? = nil, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
        let observation = _TypedNotificationObservation<T>(notificationCenter: self, sender: object, queue: queue, block: block)
        
        let notificationIdentifier = NotificationIdentifier(T.self)
        let senderIdentifier = observation.senderIdentifier
        let observerIdentifier = ObjectIdentifier(observation)
        let boxedObservation = WeakBox(observation)
        
        observerQueue.async {
            self.observers[notificationIdentifier, default: [:]][senderIdentifier, default: [:]][observerIdentifier] = boxedObservation
        }
        
        return observation
    }
    
    public func post<T: TypedNotification>(_ type: T.Type, sender: T.Sender, payload: T.Payload) {
        var nilObservations: [_TypedNotificationObservation<T>]?
        var objectObservations: [_TypedNotificationObservation<T>]?
        observerQueue.sync {
            (nilObservations, objectObservations) = self.filter(sender: sender, payload: payload)
        }
        nilObservations?.forEach { observation in
            if let queue = observation.queue,
                let block = observation.block {
                queue.addOperation {
                    block(sender, payload)
                }
            } else {
                observation.block?(sender, payload)
            }
        }
        objectObservations?.forEach { observation in
            guard observation.sender != nil else { return }
            if let queue = observation.queue,
                let block = observation.block {
                queue.addOperation {
                    block(sender, payload)
                }
            } else {
                observation.block?(sender, payload)
            }
        }
    }
}

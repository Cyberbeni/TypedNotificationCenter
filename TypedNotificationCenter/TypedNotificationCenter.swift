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

public final class TypedNotificationCenter {
    private let observerQueue: DispatchQueue
    private var observers = [WeakBox]()
    
    // MARK: - Utility functions
    
    private func filter<T: TypedNotification>(sender: T.Sender, payload: T.Payload) -> [_TypedNotificationObservation<T>] {
        return self.observers.compactMap { (container) -> _TypedNotificationObservation<T>? in
            guard let observer = container.object as? _TypedNotificationObservation<T>,
                observer.isValid,
                observer.sender == nil || observer.sender === sender else {
                    return nil
            }
            return observer
        }
    }
    
    // MARK: - Internal functions
    
    func remove(observation: ObjectIdentifier) {
        observerQueue.async {
            if let indexToRemove = self.observers.firstIndex(where: { $0.identifier == observation }) {
                self.observers.remove(at: indexToRemove)
            }
        }
    }
    
    // MARK: - Public interface
    
    public init(queueName: String = UUID().uuidString, queueQos: DispatchQoS = .userInitiated) {
        observerQueue = DispatchQueue(label: "TypedNotificationCenter.\(queueName)", qos: queueQos, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    }
    
    public static let `default` = TypedNotificationCenter(queueName: "default")
    
    public func observe<T: TypedNotification>(_ type: T.Type, object: T.Sender?, queue: OperationQueue? = nil, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
        let observation = _TypedNotificationObservation<T>(notificationCenter: self, sender: object, queue: queue, block: block)
        
        observerQueue.async {
            self.observers.append(WeakBox(observation))
        }
        
        return observation
    }
    
    public func post<T: TypedNotification>(_ type: T.Type, sender: T.Sender, payload: T.Payload) {
        var observationsToCall: [_TypedNotificationObservation<T>]?
        observerQueue.sync {
            observationsToCall = self.filter(sender: sender, payload: payload)
        }
        observationsToCall?.forEach { observation in
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

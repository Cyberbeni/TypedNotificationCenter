//
//  TypedNotificationCenter.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation

public final class TypedNotificationCenter {
    private let observerQueue = DispatchQueue(label: "TypedNotificationCenter.queue.\(UUID().uuidString)", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    private var observers = [TypedNotificationObservation]()
    
    // MARK: - Utility functions
    
    private func filter<T: TypedNotification>(sender: T.Sender, payload: T.Payload) -> [_TypedNotificationObservation<T>] {
        return self.observers.compactMap { (observer) -> _TypedNotificationObservation<T>? in
            guard let observer = observer as? _TypedNotificationObservation<T>,
                observer.isValid,
                observer.sender == nil || observer.sender === sender else {
                    return nil
            }
            return observer
        }
    }
    
    // MARK: - Public interface
    
    public static let `default` = TypedNotificationCenter()
    
    public func observe<T: TypedNotification>(_ type: T.Type, object: T.Sender?, queue: OperationQueue? = nil, block: @escaping T.ObservationBlock) -> TypedNotificationObservation {
        let observation = _TypedNotificationObservation<T>(notificationCenter: self, sender: object, queue: queue, block: block)
        
        observerQueue.async {
            self.observers.append(observation)
        }
        
        return observation
    }
    
    public func remove(observer: AnyObject) {
        observerQueue.async {
            if let indexToRemove = self.observers.firstIndex(where: { $0 === observer }) {
                self.observers.remove(at: indexToRemove)
            }
        }
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

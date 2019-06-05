//
//  PerformanceTestsSubscribing.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 06. 05.
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

import XCTest
import Foundation
@testable import TypedNotificationCenter

class PerformanceTestsSubscribing: XCTestCase {
    var sender: NSObject!
    
    // TypedNotificationCenter
    var notificationCenter: TypedNotificationCenter!
    var observations: [TypedNotificationObservation]!
    
    // Apple's NotificationCenter
    var aNotificationCenter: NotificationCenter!
    var aObservations: [Any]!
    
    override func setUp() {
        sender = NSObject()
        
        notificationCenter = TypedNotificationCenter()
        observations = [TypedNotificationObservation]()
        
        aNotificationCenter = NotificationCenter()
        aObservations = [Any]()
    }
    
    override func tearDown() {
        sender = nil
        
        notificationCenter = nil
        observations = nil
        
        aNotificationCenter = nil
        aObservations = nil
    }
    
    func testPerformance_own_nilSenders() {
        measure {
            for _ in 1...100 {
                TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: nil)
            }
            notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        }
    }
    
    func testPerformance_apple_nilSenders() {
        measure {
            for _ in 1...100 {
                for notificationName in TestData.notificationNames {
                    aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: nil, queue: nil) { _ in })
                }
            }
            aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
        }
    }
    
    func testPerformance_own_2senders() {
        measure {
            let otherSender = NSObject()
            TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
            TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: nil)
            for _ in 1...98 {
                TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: otherSender)
            }
            notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        }
    }
    
    func testPerformance_apple_2senders() {
        measure {
            let otherSender = NSObject()
            for notificationName in TestData.notificationNames {
                aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: sender, queue: nil) { _ in })
                aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: nil, queue: nil) { _ in })
            }
            for _ in 1...98 {
                for notificationName in TestData.notificationNames {
                    aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: otherSender, queue: nil) { _ in })
                }
            }
            aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
        }
    }
    
    func testPerformance_own_100senders() {
        measure {
            var otherSenders = [NSObject]()
            for _ in 1...99 {
                otherSenders.append(NSObject())
            }
            TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
            for otherSender in otherSenders {
                TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: otherSender)
            }
            notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        }
    }
    
    func testPerformance_apple_100senders() {
        measure {
            var otherSenders = [NSObject]()
            for _ in 1...99 {
                otherSenders.append(NSObject())
            }
            for notificationName in TestData.notificationNames {
                aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: sender, queue: nil) { _ in })
                for otherSender in otherSenders {
                    aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: otherSender, queue: nil) { _ in })
                }
            }
            aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
        }
    }
}

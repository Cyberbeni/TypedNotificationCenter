//
//  PerformanceTestsPosting.swift
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

import Foundation
@testable import TypedNotificationCenter
import XCTest

class PerformanceTestsPosting: TestCase {
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

    func testPerformance_all_own() {
        for _ in 1 ... 10 {
            TestData
                .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter,
                                sender: nil)
        }
        notificationCenter
            .post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        measure {
            for _ in 1 ... 500 {
                TestData.postToAll(sender: sender, notificationCenter: notificationCenter)
            }
        }
    }

    func testPerformance_all_own_concurrentPost() {
        for _ in 1 ... 10 {
            TestData
                .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter,
                                sender: nil)
        }
        notificationCenter
            .post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        var queues = [DispatchQueue]()
        for i in 1 ... 5 {
            queues.append(DispatchQueue(label: "TestQueue\(i)"))
        }
        measure {
            for queue in queues {
                queue.async {
                    for _ in 1 ... 100 {
                        TestData.postToAll(sender: self.sender, notificationCenter: self.notificationCenter)
                    }
                }
            }
            for queue in queues {
                queue.sync {}
            }
        }
    }

    func testPerformance_all_apple() {
        for _ in 1 ... 10 {
            for notificationName in TestData.notificationNames {
                aObservations
                    .append(aNotificationCenter!.addObserver(forName: notificationName, object: nil, queue: nil) { _ in
                    })
            }
        }
        aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
        measure {
            for _ in 1 ... 500 {
                for notificationName in TestData.notificationNames {
                    aNotificationCenter.post(name: notificationName, object: sender, userInfo: [:])
                }
            }
        }
    }

    func testPerformance_20percent_own() {
        let otherSender = NSObject()
        TestData
            .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
        TestData
            .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: nil)
        for _ in 1 ... 8 {
            TestData
                .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter,
                                sender: otherSender)
        }
        notificationCenter
            .post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        measure {
            for _ in 1 ... 500 {
                TestData.postToAll(sender: sender, notificationCenter: notificationCenter)
            }
        }
    }

    func testPerformance_20percent_apple() {
        let otherSender = NSObject()
        for notificationName in TestData.notificationNames {
            aObservations
                .append(aNotificationCenter!.addObserver(forName: notificationName, object: sender, queue: nil) { _ in
                })
            aObservations
                .append(aNotificationCenter!.addObserver(forName: notificationName, object: nil, queue: nil) { _ in })
        }
        for _ in 1 ... 8 {
            for notificationName in TestData.notificationNames {
                aObservations
                    .append(aNotificationCenter!
                        .addObserver(forName: notificationName, object: otherSender, queue: nil) { _ in })
            }
        }
        aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
        measure {
            for _ in 1 ... 500 {
                for notificationName in TestData.notificationNames {
                    aNotificationCenter.post(name: notificationName, object: sender, userInfo: [:])
                }
            }
        }
    }

    func testPerformance_1percent_own() {
        var otherSenders = [NSObject]()
        for _ in 1 ... 99 {
            otherSenders.append(NSObject())
        }
        TestData
            .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
        for otherSender in otherSenders {
            TestData
                .subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter,
                                sender: otherSender)
        }
        notificationCenter
            .post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
        measure {
            for _ in 1 ... 1000 {
                TestData.postToAll(sender: sender, notificationCenter: notificationCenter)
            }
        }
    }

    func testPerformance_1percent_apple() {
        var otherSenders = [NSObject]()
        for _ in 1 ... 99 {
            otherSenders.append(NSObject())
        }
        for notificationName in TestData.notificationNames {
            aObservations
                .append(aNotificationCenter!.addObserver(forName: notificationName, object: sender, queue: nil) { _ in
                })
            for otherSender in otherSenders {
                aObservations
                    .append(aNotificationCenter!
                        .addObserver(forName: notificationName, object: otherSender, queue: nil) { _ in })
            }
        }
        aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
        measure {
            for _ in 1 ... 1000 {
                for notificationName in TestData.notificationNames {
                    aNotificationCenter.post(name: notificationName, object: sender, userInfo: [:])
                }
            }
        }
    }
}

//
//  AsyncApiTests.swift
//  TypedNotificationCenterTests
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

import XCTest
@testable import TypedNotificationCenter

class AsyncApiTests: XCTestCase {
    var queue = OperationQueue()
    var observation: TypedNotificationObservation?
    var count = 0
    var sender: NSObject!

    override func setUp() {
        queue = OperationQueue()
        count = 0
        sender = NSObject()
    }

    override func tearDown() {
        observation = nil
    }

    func testSuspendedQueue() {
        queue.isSuspended = true
        let expectation = self.expectation(description: "Call Block")
        
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: sender, queue: queue, block: { _, _ in
            self.count += 1
            expectation.fulfill()
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        wait(2.0)
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times on suspended queue")
        
        queue.isSuspended = false
        
        self.wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(count, 1, "Observer block should've been called exactly once")
    }
    
    func testSuspendedQueueNilSender() {
        queue.isSuspended = true
        let expectation = self.expectation(description: "Call Block")
        
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, queue: queue, block: { _, _ in
            self.count += 1
            expectation.fulfill()
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        wait(2.0)
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times on suspended queue")
        
        queue.isSuspended = false
        
        self.wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(count, 1, "Observer block should've been called exactly once")
    }
}

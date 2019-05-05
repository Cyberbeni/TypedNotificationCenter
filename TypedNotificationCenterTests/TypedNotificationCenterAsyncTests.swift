//
//  TypedNotificationCenterAsyncTests.swift
//  TypedNotificationCenterTests
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import XCTest
@testable import TypedNotificationCenter

class TypedNotificationCenterAsyncTests: XCTestCase {
    var queue = OperationQueue()
    var observation: TypedNotificationObservation?
    var count = 0

    override func setUp() {
        queue = OperationQueue()
        count = 0
    }

    override func tearDown() {
    }

    func testSuspendedQueue() {
        queue.isSuspended = true
        let expectation = self.expectation(description: "Call Block")
        
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, queue: queue, block: { _, _ in
            expectation.fulfill()
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
        
        wait(2.0)
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times on suspended queue")
        
        queue.isSuspended = false
        
        self.wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(count, 1, "Observer block should've been called exactly once")
    }
}

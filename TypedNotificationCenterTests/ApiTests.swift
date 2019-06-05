//
//  ApiTests.swift
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

class ApiTests: XCTestCase {
    var observation: TypedNotificationObservation?
    var count = 0
    var sender: NSObject!
    
    override func setUp() {
        count = 0
        sender = NSObject()
    }

    override func tearDown() {
        observation = nil
    }

    func testNotificationWithoutObject() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 1, "Observer block should've been called once")
    }
    
    func testNotificationWithDifferentObject() {
        let otherObject = NSObject()
        
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: otherObject, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times")
    }
    
    func testNotificationWithSameObject() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: sender, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 1, "Observer block should've been called once")
    }
    
    func testInvalidateObserver() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: sender, block: { (sender, payload) in
            self.count += 1
        })
        
        observation?.invalidate()
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        observation?.invalidate()
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times")
    }
    
    func testDeallocateObserver() {
        _ = TypedNotificationCenter.default.observe(SampleNotification.self, object: sender, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times")
    }
    
    func testValidityRemoved() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, block: { (sender, payload) in
            self.count += 1
        })
        
        XCTAssertEqual(observation!.isValid, true, "Observer should be valid after adding it")
        
        observation?.invalidate()
        
        XCTAssertEqual(observation!.isValid, false, "Observer should be invalid after invalidating it")
    }
    
    func testValidityNotificationCenterDeallocated() {
        var notificationCenter: TypedNotificationCenter? = TypedNotificationCenter()
        observation = notificationCenter?.observe(SampleNotification.self, object: nil, block: { (sender, payload) in
            self.count += 1
        })
        
        XCTAssertEqual(observation!.isValid, true, "Observer should be valid after adding it")
        
        // Post syncs the queue, so TypedNotificationCenter won't be captured in any of the blocks anymore
        notificationCenter?.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        notificationCenter = nil
        
        XCTAssertEqual(observation!.isValid, false, "Observer should be invalid after the notification center deallocated")
    }
    
    func testValiditySenderDeallocated() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: sender, block: { (sender, payload) in
            self.count += 1
        })
        
        XCTAssertEqual(observation!.isValid, true, "Observer should be valid after adding it")
        
        // Post syncs the queue, so TypedNotificationCenter won't be captured in any of the blocks anymore
        TypedNotificationCenter.default.post(SampleNotification.self, sender: sender, payload: SampleNotification.Payload())
        
        sender = nil
        
        XCTAssertEqual(observation!.isValid, false, "Observer should be invalid after the sender deallocated")
    }
}

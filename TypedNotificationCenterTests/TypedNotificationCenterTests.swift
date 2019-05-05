//
//  TypedNotificationCenterTests.swift
//  TypedNotificationCenterTests
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import XCTest
@testable import TypedNotificationCenter

class TypedNotificationCenterTests: XCTestCase {
    var observation: TypedNotificationObservation?
    var count = 0
    
    override func setUp() {
        count = 0
    }

    override func tearDown() {
        observation = nil
    }

    func testNotificationWithoutObject() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: nil, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 1, "Observer block should've been called once")
    }
    
    func testNotificationWithDifferentObject() {
        let otherObject = NSObject()
        
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: otherObject, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 0, "Observer block should've been called zero times")
        
    }
    
    func testNotificationWithSameObject() {
        observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: self, block: { (sender, payload) in
            self.count += 1
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
        
        XCTAssertEqual(count, 1, "Observer block should've been called once")
    }
}

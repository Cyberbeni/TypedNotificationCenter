//
//  BridgedNotificationApiTests.swift
//  TypedNotificationCenter
// 
//  Created by Benedek Kozma on 2019. 06. 06.
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
import XCTest
@testable import TypedNotificationCenter

class BridgedNotificationApiTests: XCTestCase {
    func testSendingFromNotificationCenter() {
        let stringToSend = "TestString"
        let expectation = self.expectation(description: "Notification should arrive")
        let observation = TypedNotificationCenter.default.observe(SampleBridgedNotification.self, object: nil) { sender, payload in
            XCTAssert(payload.samplePayloadProperty == stringToSend, "Sent and received string should be the same")
            expectation.fulfill()
        }
        NotificationCenter.default.post(name: SampleBridgedNotification.notificationName, object: nil, userInfo: [SampleBridgedNotification.Payload.samplePayloadPropertyUserInfoKey:stringToSend])
        wait(for: [expectation], timeout: 1)
        XCTAssert(observation.isValid) // Removes unused variable warning
    }
}

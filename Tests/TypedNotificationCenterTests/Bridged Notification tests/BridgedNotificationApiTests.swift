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
@testable import TypedNotificationCenter
import XCTest

class BridgedNotificationApiTests: TestCase {
	let sender = MySender()

	override func tearDown() {
		TypedNotificationCenter.invalidSenderBlock = { _, _ in }
		TypedNotificationCenter.invalidPayloadBlock = { _, _, _ in }
	}

	func testCrossSendingFromNotificationCenter() {
		let stringToSend = "TestString"
		let expectation = self.expectation(description: "Notification should arrive")
		var count = 0
		let observation = TypedNotificationCenter.default.observe(SampleBridgedNotification.self, object: nil) { _, payload in
			XCTAssert(payload.samplePayloadProperty == stringToSend, "Sent and received string should be the same")
			count += 1
			expectation.fulfill()
		}
		NotificationCenter.default.post(name: SampleBridgedNotification.notificationName, object: sender, userInfo: [SampleBridgedNotification.Payload.samplePayloadPropertyUserInfoKey: stringToSend])
		wait(for: [expectation], timeout: 1)
		XCTAssertEqual(count, 1, "Observer block should've been called once")

		XCTAssertTrue(observation.isValid, "Observation should be valid by default")
		observation.invalidate()
		XCTAssertFalse(observation.isValid, "Observation should become invalid after calling invalidate")
		NotificationCenter.default.post(name: SampleBridgedNotification.notificationName, object: sender, userInfo: [SampleBridgedNotification.Payload.samplePayloadPropertyUserInfoKey: stringToSend])
		wait(0.1)
		XCTAssertEqual(count, 1, "Observer block should've been called once")
	}

	func testCrossSendingFromTypedNotificationCenter() {
		let stringToSend = "TestString"
		let expectation = self.expectation(description: "Notification should arrive")
		let observation = NotificationCenter.default.addObserver(forName: SampleBridgedNotification.notificationName, object: nil, queue: nil) { notification in
			XCTAssert(stringToSend == notification.userInfo?[SampleBridgedNotification.Payload.samplePayloadPropertyUserInfoKey] as? String)
			expectation.fulfill()
		}
		TypedNotificationCenter.default.post(SampleBridgedNotification.self, sender: sender, payload: SampleBridgedNotification.Payload(samplePayloadProperty: stringToSend))
		wait(for: [expectation], timeout: 1)
		NotificationCenter.default.removeObserver(observation)
	}

	func testSending() {
		let stringToSend = "TestString"
		let expectation = self.expectation(description: "Notification should arrive")
		let observation = TypedNotificationCenter.default.observe(SampleBridgedNotification.self, object: nil) { _, payload in
			XCTAssert(payload.samplePayloadProperty == stringToSend, "Sent and received string should be the same")
			expectation.fulfill()
		}
		TypedNotificationCenter.default.post(SampleBridgedNotification.self, sender: sender, payload: SampleBridgedNotification.Payload(samplePayloadProperty: stringToSend))
		wait(for: [expectation], timeout: 1)
		_ = observation
	}

	func testInvalidSender() {
		let stringToSend = "TestString"
		let expectation = self.expectation(description: "Invalid sender block should be called")
		TypedNotificationCenter.invalidSenderBlock = { _, _ in
			expectation.fulfill()
		}
		let observation = TypedNotificationCenter.default.observe(SampleBridgedNotification.self, object: nil) { _, _ in
			XCTFail("Notification should not arrive")
		}
		NotificationCenter.default.post(name: SampleBridgedNotification.notificationName, object: nil, userInfo: [SampleBridgedNotification.Payload.samplePayloadPropertyUserInfoKey: stringToSend])
		wait(for: [expectation], timeout: 1)
		_ = observation
	}

	func testInvalidPayload() {
		let expectation = self.expectation(description: "Invalid payload block should be called")
		TypedNotificationCenter.invalidPayloadBlock = { error, _, _ in
			XCTAssertEqual(error.localizedDescription, String(describing: error))
			expectation.fulfill()
		}
		let observation = TypedNotificationCenter.default.observe(SampleBridgedNotification.self, object: nil) { _, _ in
			XCTFail("Notification should not arrive")
		}
		NotificationCenter.default.post(name: SampleBridgedNotification.notificationName, object: sender, userInfo: nil)
		wait(for: [expectation], timeout: 1)
		_ = observation
	}
}

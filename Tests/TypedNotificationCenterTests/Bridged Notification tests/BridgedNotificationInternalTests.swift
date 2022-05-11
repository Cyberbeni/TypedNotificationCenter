//
//  BridgedNotificationInternalTests.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2021. 03. 23.
//  Copyright (c) 2021. Benedek Kozma
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

class BridgedNotificationInternalTests: TestCase {
	let notificationName = Notification.Name("TestNotificationName")
	let sender = MySender()

	var aNotificationCenter: NotificationCenter!
	var notificationCenter: TypedNotificationCenter!

	override func setUp() {
		super.setUp()
		aNotificationCenter = NotificationCenter()
		notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
	}

	override func tearDown() {
		super.tearDown()
		notificationCenter = nil
	}

	func testInvalidateNsObservations() throws {
		let observation1 = notificationCenter.observe(notificationName, object: nil, block: { _ in XCTFail("Block shouldn't be called after invalidating the internal observers") })
		let observation2 = notificationCenter.observe(SampleBridgedNotification.self, object: nil, block: { _, _ in XCTFail("Block shouldn't be called after invalidating the internal observers") })
		let internalObservation1 = try XCTUnwrap(notificationCenter.bridgedNsnotificationObservers[SampleBridgedNotification.notificationName])
		XCTAssertTrue(internalObservation1.isValid)
		internalObservation1.invalidate()
		XCTAssertFalse(internalObservation1.isValid)
		let internalObservation2 = try XCTUnwrap(notificationCenter.genericNsnotificationObservers[notificationName])
		XCTAssertTrue(internalObservation2.isValid)
		internalObservation2.invalidate()
		XCTAssertFalse(internalObservation2.isValid)
		NotificationCenter.default.post(name: notificationName, object: sender, userInfo: nil)
		NotificationCenter.default.post(name: SampleBridgedNotification.notificationName, object: sender, userInfo: SampleBridgedNotification.Payload(samplePayloadProperty: "text").asDictionary())
		_ = observation1
		_ = observation2
	}
}

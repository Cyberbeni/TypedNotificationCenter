//
//  NotificationNameApiTests.swift
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
import TypedNotificationCenter
import XCTest

class NotificationNameApiTests: TestCase {
	let notificationName = Notification.Name("TestNotificationName")
	let sender = MySender()
	let otherSender = MySender()

	func testCrossSendingFromNotificationCenter() {
		let notificationCenter = TypedNotificationCenter()

		var count = 0
		let observation1 = notificationCenter.observe(notificationName, object: nil) { _ in
			count += 1
		}
		let observation2 = notificationCenter.observe(notificationName, object: sender) { _ in
			count += 1
		}
		NotificationCenter.default.post(name: notificationName, object: sender, userInfo: nil)
		XCTAssertEqual(count, 2, "Observer block should've been called twice")

		NotificationCenter.default.post(name: notificationName, object: otherSender, userInfo: nil)
		XCTAssertEqual(count, 3, "Observer block should've been called three times")

		XCTAssertTrue(observation1.isValid, "Observation should be valid by default")
		observation1.invalidate()
		XCTAssertFalse(observation1.isValid, "Observation should become invalid after calling invalidate")
		NotificationCenter.default.post(name: notificationName, object: sender, userInfo: nil)
		XCTAssertEqual(count, 4, "Observer block should've been called four times")
		_ = observation2
	}
}

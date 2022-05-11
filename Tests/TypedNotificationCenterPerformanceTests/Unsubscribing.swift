//
//  Unsubscribing.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2022. 05. 01.
//  Copyright (c) 2022. Benedek Kozma
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

class UnsubscribingTests: TestCase {
	let sender = NSObject()

	// TypedNotificationCenter
	var observations: [TypedNotificationObservation]!

	// Apple's NotificationCenter
	var aObservations: [Any]!

	override func setUp() {
		observations = [TypedNotificationObservation]()
		aObservations = [Any]()
	}

	override func tearDown() {
		observations = nil
		aObservations = nil
	}

	func test_1_own() {
		let aNotificationCenter = NotificationCenter()
		let notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
		for _ in 1 ... 60000 {
			observations.append(notificationCenter.observe(TestData.PerformanceTestNotification1.self, object: sender) { _, _ in })
		}
		notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
		measure {
			for observation in observations {
				observation.invalidate()
			}
			notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
		}
	}

	func test_1_apple() throws {
		try XCTSkipIf(Self.skipNsNotificationCenterTests, "Skipping NSNotificationCenter test")
		let aNotificationCenter = NotificationCenter()
		for _ in 1 ... 60000 {
			aObservations.append(aNotificationCenter.addObserver(forName: TestData.notificationNames.first!, object: sender, queue: nil) { _ in })
		}
		aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
		measure {
			for observation in aObservations {
				aNotificationCenter.removeObserver(observation)
			}
			aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
		}
	}

	func test_all_own() {
		let aNotificationCenter = NotificationCenter()
		let notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
		for _ in 1 ... 600 {
			TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
		}
		notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
		measure {
			for observation in observations {
				observation.invalidate()
			}
			notificationCenter.post(TestData.PerformanceTestNotification1.self, sender: sender, payload: TestData.DummyPayload())
		}
	}

	func test_all_apple() throws {
		try XCTSkipIf(Self.skipNsNotificationCenterTests, "Skipping NSNotificationCenter test")
		let aNotificationCenter = NotificationCenter()
		for _ in 1 ... 600 {
			for notificationName in TestData.notificationNames {
				aObservations.append(aNotificationCenter.addObserver(forName: notificationName, object: sender, queue: nil) { _ in })
			}
		}
		aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
		measure {
			for observation in aObservations {
				aNotificationCenter.removeObserver(observation)
			}
			aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
		}
	}
}

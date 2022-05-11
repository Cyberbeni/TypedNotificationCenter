//
//  BridgedNotification.swift
//  TypedNotificationCenterPerformanceTests
//
//  Created by Benedek Kozma on 2022. 04. 29.
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

class BridgedNotificationTests: TestCase {
	let sender = NSObject()
	let otherSender = NSObject()

	func test_subscribing_2senders_notificationName() {
		measureMetrics(Self.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
			let aNotificationCenter = NotificationCenter()
			let notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
			var observations = [TypedNotificationObservation]()
			startMeasuring()
			for _ in 1 ... 3 {
				for notificationName in TestData.notificationNames {
					observations.append(notificationCenter.observe(notificationName, object: sender, block: { _ in }))
					observations.append(notificationCenter.observe(notificationName, object: nil, block: { _ in }))
				}
				for _ in 1 ... 98 {
					for notificationName in TestData.notificationNames {
						observations.append(notificationCenter.observe(notificationName, object: otherSender, block: { _ in }))
					}
				}
			}
			aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
			stopMeasuring()
			observations.removeAll()
		}
	}

	func test_subscribing_2senders_bridgedNotification() {
		measureMetrics(Self.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
			let aNotificationCenter = NotificationCenter()
			let notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
			var observations = [TypedNotificationObservation]()
			startMeasuring()
			for _ in 1 ... 3 {
				TestData.subscribeToAllBridged(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
				TestData.subscribeToAllBridged(observationContainer: &observations, notificationCenter: notificationCenter, sender: nil)
				for _ in 1 ... 98 {
					TestData.subscribeToAllBridged(observationContainer: &observations, notificationCenter: notificationCenter, sender: otherSender)
				}
			}
			notificationCenter.post(TestData.PerformanceTestNotification1Bridged.self, sender: sender, payload: .init())
			stopMeasuring()
			observations.removeAll()
		}
	}

	func test_posting_20percent_notificationName() {
		let aNotificationCenter = NotificationCenter()
		let notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
		var observations = [TypedNotificationObservation]()

		for notificationName in TestData.notificationNames {
			observations.append(notificationCenter.observe(notificationName, object: sender, block: { _ in }))
			observations.append(notificationCenter.observe(notificationName, object: nil, block: { _ in }))
		}
		for _ in 1 ... 8 {
			for notificationName in TestData.notificationNames {
				observations.append(notificationCenter.observe(notificationName, object: otherSender, block: { _ in }))
			}
		}
		aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
		measure {
			for _ in 1 ... 250 {
				for notificationName in TestData.notificationNames {
					aNotificationCenter.post(name: notificationName, object: sender, userInfo: [:])
				}
			}
		}
	}

	func test_posting_20percent_bridgedNotification() {
		let aNotificationCenter = NotificationCenter()
		let notificationCenter = TypedNotificationCenter(nsNotificationCenterForBridging: aNotificationCenter)
		var observations = [TypedNotificationObservation]()

		TestData.subscribeToAllBridged(observationContainer: &observations, notificationCenter: notificationCenter, sender: sender)
		TestData.subscribeToAllBridged(observationContainer: &observations, notificationCenter: notificationCenter, sender: nil)
		for _ in 1 ... 8 {
			TestData.subscribeToAllBridged(observationContainer: &observations, notificationCenter: notificationCenter, sender: otherSender)
		}
		notificationCenter.post(TestData.PerformanceTestNotification1Bridged.self, sender: sender, payload: .init())
		aNotificationCenter.post(name: TestData.notificationNames.first!, object: sender, userInfo: [:])
		measure {
			for _ in 1 ... 250 {
				TestData.postToAllBridged(sender: sender, notificationCenter: notificationCenter)
			}
		}
	}
}

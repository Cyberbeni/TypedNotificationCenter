//
//  ViewController.swift
//  TypedNotificationCenterExample
//
//  Created by Benedek Kozma on 2019. 05. 05.
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

import TypedNotificationCenter
import UIKit

class ViewController: UIViewController {
	@IBOutlet var testingTextField: UITextField! {
		didSet {
			testingTextField.accessibilityIdentifier = "testingTextField"
		}
	}

	@IBOutlet var testResultLabel: UILabel! {
		didSet {
			testResultLabel.text = "KeyboardNotificationTesting in progress"
		}
	}

	var observations = [TypedNotificationObservation]()
	let notificationCenter = TypedNotificationCenter.default
	var receivedNotifications = Set<ObjectIdentifier>()

	override func viewDidLoad() {
		super.viewDidLoad()

		observe(UIResponder.KeyboardWillShowNotification.self)
		observe(UIResponder.KeyboardDidShowNotification.self)
		observe(UIResponder.KeyboardWillHideNotification.self)
		observe(UIResponder.KeyboardDidHideNotification.self)
		observe(UIResponder.KeyboardWillChangeFrameNotification.self)
		observe(UIResponder.KeyboardDidChangeFrameNotification.self)
	}

	private func observe<T: BridgedNotification>(_ type: T.Type) {
		observations.append(notificationCenter.observe(type.self, object: nil, block: { [weak self] _, payload in
			var userInfo = payload.asDictionary()
			if #available(iOS 9.0, *) {
				userInfo.removeValue(forKey: UIResponder.keyboardIsLocalUserInfoKey)
				_ = try? UIResponder.KeyboardNotificationPayload(userInfo)
			}
			userInfo.removeValue(forKey: UIResponder.keyboardFrameEndUserInfoKey)
			_ = try? UIResponder.KeyboardNotificationPayload(userInfo)
			self?.addToReceivedNotifications(type.self)
        }))
	}

	private func addToReceivedNotifications<T: BridgedNotification>(_ type: T.Type) {
		receivedNotifications.insert(ObjectIdentifier(type))
		if receivedNotifications.count == 6 {
			testResultLabel.text = "KeyboardNotificationTesting passed"
		}
	}
}

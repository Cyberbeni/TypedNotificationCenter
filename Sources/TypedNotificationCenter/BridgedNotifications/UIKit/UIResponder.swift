//
//  UIResponder.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2019. 06. 05.
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

#if os(iOS)
	import UIKit

	public extension UIResponder {
		struct KeyboardNotificationPayload: DictionaryRepresentable {
			public init(_ dictionary: [AnyHashable: Any]) throws {
				guard let keyboardAnimationCurve = (dictionary[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber).flatMap({ UIView.AnimationCurve(rawValue: $0.intValue) }),
				      let keyboardAnimationDuration = dictionary[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
				      let keyboardFrameBegin = dictionary[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
				      let keyboardFrameEnd = dictionary[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
				else {
					throw NotificationDecodingError(type: type(of: self), source: dictionary)
				}
				var keyboardIsLocal = true
				if #available(iOS 9.0, *) {
					guard let keyboardIsLocalNumber = dictionary[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber else {
						throw NotificationDecodingError(type: type(of: self), source: dictionary)
					}
					keyboardIsLocal = keyboardIsLocalNumber.boolValue
				}
				self.keyboardIsLocal = keyboardIsLocal
				self.keyboardAnimationCurve = keyboardAnimationCurve
				self.keyboardAnimationDuration = keyboardAnimationDuration.doubleValue
				self.keyboardFrameBegin = keyboardFrameBegin.cgRectValue
				self.keyboardFrameEnd = keyboardFrameEnd.cgRectValue
			}

			public func asDictionary() -> [AnyHashable: Any] {
				var retVal = [AnyHashable: Any]()

				retVal[UIResponder.keyboardAnimationCurveUserInfoKey] = NSNumber(value: keyboardAnimationCurve.rawValue)
				retVal[UIResponder.keyboardAnimationDurationUserInfoKey] = NSNumber(value: keyboardAnimationDuration)
				if #available(iOS 9.0, *) {
					retVal[UIResponder.keyboardIsLocalUserInfoKey] = NSNumber(value: keyboardIsLocal)
				}
				retVal[UIResponder.keyboardFrameBeginUserInfoKey] = NSValue(cgRect: keyboardFrameBegin)
				retVal[UIResponder.keyboardFrameEndUserInfoKey] = NSValue(cgRect: keyboardFrameEnd)

				return retVal
			}

			public let keyboardAnimationCurve: UIView.AnimationCurve
			public let keyboardAnimationDuration: Double
			/// Only available since iOS 9.0, constant true on earlier iOS versions
			public let keyboardIsLocal: Bool
			public let keyboardFrameBegin: CGRect
			public let keyboardFrameEnd: CGRect
		}

		enum KeyboardWillShowNotification: BridgedNotification {
			public static var notificationName: Notification.Name = UIResponder.keyboardWillShowNotification
			public typealias Sender = NSNull
			public typealias Payload = KeyboardNotificationPayload
		}

		enum KeyboardDidShowNotification: BridgedNotification {
			public static var notificationName: Notification.Name = UIResponder.keyboardDidShowNotification
			public typealias Sender = NSNull
			public typealias Payload = KeyboardNotificationPayload
		}

		enum KeyboardWillHideNotification: BridgedNotification {
			public static var notificationName: Notification.Name = UIResponder.keyboardWillHideNotification
			public typealias Sender = NSNull
			public typealias Payload = KeyboardNotificationPayload
		}

		enum KeyboardDidHideNotification: BridgedNotification {
			public static var notificationName: Notification.Name = UIResponder.keyboardDidHideNotification
			public typealias Sender = NSNull
			public typealias Payload = KeyboardNotificationPayload
		}

		enum KeyboardWillChangeFrameNotification: BridgedNotification {
			public static var notificationName: Notification.Name = UIResponder.keyboardWillChangeFrameNotification
			public typealias Sender = NSNull
			public typealias Payload = KeyboardNotificationPayload
		}

		enum KeyboardDidChangeFrameNotification: BridgedNotification {
			public static var notificationName: Notification.Name = UIResponder.keyboardDidChangeFrameNotification
			public typealias Sender = NSNull
			public typealias Payload = KeyboardNotificationPayload
		}
	}

#endif

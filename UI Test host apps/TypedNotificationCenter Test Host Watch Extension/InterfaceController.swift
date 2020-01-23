//
//  InterfaceController.swift
//  TypedNotificationCenterExampleWatch Extension
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

import Foundation
import TypedNotificationCenter
import WatchKit

class InterfaceController: WKInterfaceController {
	var observation: Any?

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()

		observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: self, block: { sender, payload in
			print("IT WORKS! sender: \(sender), payload: \(payload)")
        })

		TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
	}
}

//
//  main.swift
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

guard CommandLine.arguments.count == 2 else {
    exit(1)
}

let baseName = "PerformanceTestNotification"
let numberOfNotifications = 100
let outputFile = CommandLine.arguments[1]

var names = [String]()

var output = """
// Generated by 'GenerateTestCode' target

import Foundation
@testable import TypedNotificationCenter

enum TestData {

    struct DummyPayload {
        var name = "test"
    }

    static func subscribeToAll(observationContainer: inout [TypedNotificationObservation], notificationCenter: TypedNotificationCenter, sender: AnyObject?) {

"""

for i in 1...numberOfNotifications {
    let newName = "\(baseName)\(i)"
    names.append(newName)
    output.append("""
        observationContainer.append(notificationCenter.observe(\(newName).self, object: sender) { _, _ in })

""")
}

output.append("""
    }

    static func postToAll(sender: AnyObject, notificationCenter: TypedNotificationCenter) {

""")

for name in names {
    output.append("        notificationCenter.post(\(name).self, sender: sender, payload: DummyPayload())\n")
}

output.append("""
    }

    static var notificationNames: [Notification.Name] = [

""")

for name in names {
    output.append("        Notification.Name(rawValue: \"\(name)\"),\n")
}

output.append("""
    ]


""")

for name in names {
    output.append("""
    enum \(name): TypedNotification {
        typealias Sender = AnyObject
        typealias Payload = DummyPayload
    }


""")
}

output.append("}\n")

do {
    try output.write(toFile: outputFile, atomically: true, encoding: .utf8)
} catch {
    print(error)
    exit(1)
}

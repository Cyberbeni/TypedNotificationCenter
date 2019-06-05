//
//  TypedNotificationCenterPerformanceTests.swift
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

import XCTest
import Foundation
@testable import TypedNotificationCenter

class TypedNotificationCenterPerformanceTests: XCTestCase {
    var sender: NSObject!
    
    // TypedNotificationCenter
    var notificationCenter: TypedNotificationCenter!
    var observations: [TypedNotificationObservation]!
    
    // Apple's NotificationCenter
    var aNotificationCenter: NotificationCenter!
    var aObservations: [Any]!
    
    override func setUp() {
        sender = NSObject()
        
        notificationCenter = TypedNotificationCenter()
        observations = [TypedNotificationObservation]()
        
        aNotificationCenter = NotificationCenter()
        aObservations = [Any]()
    }
    
    func testPerformanceIncludingSubscribing_own_all() {
        measure {
            for _ in 1...10 {
                TestData.subscribeToAll(observationContainer: &observations, notificationCenter: notificationCenter)
            }
//            for _ in 1...1000 {
                TestData.postToAll(sender: sender, notificationCenter: notificationCenter)
//            }
        }
    }
    
    func testPerformanceIncludingSubscribing_apple_all() {
        measure {
            for _ in 1...10 {
                for notificationName in TestData.notificationNames {
                    aObservations.append(aNotificationCenter!.addObserver(forName: notificationName, object: nil, queue: nil) { _ in })
                }
            }
//            for _ in 1...1000 {
            for notificationName in TestData.notificationNames {
                aNotificationCenter.post(name: notificationName, object: sender, userInfo: [:])
            }
//            }
        }
    }
}

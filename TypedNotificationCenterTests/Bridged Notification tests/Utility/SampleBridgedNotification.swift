//
//  SampleBridgedNotification.swift
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

enum SampleBridgedNotification: BridgedNotification {
    static var notificationName = Notification.Name("TypedNotificationCenter.SampleBridgedNotification")
    
    struct Payload: DictionaryRepresentable {
        init(samplePayloadProperty: String) {
            self.samplePayloadProperty = samplePayloadProperty
        }
        
        init(_ dictionary: [AnyHashable : Any]) throws {
            guard let samplePayloadProperty = dictionary[Payload.samplePayloadPropertyUserInfoKey] as? String else {
                throw NotificationDecodingError(type: type(of: self), dictionary: dictionary)
            }
            self.samplePayloadProperty = samplePayloadProperty
        }
        
        func asDictionary() -> [AnyHashable : Any] {
            var retVal = [AnyHashable : Any]()
            
            retVal[Payload.samplePayloadPropertyUserInfoKey] = samplePayloadProperty as NSString
            
            return retVal
        }
        
        static let samplePayloadPropertyUserInfoKey = "samplePayloadPropertyUserInfoKey"
        let samplePayloadProperty: String

    }
    
    typealias Sender = AnyObject
}
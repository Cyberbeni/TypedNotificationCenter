//
//  PDFView.swift
//  TypedNotificationCenter
//
//  Created by Benedek Kozma on 2023. 01. 16.
//  Copyright (c) 2023. Benedek Kozma
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

// TODO: It should be available for macOS too but Xcode 14.2 gives compiler error
#if os(iOS)
	import PDFKit

	@available(macCatalyst 13.1, *)
	public extension PDFView {
		enum AnnotationHitNotification: BridgedNotification {
			public static var notificationName: Notification.Name = .PDFViewAnnotationHit
			public typealias Sender = PDFView
			public struct Payload: DictionaryRepresentable {
				let annotation: PDFAnnotation

				private static let PDFAnnotationHitKey = "PDFAnnotationHit"
				public init(_ dictionary: [AnyHashable: Any]) throws {
					guard let annotation = dictionary[Self.PDFAnnotationHitKey] as? PDFAnnotation else {
						throw NotificationDecodingError(type: type(of: self), source: dictionary)
					}
					self.annotation = annotation
				}

				public func asDictionary() -> [AnyHashable: Any] {
					var retVal = [AnyHashable: Any]()
					retVal[Self.PDFAnnotationHitKey] = annotation
					return retVal
				}
			}
		}
	}
#endif

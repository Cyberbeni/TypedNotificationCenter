//
//  XCTestCase+Utils.swift
//  TypedNotificationCenterTests
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func wait(_ seconds: Double) {
        let expectation = self.expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: seconds + 1)
    }
}

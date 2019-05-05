//
//  InterfaceController.swift
//  TypedNotificationCenterExampleWatch Extension
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import WatchKit
import Foundation
import TypedNotificationCenter

class InterfaceController: WKInterfaceController {
    var observation: Any?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: self, block: { (sender, payload) in
            print("IT WORKS! sender: \(sender), payload: \(payload)")
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

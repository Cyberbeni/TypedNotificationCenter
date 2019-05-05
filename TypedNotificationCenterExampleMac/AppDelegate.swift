//
//  AppDelegate.swift
//  TypedNotificationCenterExampleMac
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import Cocoa
import TypedNotificationCenter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var observation: Any?

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        self.observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: self, block: { (sender, payload) in
            print("IT WORKS! sender: \(sender), payload: \(payload)")
        })
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


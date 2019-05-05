//
//  ViewController.swift
//  TypedNotificationCenterExampleTV
//
//  Created by Benedek Kozma on 2019. 05. 05..
//  Copyright © 2019. Benedek Kozma. All rights reserved.
//

import UIKit
import TypedNotificationCenter

class ViewController: UIViewController {
    var observation: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observation = TypedNotificationCenter.default.observe(SampleNotification.self, object: self, block: { (sender, payload) in
            print("IT WORKS! sender: \(sender), payload: \(payload)")
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        TypedNotificationCenter.default.post(SampleNotification.self, sender: self, payload: SampleNotification.Payload())
    }
}

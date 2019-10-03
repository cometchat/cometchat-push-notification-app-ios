//
//  IncomingCall.swift
//  CometChatPro-PushNotification-SampleApp
//
//  Created by MacMini-03 on 18/07/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit

class IncomingCall: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func callAccepted(_ sender: Any) {
          self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callRejected(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

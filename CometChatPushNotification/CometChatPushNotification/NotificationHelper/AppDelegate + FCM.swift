//
//  AppDelegate + FCM.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 06/09/23.
//

import Foundation
import Firebase
import CometChatSDK


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        guard let fcmToken = fcmToken else { return }
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        CometChat.registerTokenForPushNotification(token: fcmToken, onSuccess: { (sucess) in
            print("token registered \(sucess)")
        }) { (error) in
            print("token registered error \(String(describing: error?.errorDescription))")
        }
        
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

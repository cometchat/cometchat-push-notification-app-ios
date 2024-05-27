//
//  AppDelegate + CometChatPN.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift
import Firebase

extension AppDelegate: UNUserNotificationCenterDelegate ,MessagingDelegate { 
    //Registering PN Token on CometChat server
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if CometChat.getLoggedInUser() != nil {
            
            if Constants.notificationMode == .FCM {
                cometchatFCMHelper.registerTokenForPushNotification(deviceToken: deviceToken)
            }
            if Constants.notificationMode == .APNs {
                cometchatAPNsHelper.registerTokenForPushNotification(deviceToken: deviceToken)
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("registerTokenForPushNotification failed with error: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent notification: \(notification.request.content.userInfo)")
        let userInfo = notification.request.content.userInfo
        if Constants.notificationMode == .FCM {
            if let type = userInfo["type"] as? String, type == "chat" {
                completionHandler([.alert, .badge, .sound])
            } else {
                completionHandler([])
            }
        } else {
            completionHandler([.alert, .badge, .sound])
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if Constants.notificationMode == .FCM {
            cometchatFCMHelper.presentMessageFromPayload(response: response)
        }
        
        if Constants.notificationMode == .APNs {
            cometchatAPNsHelper.presentMessageFromPayload(response: response)
        }
        
        let userInfo = response.notification.request.content.userInfo
        CometChatPNHelper.handleNotification(userInfo: userInfo, completionHandler: completionHandler)
    }
}

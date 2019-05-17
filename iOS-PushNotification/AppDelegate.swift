//
//  AppDelegate.swift
//  iOS-PushNotification
//
//  Created by Admin1 on 29/03/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit
import CometChatPro
import Firebase
import UserNotifications
import PNExtension

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initialization()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        return true
    }
    
    func initialization(){
        
        CometChat(appId: Constants.appID, onSuccess: { (Success) in
           print("Initialization Sucess \(Success)")
        }) { (error) in
            print("Initialization Sucess \(error)")
        }
    }
    

    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print( "Message ID: \(messageID)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print( "Message ID: \(messageID)")
        }
        // Print full message.
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print( "Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print( "APNs token retrieved: \(deviceToken)")
        
        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        // kDeviceToken=tokenString
        print( "deviceToken: \(tokenString)")
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
         CometChat.startServices()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
         CometChat.startServices()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
       
    }


}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
       
        
        if let userInfo = (notification.request.content.userInfo as? [String : Any]){
            
            let messageObject = userInfo["message"]
          
            if let someString = messageObject as? String {
                
                if let dict = someString.stringTodict(){
                    
                    PNExtension.getMessageFrom(json: dict, onSuccess: { (message) in
                        
                        switch message.messageType{
                        case .text:
                            print("received text Message Object: \(String(describing: (message as? TextMessage)?.stringValue()))")
                            print("received text Message \(String(describing: (message as? TextMessage)?.text))");
                            
                        case .image:
                            print("received image Message Object:\(String(describing: (message as? MediaMessage)?.stringValue()))")
                            print("received text Message \(String(describing: (message as? MediaMessage)?.url))");
                        case .video:
                            print("received video Message Object:\(String(describing: (message as? MediaMessage)?.stringValue()))")
                            print("received video Message \(String(describing: (message as? MediaMessage)?.url))");
                        case .audio:
                            print("received audio Message Object:\(String(describing: (message as? MediaMessage)?.stringValue()))")
                            print("received audio Message \(String(describing: (message as? MediaMessage)?.url))");
                        case .file:
                            print("received file Message Object:\(String(describing: (message as? MediaMessage)?.stringValue()))")
                            print("received file Message \(String(describing: (message as? MediaMessage)?.url))");
                        case .groupMember: break
                        case .custom:
                            print("received custom Message Object:\(String(describing: (message as? CustomMessage)?.stringValue()))")
                            print("received custom Message \(String(describing: (message as? CustomMessage)?.customData))")
                        @unknown default: break
                        }
                    }) { (error) in
                        
                        print("error %@",error.errorDescription);
                    }
                }
            }
        }
        
        // Change this to your preferred presentation option
         completionHandler([.alert, .badge, .sound])
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = response.notification.request.content.userInfo
        // Print message ID.
        completionHandler()
    }
    
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension String {
    
    
    func stringTodict() -> [String:Any]? {
        
        var dictonary:[String:Any]?
        
        if let data = self.data(using: .utf8) {
            
            do {
                dictonary =  try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                
                if let myDictionary = dictonary
                {
                    return myDictionary;
                }
            } catch let error as NSError {
                print(error)
            }
            
        }
        return dictonary;
    }
}

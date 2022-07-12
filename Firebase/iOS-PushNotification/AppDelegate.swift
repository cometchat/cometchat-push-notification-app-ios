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
import PushKit
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var blockedUsersArray = [String]()
    let blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 100).build();
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.initialization()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        CometChat.calldelegate = self
        CometChat.messagedelegate = self
        if((UserDefaults.standard.object(forKey: "LoggedInUserID")) != nil){
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "navigationController") as! NavigationController
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
            getBlockedUser()
        }
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
        
        Messaging.messaging().isAutoInitEnabled = true
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func initialization(){
        
        let appSettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: Constants.region).build()
        
        CometChat.init(appId: Constants.appID, appSettings: appSettings, onSuccess: { (Success) in
            print("initialization Success: \(Success)")
            
        }) { (error) in
            print( "Initialization Error \(error.errorDescription)")
        }
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        
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
    
    
    func getBlockedUser(){
        blockedUserRequest.fetchNext(onSuccess : { (users) in
            print("blocked users : \(String(describing: users))")
            
            for user in users! {
                self.blockedUsersArray.append(user.uid!)
            }
            var defaults = UserDefaults.standard
            defaults = UserDefaults(suiteName: "group.com.inscripts.comatchat.dev2")!
            defaults.set(self.blockedUsersArray, forKey: "blockedUsers")
            print("blockedUSersArray: \(self.blockedUsersArray)")
        }, onError : { (error) in
            print("error while fetching the blocked user request :  \(String(describing: error?.errorDescription))")
        })
        
        
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
        
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
        voipRegistry.delegate = self
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.initialization()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UserDefaults(suiteName: "group.com.inscripts.cometchat.dev2")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.initialization()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func presentCall(){
        DispatchQueue.main.async {
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "incomingCall") as? IncomingCall {
                if let window = self.window, let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    controller.modalPresentationStyle = .custom
                    currentController.present(controller, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    
}

extension AppDelegate : CometChatCallDelegate {
    
    
    func onIncomingCallReceived(incomingCall: Call?, error: CometChatException?) {
        print("incoming Call Received : \(String(describing: incomingCall?.stringValue()))")
        self.presentCall()
        
    }
    
    func onOutgoingCallAccepted(acceptedCall: Call?, error: CometChatException?) {
        
    }
    
    func onOutgoingCallRejected(rejectedCall: Call?, error: CometChatException?) {
        
    }
    
    func onIncomingCallCancelled(canceledCall: Call?, error: CometChatException?) {
        
    }
    
    
}





// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        var sender:String = String()
        var type :String = String()
        
        if let userInfo = (notification.request.content.userInfo as? [String : Any]){
            

            let messageObject = userInfo["message"]
            
//
//            if let someString = messageObject as? String {
//
//                if let dict = someString.stringTodictionary(){
//
//                    sender = dict["sender"] as? String ?? ""
//                    type = dict["type"] as! String
//
//                  print("BaseMessage Object: \(CometChat.processMessage(dict))")
//                }
//            }
        }

        
        if(blockedUsersArray.contains(sender)){
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(notification.request.identifier)"])
        }else if(type == "audio") || (type == "video"){
        
        }else{
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: @escaping () -> Void) {
           if let userInfo = (response.notification.request.content.userInfo as? [String : Any]){
               let messageObject = userInfo["message"]
               if let someString = messageObject as? String {
                   if let dict = someString.stringTodictionary(){
                       print("Call Object: \(CometChat.processMessage(dict))")
                       if let currentcall = CometChat.processMessage(dict).0 as? Call {
                           DispatchQueue.main.async {
                            self.presentCall()
                           }
                       }
                   }
               }
           }
           completionHandler()
       }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict:[String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        if let token = fcmToken , CometChat.getLoggedInUser() != nil {
            
            CometChat.registerTokenForPushNotification(token: token, onSuccess: { (sucess) in
                print("token registered \(sucess)")
            }) { (error) in
                print("token registered error \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    
//    // [START refresh_token]
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(fcmToken)")
//        print("Firebase registration token1: \(Messaging.messaging().fcmToken)")
//
//
//
//        let dataDict:[String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//    }
//
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
    // [END ios_10_data_message]
}

extension AppDelegate : CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        
        print("message is: \(textMessage.stringValue())")
    }
}


extension AppDelegate : PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        if pushCredentials.token.count == 0 {
            print("voip token NULL")
            return
        }
        //print out the VoIP token. We will use this to test the notification.
         let   tokenString = pushCredentials.token.reduce("", {$0 + String(format: "%02X",    $1)})
        print("voip token \(tokenString)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        let message = payloadDict?["alert"]
        
        //present a local notifcation to visually see when we are recieving a VoIP Notification
        if UIApplication.shared.applicationState == UIApplication.State.background {
            
            let localNotification = UILocalNotification()
            localNotification.alertBody = message
            localNotification.applicationIconBadgeNumber = 1
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            UIApplication.shared.presentLocalNotificationNow(localNotification);
        }
            
        else {
            DispatchQueue.main.async {
                
                let alert = UIAlertView(title: "VoIP Notification", message: message, delegate: nil, cancelButtonTitle: "Ok");
                alert.show()
            }
        }
        NSLog("incoming voip notfication: \(payload.dictionaryPayload)")
    }
    
   
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
          NSLog("token invalidated")
    }

}



extension String {
    
    func stringTodictionary() -> [String:Any]? {
        
        var dictonary:[String:Any]?
        
        if let data = self.data(using: .utf8) {
            
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                
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




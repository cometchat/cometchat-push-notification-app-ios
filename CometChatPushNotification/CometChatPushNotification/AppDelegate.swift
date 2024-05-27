//
//  AppDelegate.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import UIKit
import CometChatUIKitSwift
import CometChatSDK
import CometChatCallsSDK
import Firebase
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var pushRegistry: PKPushRegistry!
    let cometchatAPNsHelper = CometChatAPNsHelper()
    let cometchatFCMHelper = CometChatFCMHelper()
    var currentChatIdentifier: String?
    var currentChatType: String?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        //MARK: Configuring PushNotification Starts
        if Constants.notificationMode == .FCM {
            cometchatFCMHelper.configurePushNotification(application: application, delegate: self)
        }
        
        if Constants.notificationMode == .APNs{
            cometchatAPNsHelper.configurePushNotification(application: application, delegate: self)
        }
        //MARK: Configuring PushNotification Ends
        initializeUIKit()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func initializeUIKit() {
        
        if(Constants.appId.contains("Enter") || Constants.appId.contains("ENTER") || Constants.appId.contains("NULL") || Constants.appId.contains("null") || Constants.appId.count == 0) {
        } else {
            let uikitSettings = UIKitSettings()
            
            uikitSettings.set(appID: Constants.appId)
                .set(authKey: Constants.authKey)
                .set(region: Constants.region)
                .setExtensionGroupID(id: "group.notification.for.markAsDelivered")
                .build()
            
            let metaInfo = [
                "sampleAppFor": "enhanced-push-notification",
                "name": "iOS \(Constants.notificationMode == .FCM ? "FCM" : "APNs") Push Notification Sample App",
                "type": "sample",
                "version": Bundle.main.infoDictionary!["CFBundleShortVersionString"],
                "bundle": Bundle.main.bundleIdentifier,
                "platform": "iOS"
            ]
            
            CometChat.set(demoMetaInfo: metaInfo as [String : Any])
            
            CometChatUIKit.init(uiKitSettings: uikitSettings, result: {
                result in
                switch result {
                case .success(_):
                    CometChat.setSource(resource: "uikit-v4", platform: "ios", language: "swift")
                    break
                case .failure(let error):
                    print("Initialization Error:  \(error.localizedDescription)")
                    print("Initialization Error Description:  \(error.localizedDescription)")
                    break
                }
            })
        }
    }


}


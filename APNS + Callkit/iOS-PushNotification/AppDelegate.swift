//
//  AppDelegate.swift
//  iOS-PushNotification
//
//  Created by Admin1 on 29/03/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit
import CometChatPro
import UserNotifications
import PushKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var blockedUsersArray = [String]()
    let manager = CallManager()
    let blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 100).build();
    private let callController = CXCallController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.initialization()
        self.voipRegistration()
    
        if CometChat.getLoggedInUser() != nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyBoard.instantiateViewController(withIdentifier: "pushNotification") as! PushNotification
            let navigationController: UINavigationController = UINavigationController(rootViewController: mainVC)
            navigationController.navigationBar.prefersLargeTitles = true
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.shadowColor = .clear
                navBarAppearance.backgroundColor = .systemBackground
                navigationController.navigationBar.standardAppearance = navBarAppearance
                navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
            }
            self.window?.rootViewController = navigationController
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
        
        application.registerForRemoteNotifications()

        // [END register_for_notifications]
        return true
    }
    
    private func initialization(){
        
        let appSettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: Constants.region).build()
        
        CometChat.init(appId: Constants.appID, appSettings: appSettings, onSuccess: { (Success) in
            print("initialization Success: \(Success)")
            
        }) { (error) in
            print( "Initialization Error \(error.errorDescription)")
        }
    }
    
    private func voipRegistration() {
        // Create a push registry object
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) { }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) { }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print( "Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    private func getBlockedUser(){
        
        blockedUserRequest.fetchNext(onSuccess : { (users) in
            print("blocked users : \(String(describing: users))")
            
            for user in users! {
                
                self.blockedUsersArray.append(user.uid!)
            }
            var defaults = UserDefaults.standard
            defaults = UserDefaults(suiteName: "group.com.cometchat.apns")!
            defaults.set(self.blockedUsersArray, forKey: "blockedUsers")
            print("blockedUSersArray: \(self.blockedUsersArray)")
        }, onError : { (error) in
            print("error while fetching the blocked user request :  \(String(describing: error?.errorDescription))")
        })
        
        
    }
   
   
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        self.initialization()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    UserDefaults(suiteName: "group.com.cometchat.apns")?.set(1, forKey: "count")
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

// -------------------------------------------------------------------------------------------------------------//

// MARK: APNS Notification

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNS Token : ",token)
        
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token 11: ",hexString)
        UserDefaults.standard.set(hexString, forKey: "apnsToken")
        CometChat.registerTokenForPushNotification(token: hexString, settings: ["voip":false]) { (success) in
            print("registerTokenForPushNotification success: \(success)")
        } onError: { (error) in
            print("registerTokenForPushNotification error: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent notification: \(notification.request.content.userInfo)")
        
        
        if let userInfo = notification.request.content.userInfo as? [String : Any], let messageObject =
            userInfo["message"], let str = messageObject as? String, let dict = str.stringTodictionary() {

                      if let baseMessage = CometChat.processMessage(dict).0 {
                          switch baseMessage.messageCategory {
                          case .message:
                            if let message = baseMessage as? BaseMessage {
                                switch message.messageType {
                                case .text:
                                    print("text Messagge is: \(String(describing: (message as? TextMessage)?.stringValue()))")
                                case .image:
                                    print("image Messagge is: \(String(describing: (message as? MediaMessage)?.stringValue()))")
                                case .video:
                                    print("video Messagge is: \(String(describing: (message as? MediaMessage)?.stringValue()))")
                                case .audio:
                                    print("audio Messagge is: \(String(describing: (message as? MediaMessage)?.stringValue()))")
                                case .file:
                                    print("file Messagge is: \(String(describing: (message as? MediaMessage)?.stringValue()))")
                                case .custom:
                                    print("custom Messagge is: \(String(describing: (message as? MediaMessage)?.stringValue()))")
                                case .groupMember:
                                    break
                                @unknown default:
                                    break
                                }
                            }
                          case .action: break
                          case .call:
                            if let call = baseMessage as? Call {
                                print("call is: \(call.stringValue())")
                            }
                            
                          case .custom:
                            if let customMessage = baseMessage as? CustomMessage {
                                print("customMessage is: \(customMessage.stringValue())")
                            }
                            
                          @unknown default: break
                          }
                      }
                  
                  }
        completionHandler([.alert, .badge, .sound])
    }
}

// -------------------------------------------------------------------------------------------------------------//

// MARK: CallKit & PushKit

extension AppDelegate: PKPushRegistryDelegate , CXProviderDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("didUpdate : \(pushCredentials)")
        let deviceToken = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
            print("voip token is: \(deviceToken)")
        UserDefaults.standard.set(deviceToken, forKey: "voipToken")
        CometChat.registerTokenForPushNotification(token: deviceToken, settings: ["voip":true]) { (success) in
            print("registerTokenForPushNotification voip: \(success)")
        } onError: { (error) in
            print("registerTokenForPushNotification error: \(error)")
        }

    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        print("didReceiveIncomingPushWith : \(payload.dictionaryPayload)")
        
        if let userInfo = payload.dictionaryPayload as? [String : Any], let messageObject =
            userInfo["message"], let dict = messageObject as? [String : Any] {

                      if let baseMessage = CometChat.processMessage(dict).0 {
                          switch baseMessage.messageCategory {
                          case .message: break
                          case .action: break
                          case .call:
                            if let call = baseMessage as? Call {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceivedIncomingCall"), object: nil, userInfo: ["call":call])
                                }
                                switch call.callType {
                               
                                case .audio where call.receiverType == .user:
                                    if let name = (call.sender)?.name {
                                        let config = CXProviderConfiguration(localizedName: "")
                                        config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
                                        config.includesCallsInRecents = false
                                        config.ringtoneSound = "ringtone.caf"
                                        config.supportsVideo = false
                                        let provider = CXProvider(configuration: config)
                                        provider.setDelegate(self, queue: nil)
                                        let update = CXCallUpdate()
                                        update.remoteHandle = CXHandle(type: .generic, value: name)
                                        update.hasVideo = false
                                        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
                                    }
                                    
                                case .audio where call.receiverType == .group:
                                    if let group = (call.receiver as? Group)?.name {
                                        let config = CXProviderConfiguration(localizedName: "APNS + Callkit")
                                        config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
                                        config.includesCallsInRecents = false
                                        config.ringtoneSound = "ringtone.caf"
                                        config.supportsVideo = false
                                        let provider = CXProvider(configuration: config)
                                        provider.setDelegate(self, queue: nil)
                                        let update = CXCallUpdate()
                                        update.remoteHandle = CXHandle(type: .generic, value: group)
                                        update.hasVideo = false
                                        
                                        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
                                    }
                                    
                                case .video where call.receiverType == .user:
                                    if let name = (call.sender)?.name {
                                        let config = CXProviderConfiguration(localizedName: "APNS + Callkit")
                                        config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
                                        config.includesCallsInRecents = false
                                        config.ringtoneSound = "ringtone.caf"
                                        config.supportsVideo = true
                                        let provider = CXProvider(configuration: config)
                                        provider.setDelegate(self, queue: nil)
                                        let update = CXCallUpdate()
                                        update.remoteHandle = CXHandle(type: .generic, value: name)
                                        update.hasVideo = true
                                        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
                                        
                                        
                                    }
                                case .video where call.receiverType == .group:
                                    if let group = (call.receiver as? Group)?.name {
                                        let config = CXProviderConfiguration(localizedName: "APNS + Callkit")
                                        config.includesCallsInRecents = false
                                        config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
                                        config.ringtoneSound = "ringtone.caf"
                                        config.supportsVideo = true
                                        let provider = CXProvider(configuration: config)
                                        provider.setDelegate(self, queue: nil)
                                        let update = CXCallUpdate()
                                        update.remoteHandle = CXHandle(type: .generic, value: group)
                                        update.hasVideo = true
                                        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
                                    }
                                case .audio: break
                                case .video: break
                                @unknown default: break
                                }
                                
                                print("call is: \(call.stringValue())")
                               
                            }
                          case .custom:
                            if let customMessage = baseMessage as? CustomMessage {
                                print("customMessage is: \(customMessage.stringValue())")
                            }
                            
                          @unknown default: break
                          }
                      }
                  
                  }
    }
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didAcceptButtonPressed"), object: nil, userInfo: nil)

        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRejectButtonPressed"), object: nil, userInfo: nil)
        action.fulfill()
    }
    
}

// -------------------------------------------------------------------------------------------------------------//


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

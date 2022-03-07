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
import AudioToolbox
import AVKit


struct ActiveCall {
   let uuid = UUID()
   var call: Call
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var blockedUsersArray = [String]()
    let blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 100).build();

    
    private let callController = CXCallController()
    let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    var provider: CXProvider? = nil
    var activeCall: ActiveCall? = nil
    var timeout: DispatchTime = .now() + 20.0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        initialization()
        registerForPushNotifications(application: application)
        registerForVoIP()
        
        CometChatCallManager().registerForCalls(application: self)
        
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

        // [END register_for_notifications]
        return true
    }
    
    private func initialization(){
        
        let appSettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: Constants.region).build()
        
        CometChat.init(appId: Constants.appId, appSettings: appSettings, onSuccess: { (Success) in
            print("initialization Success: \(Success)")
            
        }) { (error) in
            print( "Initialization Error \(error.errorDescription)")
        }
    }
    
    private func registerForPushNotifications(application: UIApplication) {
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

    }
    
    private func registerForVoIP() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) { }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) { }
    
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
                    didReceive response: UNNotificationResponse,
                    withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let userInfo = response.notification.request.content.userInfo as? [String : Any], let messageObject = userInfo["message"] as? [String:Any] {
           print("didReceive: \(userInfo)")
          if let baseMessage = CometChat.processMessage(messageObject).0 {
            switch baseMessage.messageCategory {
            case .message:
                print("Message Object Received: \(String(describing: (baseMessage as? TextMessage)?.stringValue()))")
                
                switch baseMessage.receiverType {
                case .user:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let user = baseMessage.sender {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceivedMessageFromUser"), object: nil, userInfo: ["user":user])
                        }
                    }
                case .group:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let group = baseMessage.receiver as? Group {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceivedMessageFromGroup"), object: nil, userInfo: ["group":group])
                        }
                    }
                @unknown default: break
                }
                
            case .action: break
            case .call: break
            case .custom: break
            @unknown default: break
            }
          }
        }
        completionHandler()
      }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if let userInfo = notification.request.content.userInfo as? [String : Any], let messageObject =
            userInfo["message"], let dict = messageObject as? [String : Any] {

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
                              
                                let activeCall = ActiveCall(call: call)
                                self.activeCall = activeCall

                                  if let name = (call.sender)?.name {
                                      let config = CXProviderConfiguration(localizedName: "APNS + Callkit")
                                      config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
                                      config.includesCallsInRecents = false
                                      config.ringtoneSound = "ringtone.caf"
                                      config.supportsVideo = true
                                      provider = CXProvider(configuration: config)
                                      provider?.setDelegate(self, queue: nil)
                                      let update = CXCallUpdate()
                                      update.remoteHandle = CXHandle(type: .generic, value: name.capitalized)
                                      if call.callType == .video {
                                          update.hasVideo = true
                                      }else{
                                          update.hasVideo = false
                                      }
                                      provider?.reportNewIncomingCall(with: activeCall.uuid, update: update, completion: { error in
                                          if error == nil {
                                              self.configureAudioSession()
                                          }
                                     })
                                  }
                               
                                print("call is: \(call.stringValue())")
                                print("call Status: \(call.callStatus.hashValue)")
                            }
                          case .custom:
                            if let customMessage = baseMessage as? CustomMessage {
                                print("customMessage is: \(customMessage.stringValue())")
                            }
                            
                          @unknown default: break
                          }
                      }
                  }
        
        DispatchQueue.main.asyncAfter(deadline: timeout) {
            if let activeCall = self.activeCall {
                self.end(call: activeCall)
            }
        }
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)

        } catch let error as NSError {
            print(error)
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {
        if let uuid = activeCall?.uuid {
            provider.reportCall(with: uuid, endedAt: Date(), reason: .unanswered)
        }
       

    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        if let activeCall = activeCall {
            CometChatCallManager().startCall(call: activeCall.call)
            provider.reportCall(with: activeCall.uuid, endedAt: Date(), reason: .remoteEnded)
        }
        action.fulfill()
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRejectButtonPressed"), object: nil, userInfo: nil)
        if let activeCall = activeCall {
            CometChatCallManager().reject(call: activeCall.call)
            provider.reportCall(with: activeCall.uuid, endedAt: Date(), reason: .remoteEnded)
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print(#function)
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        action.fulfill()
        print(#function)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print(#function)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print(#function)
    }

    
    func end(call: ActiveCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)
        requestTransaction(transaction, action: "")
    }

    func setHeld(call: ActiveCall, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)

        requestTransaction(transaction, action: "")
    }

    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction \(action) successfully")
            }
        }
    }
    
    
}


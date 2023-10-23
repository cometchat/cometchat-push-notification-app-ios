//
//  CometChatPNHelper.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift
import PushKit
import CallKit
import AVFAudio
import CometChatCallsSDK

class CometChatAPNsHelper {
    
    var uuid: UUID?
    var activeCall: Call?
    var cancelCall: Bool = true
    var onCall = true
    var callController = CXCallController()
    let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    var provider: CXProvider? = nil
    
    //Start For APNs Push notification
    public func configurePushNotification(application: UIApplication, delegate: PKPushRegistryDelegate) {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        application.registerForRemoteNotifications()
        
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = delegate
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        CometChat.addLoginListener("loginlistener-pnToken-register-login", self)
        CometChatCallEvents.addListener("loginlistener-pnToken-register-login", self)
        
    }
    
    
    public func registerTokenForPushNotification(deviceToken: Data) {
        
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(hexString, forKey: "apnspuToken")
        
        CometChat.registerTokenForPushNotification(token: hexString, settings: ["voip":false]) { (success) in
            print("registerTokenForPushNotification: \(success)")
        } onError: { (error) in
            print("registerTokenForPushNotification error: \(String(describing: error))")
        }
        
    }
    //end for APNs Push notification
    
    
    //start for VoIP
    
    public func registerForVoIPCalls(pushCredentials: PKPushCredentials) {
        
        let deviceToken = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        UserDefaults.standard.set(deviceToken, forKey: "voipToken")
        
        CometChat.registerTokenForPushNotification(token: deviceToken, settings: ["voip":true]) { (success) in
            print("registerTokenForPushNotification voip: \(success)")
        } onError: { (error) in
            print("registerTokenForPushNotification error: \(String(describing: error?.errorDescription))")
        }
    }
    
    public func onProviderDidReset(provider: CXProvider) {
        if let uuid = self.uuid {
            onCall = true
            provider.reportCall(with: uuid, endedAt: Date(), reason: .unanswered)
        }
    }
    
    public func didReceiveIncomingPushWith(payload: PKPushPayload) -> CXProvider? {
        
        if let payloadData = payload.dictionaryPayload as? [String : Any], let messageObject =
            payloadData["message"], let dict = messageObject as? [String : Any] {
            
            if let baseMessage = CometChat.processMessage(dict).0 {
                if baseMessage.messageCategory == .call {
                    let callObject = baseMessage as! Call
                    switch callObject.callStatus {
                    case .initiated:
                        let newCallProvider = initiateCall(callObject: callObject)
                        return newCallProvider
                    case .ongoing: //this will never be called from the VoIP payload
                        print("----------ongoing voip received----------")
                        break
                    case .unanswered:
                        provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .unanswered)
                    case .rejected:
                        provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .unanswered)
                    case .busy:
                        provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .unanswered)
                    case .cancelled:
                        provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .failed)
                    case .ended:
                        provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .remoteEnded)
                    @unknown default:
                        provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .remoteEnded)
                    }
                }
            }
        }
        return nil
    }
    
    public func onAnswerCallAction(action: CXAnswerCallAction) {
        if activeCall != nil {
            startCall()
        }
        
        action.fulfill()
    }
    
    public func onEndCallAction(action: CXEndCallAction) {
        
        
        let endCallAction = CXEndCallAction(call: uuid!)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
        
        if let activeCall = activeCall {
            if CometChat.getActiveCall() == nil || (CometChat.getActiveCall()?.callStatus == .initiated && CometChat.getActiveCall()?.callInitiator != CometChat.getLoggedInUser())  {
                CometChat.rejectCall(sessionID: activeCall.sessionID ?? "", status: .rejected, onSuccess: {(rejectedCall) in
                    action.fulfill()
                    print("CallKit: Reject call success")
                }) { (error) in
                    print("CallKit: Reject call failed with error: \(String(describing: error?.errorDescription))")
                }
            } else {
                CometChat.endCall(sessionID: CometChat.getActiveCall()?.sessionID ?? "") { call in
                    CometChatCalls.endSession()
                    action.fulfill()
                    print("CallKit: End call success")
                } onError: { error in
                    print("CallKit: End call failed with error: \(String(describing: error?.errorDescription))")
                }

            }
        }
    }
    
    //end for VoIP
    
    public func presentMessageFromPayload(response:  UNNotificationResponse) {
        let notification = response.notification.request.content.userInfo as? [String: Any]
        
        if let userInfo = notification, let messageObject =
            userInfo["message"], let dict = messageObject as? [String: Any] {
            
            let message = CometChat.processMessage(dict).0
            let cometChatMessages = CometChatMessages()
            
            if message?.receiverType == .user {
                guard let uid = message?.senderUid, let userName = message?.sender?.name else { return }
                let user = User(uid: uid, name: userName)
                cometChatMessages.set(user: user)
            }else {
                guard let group = (message?.receiver as? Group)else { return }
                cometChatMessages.set(group: group)
            }
            
            cometChatMessages.modalPresentationStyle = .fullScreen
            
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            
            if let window = sceneDelegate?.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                currentController.present(cometChatMessages, animated: true)
            }
        }
    }
}

//MARK: CALL KIT HELPER FUNCTIONS
extension CometChatAPNsHelper {
    
    private func initiateCall(callObject: Call) -> CXProvider {
        
        activeCall = callObject
        uuid = UUID()
        
        let callerName = callObject.sender!.name
        
        let config = CXProviderConfiguration(localizedName: "APNS + Callkit")
        config.iconTemplateImageData = UIImage(named: "AppIcon")?.pngData()
        config.includesCallsInRecents = true
        config.ringtoneSound = "ringtone.caf"
        config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
        config.supportsVideo = true
        
        provider = CXProvider(configuration: config)
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: callerName!.capitalized)
        if callObject.callType == .video {
            update.hasVideo = true
        }else{
            update.hasVideo = false
        }
        
        provider?.reportNewIncomingCall(with: self.uuid!, update: update, completion: { error in
            if error == nil {
                self.configureAudioSession()
            }
        })
        
        return provider!
        
    }
    
    private func configureAudioSession() {
         do {
             try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
             try AVAudioSession.sharedInstance().setActive(true)
         } catch let error as NSError {
             print(error)
         }
     }
    
    private func startCall() {
        
        let cometChatOngoingCall = CometChatOngoingCall()
        
        CometChat.acceptCall(sessionID: activeCall?.sessionID ?? "") { call in
            
            DispatchQueue.main.async {
                
                var isAudioCall = false
                if self.activeCall?.callType == .audio {
                    isAudioCall = true
                }
                
                let callSettingsBuilder = CallingDefaultBuilder.callSettingsBuilder
                callSettingsBuilder.setIsAudioOnly(isAudioCall)
                cometChatOngoingCall.set(callSettingsBuilder: callSettingsBuilder)
                cometChatOngoingCall.set(callWorkFlow: .defaultCalling)
                cometChatOngoingCall.set(sessionId: call?.sessionID ?? "")
                cometChatOngoingCall.modalPresentationStyle = .fullScreen
                
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                
                if let window = sceneDelegate?.window, let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.present(cometChatOngoingCall, animated: true)
                }
                
            }
            
            cometChatOngoingCall.setOnCallEnded { [weak self] call in
                self?.provider?.reportCall(with: self?.uuid ?? UUID(), endedAt: Date(), reason: .remoteEnded)
            }
            
        } onError: { error in
            print("Error while accreting the call: \(String(describing: error?.errorDescription))")
        }


    }
    
}

//MARK: Login Token handling
extension CometChatAPNsHelper: CometChatLoginDelegate {
    
    func onLoginSuccess(user: CometChatSDK.User) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func onLoginFailed(error: CometChatSDK.CometChatException?) {  return }
    
    func onLogoutSuccess() { return }
    
    func onLogoutFailed(error: CometChatSDK.CometChatException?) { return }
    
    
}

extension CometChatAPNsHelper: CometChatCallEventListener {
    func onIncomingCallAccepted(call: CometChatSDK.Call) {
        print(#function)
    }
    
    func onIncomingCallRejected(call: CometChatSDK.Call) {
        print(#function)
    }
    
    func onCallEnded(call: CometChatSDK.Call) {
        guard let uuid = uuid else { return }
        
        if activeCall != nil {
            let transaction = CXTransaction(action: CXEndCallAction(call: uuid))
            callController.request(transaction, completion: { error in })
            activeCall = nil
        }
    }
    
    func onCallInitiated(call: CometChatSDK.Call) {
        let callerName = (call.callReceiver as? User)?.name
        callController = CXCallController()
        uuid = UUID()
        
        let transactionCallStart = CXTransaction(action: CXStartCallAction(call: uuid!, handle: CXHandle(type: .generic, value: callerName ?? "")))
        callController.request(transactionCallStart, completion: { error in })
    }
    
    func onOutgoingCallAccepted(call: CometChatSDK.Call) {
        print("onOutgoingCallAccepted(acceptedCall: onOutgoingCallAccepted(acceptedCall")
        
        
        let transactionCallAccepted = CXTransaction(action: CXAnswerCallAction(call: uuid!))
        callController.request(transactionCallAccepted, completion: { error in })
    }
    
    func onOutgoingCallRejected(call: CometChatSDK.Call) {
        guard let uuid = uuid else { return }
        
        if activeCall != nil {
            let transactionCallAccepted = CXTransaction(action: CXEndCallAction(call: uuid))
            callController.request(transactionCallAccepted, completion: { error in })
            activeCall = nil
        }
    }
    
}


//
//  APNsCallViewController.swift
//  PushNotificationSample-APNS
//
//  Created by SuryanshBisen on 16/10/23.
//  Copyright © 2023 Admin1. All rights reserved.
//

import UIKit
import CometChatPro
import CometChatProCalls

class APNsCallViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public func acceptCall(withCall: CometChatPro.Call?) {
        if let call = withCall  {
            CometChatSoundManager().play(sound: .incomingCall, bool: false)
            CometChat.acceptCall(sessionID: call.sessionID ?? "", onSuccess: { (acceptedCall) in
                if acceptedCall != nil {
                    
                    DispatchQueue.main.async {
                            
                        let callSetting = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: call.sessionID ?? "").build()
                        
                        
                        CometChat.startCall(callSettings: callSetting) { onUserJoined in
                            DispatchQueue.main.async {
                                if let name = onUserJoined?.name {
                                    CometChatSnackBoard.display(message:  "\(name) " + "JOINED".localized(), mode: .info, duration: .short)
                                }
                            }
                        } onUserLeft: { onUserLeft in
                            DispatchQueue.main.async {
                                if let name = onUserLeft?.name {
                                    CometChatSnackBoard.display(message:  "\(name) " + "LEFT_THE_CALL".localized(), mode: .info, duration: .short)
                                }
                            }
                        } onUserListUpdated: { onUserListUpdated in
                            
                        } onAudioModesUpdated: { onAudioModesUpdated in
                            
                        } onUserMuted: { onUserMuted in
                            
                        } onCallSwitchedToVideo: { onCallSwitchedToVideo in
                            
                        } onRecordingStarted: { onRecordingStarted in
                            
                        } onRecordingStopped: { onRecordingStopped in
                            
                        } onError: { onError in

                            DispatchQueue.main.async {
                                if (onError?.errorDescription) != nil {
                                    CometChatSnackBoard.display(message:  "CALL_ENDED".localized(), mode: .info, duration: .short)
                                }
                            }
                        } onCallEnded: { onCallEnded in
                            
                            //MARK: CallKit Changes
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onCallEnded"), object: nil, userInfo: nil)
                            
                            DispatchQueue.main.async {
                                self.dismiss(animated: true)
                                CometChatSnackBoard.display(message:  "CALL_ENDED".localized(), mode: .info, duration: .short)
                                
                            }
                        }
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    

}

//
//  CometChatCall.swift
//  CometChatCallManager
//
//  Created by Pushpsen Airekar on 01/03/22.
//

import UIKit
import CometChatPro
class CometChatCall: UIViewController {

    weak var call: Call?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let call = call {
            
            if (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid {
                
                CometChat.acceptCall(sessionID: call.sessionID ?? "") { acceptedCall in
                    
                    DispatchQueue.main.async {
                        let callSettings = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: acceptedCall?.sessionID ?? "").setMode(mode: .MODE_SINGLE).build()
                      
                
                        CometChat.startCall(callSettings: callSettings) { userJoined in
                            
                        } onUserLeft: { onUserLeft in
                            
                        } onUserListUpdated: { onUserListUpdated in
                            
                        } onAudioModesUpdated: { onAudioModesUpdated in
                            
                        } onUserMuted: { onUserMuted in
                            
                        } onCallSwitchedToVideo: { onCallSwitchedToVideo in
                            
                        } onRecordingStarted: { onRecordingStarted in
                            
                        } onRecordingStopped: { onRecordingStopped in
                            
                        } onError: { onError in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } onCallEnded: { onCallEnded in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                } onError: { error in
                
                }
            }else{
                
                let callSettings = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: call.sessionID ?? "").setMode(mode: .MODE_SINGLE).build()
                CometChat.startCall(callSettings: callSettings) { userJoined in
                    
                } onUserLeft: { onUserLeft in
                    
                } onUserListUpdated: { onUserListUpdated in
                    
                } onAudioModesUpdated: { onAudioModesUpdated in
                    
                } onUserMuted: { onUserMuted in
                    
                } onCallSwitchedToVideo: { onCallSwitchedToVideo in
                    
                } onRecordingStarted: { onRecordingStarted in
                    
                } onRecordingStopped: { onRecordingStopped in
                    
                } onError: { onError in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } onCallEnded: { onCallEnded in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }

            }
        }

    }


}

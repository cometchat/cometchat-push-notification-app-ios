//
//  NotificationService.swift
//  PNServiceExtension
//
//  Created by MacMini-03 on 30/05/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UserNotifications
import CometChatPro
import PNExtension
import UIKit

//UNNotificationServiceExtension:  This sevice grabs the data from the push notification payload and we can modify it and display the customized data on to the push notification.

// Here, we are modifying the data or hiding the push notification for users which are blocked from the loggedInUser.

//Steps:

// 1. When the user login, fetch the blockedUsersList using  'blockedUserRequest'. Refer the 'getBlockedUser()' from AppDelegate.
// 2. Store the 'blockedUsersList' in UserDefaults with key 'blockedUsers'.
// 3. Grab the value of push notification 'sender' from push notification payload data.
// 4. Check the same user is contains in the 'blockedUsersList'.
// 5. If the user contains in the 'blockedUsersList' then modify the playload if you want to show custom message for eg.'New Message from Blocked User' and provide the 'bestAttemptContent' UNNotificationRequest to contentHandler.
// 5. If you want hide the push notification from blocked user then simply don't provide the bestAttemptContent' UNNotificationRequest to contentHandler.This will not trigger the modified push notification but system automatically sends defult notification after 30 seconds if custom  notification dosent trigger.
// 6. to avoid the system generated push notification use 'removePendingNotificationRequests(withIdentifiers:)' and provide the push notifcation identifier to it. It will remove pendingNotificationRequests with same identifier. Kindly, refer ' willPresent notification:' from app delegate.


class NotificationService: UNNotificationServiceExtension{
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var badge = 0
    let blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 20).build();

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        if let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent), let userInfo = bestAttemptContent.userInfo as? [String : Any] {
            
            let defaults = UserDefaults(suiteName: "group.com.inscripts.comatchat.dev2")
            let usersArray = defaults?.value(forKey: "blockedUsers")
            let blockedUsers:[String] = (usersArray as? [String])!
            print("blocked Users : \(blockedUsers)")
            
            let messageObject = userInfo["message"]
            if let someString = messageObject as? String {
                
                if let dict = someString.stringTodictionary(){
                    let sender = dict["sender"]
                    if(blockedUsers.contains(sender as! String)){
                        bestAttemptContent.title = ""
                        bestAttemptContent.body = "New Message from Blocked User"
//                        If you don't want to hide the notification and want to show cutom message for blocked user then uncomment below line.
                        contentHandler(bestAttemptContent)
                    }
                }else{
                    if let aps = userInfo["aps"] as? NSDictionary {
                        if let alert = aps["alert"] as? NSDictionary {
                            if let title = alert["title"] as? NSString {
                                print("title is: \(title)")
                                bestAttemptContent.title = title as String
                            }
                            if let body = alert["body"] as? NSString {
                                bestAttemptContent.body = body as String
                            }
                        }
                    }
                    contentHandler(bestAttemptContent)
                }
            }
              contentHandler(bestAttemptContent)
        }
    }
    
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

extension String {
    
    
    func stringTodictionary() -> [String:Any]? {
        
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

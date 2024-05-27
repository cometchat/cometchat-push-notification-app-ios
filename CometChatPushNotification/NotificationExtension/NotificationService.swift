//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by SuryanshBisen on 11/09/23.
//

import UserNotifications
import CometChatSDK

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            CometChat.setExtensionGroupID(id: "group.notification.for.markAsDelivered")
            CometChat.markAsDelivered(withNotificationPayload: bestAttemptContent.userInfo)
            
            //here we are setting the sender avatar
            if let avatarURLString = bestAttemptContent.userInfo["senderAvatar"] as? String,
               let avatarURL = URL(string: avatarURLString),
               let imageData = try? Data(contentsOf: avatarURL) {
                
                do {
                    let fileManager = FileManager.default
                    let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
                    let fileURL = temporaryDirectory.appendingPathComponent("avatar.png")
                    try imageData.write(to: fileURL)
                    let attachment = try UNNotificationAttachment(identifier: "avatar", url: fileURL, options: nil)
                    bestAttemptContent.attachments = [attachment]
                } catch {
                    print("Error creating notification attachment: \(error.localizedDescription)")
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

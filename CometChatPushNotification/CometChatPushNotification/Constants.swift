//  AppConstants.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

import Foundation
import UIKit

class Constants {
    static var appId =  "Enter your AppId here"
    static var authKey = "Enter your Authkey here"
    static var region = "Enter your Region here"
    static let notificationMode = NotificationMode.APNs //set this as FCM if using FCM PN
}

enum NotificationMode {
    case FCM
    case APNs
}

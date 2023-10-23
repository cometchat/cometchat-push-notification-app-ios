//  AppConstants.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

import Foundation
import UIKit

class Constants {
    static var appId =  "236481bb592f83ce"
    static var authKey = "c559dd7780bf19e7f9d6a2e5d5e656e345835e5f"
    static var region = "us"
    static let notificationMode = NotificationMode.FCM //set this as FCM if using FCM PN
}

enum NotificationMode {
    case FCM
    case APNs
}

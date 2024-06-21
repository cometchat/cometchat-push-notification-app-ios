//
//  SampleUser.swift
//  PushNotificationSample-APNS
//
//  Created by nabhodipta on 20/06/24.
//  Copyright © 2024 Admin1. All rights reserved.
//

import Foundation

struct SampleUser: Decodable {
  let uid: String
  let name: String
  let avatar: String

  enum CodingKeys: String, CodingKey {
    case uid = "uid"
    case name = "name"
      case avatar = "avatar"
  }
}

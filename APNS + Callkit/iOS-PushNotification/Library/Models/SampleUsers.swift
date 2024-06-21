//
//  SampleUsers.swift
//  PushNotificationSample-APNS
//
//  Created by nabhodipta on 20/06/24.
//  Copyright © 2024 Admin1. All rights reserved.
//

import Foundation

struct SampleUsers: Decodable {
  let users: [SampleUser]

  enum CodingKeys: String, CodingKey {
    case users = "users"
  }
}

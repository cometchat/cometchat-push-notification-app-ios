//
//  SampleUsers.swift
//  CometChatPushNotification
//
//  Created by nabhodipta on 20/06/24.
//

import Foundation

struct SampleUsers: Decodable {
  let users: [SampleUser]

  enum CodingKeys: String, CodingKey {
    case users = "users"
  }
}

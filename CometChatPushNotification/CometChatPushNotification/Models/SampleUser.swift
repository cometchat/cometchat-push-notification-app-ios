//
//  SampleUser.swift
//  CometChatPushNotification
//
//  Created by nabhodipta on 20/06/24.
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

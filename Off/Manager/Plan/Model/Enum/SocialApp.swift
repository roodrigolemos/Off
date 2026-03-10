//
//  SocialApp.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum SocialApp: String, Codable, CaseIterable, Hashable {
    case instagram
    case tiktok
    case youtube
    case x
    case facebook
    case reddit
    case snapchat

    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .x: return "X"
        case .facebook: return "Facebook"
        case .reddit: return "Reddit"
        case .snapchat: return "Snapchat"
        }
    }

    var icon: String {
        switch self {
        case .instagram: return "camera"
        case .tiktok: return "music.note"
        case .youtube: return "play.rectangle.fill"
        case .x: return "text.bubble"
        case .facebook: return "person.2.fill"
        case .reddit: return "bubble.left.and.bubble.right.fill"
        case .snapchat: return "bolt.horizontal.circle.fill"
        }
    }
}

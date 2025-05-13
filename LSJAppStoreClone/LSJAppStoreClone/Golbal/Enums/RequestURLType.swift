//
//  RequestURLType.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

enum RequestURLType: Codable {

    case Music
    case Movie
    case Podcast

    var url: String {
        switch self {
        case .Music: return "https://itunes.apple.com/search?country=kr&media=music&entity=song&term="
        case .Movie: return "https://itunes.apple.com/search?country=kr&media=movie&entity=movie&term="
        case .Podcast: return "https://itunes.apple.com/search?country=kr&media=podcast&entity=podcast&term="
        }
    }

}

//
//  ApiUrlType.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

enum ApiUrlType: Codable {

    case Music
    case Movie
    case Podcast

    var url: String {
        switch self {
        case .Music: return "https://itunes.apple.com/search?country=kr&media=music&entity=song&term="
        default: return ""
        }
    }

}

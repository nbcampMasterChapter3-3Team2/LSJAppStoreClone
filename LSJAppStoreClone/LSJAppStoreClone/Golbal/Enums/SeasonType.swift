//
//  SeasonType.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

enum Season: Int, CaseIterable {
    case spring
    case summer
    case fall
    case winter

    var query: String {
        switch self {
        case .spring: return "봄"
        case .summer: return "여름"
        case .fall: return "가을"
        case .winter: return "겨울"
        }
    }
}

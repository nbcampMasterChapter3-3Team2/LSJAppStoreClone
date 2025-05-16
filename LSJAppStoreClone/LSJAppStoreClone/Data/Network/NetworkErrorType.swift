//
//  NetworkErrorType.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

enum NetworkErrorType: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
}

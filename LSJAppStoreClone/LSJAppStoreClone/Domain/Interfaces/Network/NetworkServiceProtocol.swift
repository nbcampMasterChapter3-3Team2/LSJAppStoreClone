//
//  NetworkServiceProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(url: URL) -> Single<T>
}

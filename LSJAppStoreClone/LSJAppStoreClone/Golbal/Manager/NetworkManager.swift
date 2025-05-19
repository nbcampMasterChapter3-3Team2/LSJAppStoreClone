//
//  NetworkManager.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

import Alamofire
import RxSwift


final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetch<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601


            let request = AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: T.self, queue: .global(), decoder: decoder) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let afError):
                        if let error = afError.asAFError, error.isResponseSerializationError {
                            observer(.failure(NetworkErrorType.decodingFail))
                            NSLog("디코딩 실패: \(afError)")
                        } else {
                            observer(.failure(NetworkErrorType.dataFetchFail))
                            NSLog("패치 실패: \(afError)")
                        }
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

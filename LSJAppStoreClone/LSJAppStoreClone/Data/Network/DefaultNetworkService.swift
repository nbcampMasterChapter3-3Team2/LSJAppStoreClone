//
//  DefaultNetworkService.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation

import Alamofire
import RxSwift

final class DefaultNetworkService: NetworkServiceProtocol {
    private let decoder: JSONDecoder

    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) {
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = dateDecodingStrategy
    }

    func fetch<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in
            let request = AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: T.self,
                                   queue: .global(),
                                   decoder: self.decoder) { response in
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

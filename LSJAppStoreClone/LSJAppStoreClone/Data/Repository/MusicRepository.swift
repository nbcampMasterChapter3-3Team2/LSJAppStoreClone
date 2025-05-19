//
//  MusicRepository.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

final class MusicRepository: MusicRepositoryProtocol {
    private let service: NetworkServiceProtocol

    public init(service: NetworkServiceProtocol) {
        self.service = service
    }

    public func fetchMusic(season: Season) -> Single<Music> {
        guard let url = URL(string: "\(APIEndpoints.Music.url)\(season.query)") else {
            return .error(NetworkErrorType.dataFetchFail)
        }
        return service.fetch(url: url)
    }
}


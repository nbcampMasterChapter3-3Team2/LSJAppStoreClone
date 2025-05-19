//
//  SuggestionRepository.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation

import RxSwift

final class SuggestionRepository: SuggestionRepositoryProtocol {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol) {
        self.service = service
    }

    func fetchMovies(query: String) -> Single<Movie> {
        guard let url = URL(string: "\(APIEndpoints.Movie.url)\(query)") else {
            return .error(NetworkErrorType.dataFetchFail)
        }
        return service.fetch(url: url)
    }

    func fetchPodcasts(query: String) -> Single<Podcast> {
        guard let url = URL(string: "\(APIEndpoints.Podcast.url)\(query)") else {
            return .error(NetworkErrorType.dataFetchFail)
        }
        return service.fetch(url: url)
    }
}

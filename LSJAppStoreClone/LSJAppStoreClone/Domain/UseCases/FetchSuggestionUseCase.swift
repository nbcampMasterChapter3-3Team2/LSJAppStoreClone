//
//  FetchSuggestionUseCase.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

final class FetchSuggestionUseCase: FetchSuggestionUseCaseProtocol {
    private let repository: SuggestionRepositoryProtocol

    init(repository: SuggestionRepositoryProtocol) {
        self.repository = repository
    }

    func executeMovies(query: String) -> Single<Movie> {
        return repository.fetchMovies(query: query)
            .map { movie in
            let sorted = movie.results.sorted { $0.releaseDate > $1.releaseDate }
            return Movie(resultCount: movie.resultCount, results: sorted)
        }
    }

    func executePodcasts(query: String) -> Single<Podcast> {
        return repository.fetchPodcasts(query: query)
            .map { podcast in
            let sorted = podcast.results.sorted { $0.releaseDate > $1.releaseDate }
            return Podcast(resultCount: podcast.resultCount, results: sorted)
        }
    }
}

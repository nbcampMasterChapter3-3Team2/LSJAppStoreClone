//
//  FetchMusicUseCase.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import RxSwift

final class FetchMusicUseCase: FetchMusicUseCaseProtocol {
    private let repository: MusicRepositoryProtocol

    public init(repository: MusicRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(season: Season) -> Single<Music> {
        return repository.fetchMusic(season: season)
            .map { music in
                let sorted = music.results
                    .sorted { $0.releaseDate > $1.releaseDate }
                let limited = (season == .spring ? Array(sorted.prefix(5)) : sorted)
                return Music(resultCount: music.resultCount, results: limited)
            }
    }
}

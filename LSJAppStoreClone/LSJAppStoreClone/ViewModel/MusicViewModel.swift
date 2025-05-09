//
//  MusicViewModel.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

import RxSwift

final class MusicViewModel {

    // MARK: - Properties
    private let disposBag = DisposeBag()

    let springMusicSubject = BehaviorSubject(value: Music())
    let summerMusicSubject = BehaviorSubject(value: Music())
    let fallMusicSubject = BehaviorSubject(value: Music())
    let winterMusicSubject = BehaviorSubject(value: Music())

    // MARK: - Initializer
    init() {
        Season.allCases.forEach { season in
            fetchMusic(to: season)
        }
    }

    // MARK: - Methods
    private func subject(for season: Season) -> BehaviorSubject<Music> {
        switch season {
        case .spring: return springMusicSubject
        case .summer: return summerMusicSubject
        case .fall: return fallMusicSubject
        case .winter: return winterMusicSubject
        }
    }

    private func fetchMusic(to season: Season) {

        guard let url = URL(string: "\(ApiUrlType.Music.url)\(season.query)") else { return }

        NetworkManager.shared.fetch(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
            onSuccess: { [weak self] (music: Music) in
                let sorted = music.results.sorted { $0.releaseDate > $1.releaseDate }
                self?.subject(for: season).onNext(
                    Music(
                        resultCount: music.resultCount,
                        results: season == .spring ? Array(sorted.prefix(5)) : sorted
                    )
                )
                NSLog("MusicVM FetchMusic Succes")
            },

            onFailure: { [weak self] error in
                self?.subject(for: season).onError(error)
                NSLog("MusicVM FetchMusic Error : \(error)")
            }
        )
            .disposed(by: disposBag)
    }

}

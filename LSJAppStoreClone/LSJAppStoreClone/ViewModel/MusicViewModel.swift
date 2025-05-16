//
//  MusicViewModel.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation

import RxSwift
import RxRelay

final class MusicViewModel: BaseViewModel {

    // MARK: - Action & State
    enum Action {
        case fetch(season: Season)
    }

    struct State {
        let musicStreams: [Season: Observable<Music>]
    }

    // MARK: - Properties
    var action: AnyObserver<Action> { actionSubject.asObserver() }
    let state: State

    private let actionSubject = PublishSubject<Action>()
    private let relays: [Season: BehaviorRelay<Music>]
    let disposeBag = DisposeBag()

    // MARK: - Initializer
    init() {
        relays = Dictionary(
            uniqueKeysWithValues: Season.allCases.map { season in
                (season, BehaviorRelay(value: Music()))
            }
        )

        state = State(
            musicStreams: relays.mapValues { $0.asObservable() }
        )

        actionSubject
            .compactMap { action -> Season? in
            guard case .fetch(let season) = action else { return nil }
            return season
        }
            .subscribe(onNext: fetchMusic)
            .disposed(by: disposeBag)

        Season.allCases.forEach(fetchMusic)
    }

    // MARK: - Methods
    private func fetchMusic(to season: Season) {
        guard let url = URL(string: "\(RequestURLType.Music.url)\(season.query)") else { return }

        NetworkManager.shared.fetch(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
            onSuccess: { [weak self] (music: Music) in
                let sorted = music.results.sorted { $0.releaseDate > $1.releaseDate }
                let limited = (season == .spring ? Array(sorted.prefix(5)) : sorted)
                let updated = Music(resultCount: music.resultCount, results: limited)
                self?.relay(for: season).accept(updated)
            },
            onFailure: { error in
                NSLog("MusicVM FetchMusic Error: \(error)")
            }
        )
            .disposed(by: disposeBag)
    }

    func relay(for season: Season) -> BehaviorRelay<Music> {
        return relays[season]!
    }
}

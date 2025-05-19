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
    let disposeBag = DisposeBag()

    private let actionSubject = PublishSubject<Action>()
    private let relays: [Season: BehaviorRelay<Music>]
    private let fetchUseCase: FetchMusicUseCaseProtocol

    // MARK: - Initializer
    init(fetchUseCase: FetchMusicUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
        self.relays = Dictionary(
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
            .subscribe(onNext: fetch)
            .disposed(by: disposeBag)

        Season.allCases.forEach(fetch)
    }

    // MARK: - Methods
    private func fetch(_ season: Season) {
        fetchUseCase.execute(season: season)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] music in
                    self?.relays[season]?.accept(music)
                },
                onFailure: { error in
                    NSLog("MusicVM FetchMusic Error: \(error)")
                }
            ).disposed(by: disposeBag)
    }

    func relay(for season: Season) -> BehaviorRelay<Music> {
        return relays[season] ?? BehaviorRelay(value: Music())
    }

}

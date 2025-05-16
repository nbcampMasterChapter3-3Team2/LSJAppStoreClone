//
//  SuggestionViewModel.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/11/25.
//

import Foundation
import RxSwift
import RxRelay

final class SuggestionViewModel: BaseViewModel {
    // MARK: - Action & State
    enum Action {
        case fetch(query: String)
        case selectSuggestion(Suggestion)
        case enterSuggestion(type: SelectedType, index: Int)
        case cancelSearch
    }

    struct State {
        let movieStream: Observable<Movie>
        let podcastStream: Observable<Podcast>
        let isShowingResults: Observable<Bool>
        let selectedType: Observable<SelectedType>
        let selectedIndex: Observable<Int>
        let selectedSuggestion: Observable<Suggestion>
    }

    // MARK: - Properties
    private let actionSubject = PublishSubject<Action>()
    var action: AnyObserver<Action> { actionSubject.asObserver() }

    let state: State
    let disposeBag = DisposeBag()

    // 내부 Relay 모음
    private let movieRelay = BehaviorRelay<Movie>(value: Movie())
    private let podcastRelay = BehaviorRelay<Podcast>(value: Podcast())
    private let showingRelay = BehaviorRelay<Bool>(value: false)
    private let typeRelay = BehaviorRelay<SelectedType>(value: .Search)
    private let indexRelay = BehaviorRelay<Int>(value: 0)
    private let suggestionRelay = PublishRelay<Suggestion>()
    var keywordRelay = ""

    // MARK: - Initializer
    init() {
        state = State(
            movieStream: movieRelay.asObservable(),
            podcastStream: podcastRelay.asObservable(),
            isShowingResults: showingRelay.asObservable(),
            selectedType: typeRelay.asObservable(),
            selectedIndex: indexRelay.asObservable(),
            selectedSuggestion: suggestionRelay.asObservable()
        )

        // Action 처리
        actionSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .fetch(let q):
                self.keywordRelay = q
                self.fetchMovie(q)
                self.fetchPodcast(q)

            case .selectSuggestion(let suggestion):
                self.showingRelay.accept(true)
                self.suggestionRelay.accept(suggestion)
                switch suggestion {
                case .movie(_, let idx):
                    self.typeRelay.accept(.Movie)
                    self.indexRelay.accept(idx)
                case .podcast(_, let idx):
                    self.typeRelay.accept(.Podcast)
                    self.indexRelay.accept(idx)
                }

            case .enterSuggestion(type: let type, index: let index):
                self.showingRelay.accept(true)
                self.typeRelay.accept(type)
                self.indexRelay.accept(index)

            case .cancelSearch:
                self.showingRelay.accept(false)

            }
        })
            .disposed(by: disposeBag)
    }

    // MARK: - 네트워크
    private func fetchMovie(_ q: String) {
        guard let url = URL(string: "\(RequestURLType.Movie.url)\(q)") else { return }
        NetworkManager.shared.fetch(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
            onSuccess: { [weak self] (m: Movie) in
                let sorted = m.results.sorted { $0.releaseDate > $1.releaseDate }
                self?.movieRelay.accept(Movie(resultCount: m.resultCount, results: sorted))
            },
            onFailure: { error in
                NSLog("Movie fetch error: \(error)")
            }
        )
            .disposed(by: disposeBag)
    }

    private func fetchPodcast(_ q: String) {
        guard let url = URL(string: "\(RequestURLType.Podcast.url)\(q)") else { return }
        NetworkManager.shared.fetch(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
            onSuccess: { [weak self] (p: Podcast) in
                let sorted = p.results.sorted { $0.releaseDate > $1.releaseDate }
                self?.podcastRelay.accept(Podcast(resultCount: p.resultCount, results: sorted))
            },
            onFailure: { error in
                NSLog("Podcast fetch error: \(error)")
            }
        )
            .disposed(by: disposeBag)
    }
}

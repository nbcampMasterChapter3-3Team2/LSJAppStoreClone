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
        case enterSuggestion
        case cancelSearch
    }

    struct State {
        let movieStream: Observable<Movie>
        let podcastStream: Observable<Podcast>
        let isShowingResults: Observable<Bool>
        let selectedSuggestion: Observable<Suggestion>
    }

    // MARK: - Properties
    var action: AnyObserver<Action> { actionSubject.asObserver() }
    let state: State
    let disposeBag = DisposeBag()

    private let actionSubject = PublishSubject<Action>()
    private let fetchUseCase: FetchSuggestionUseCaseProtocol

    var movies: Movie {
        movieSlicedRelay.value
    }
    var podcasts: Podcast {
        podcastSlicedRelay.value
    }
    var selectedTypeValue: SelectedType {
        typeRelay.value
    }
    var keywordRelay = ""

    // 내부 Relay 모음
    private let movieRelay = BehaviorRelay<Movie>(value: Movie())
    private let movieSlicedRelay = BehaviorRelay<Movie>(value: Movie())
    private let podcastRelay = BehaviorRelay<Podcast>(value: Podcast())
    private let podcastSlicedRelay = BehaviorRelay<Podcast>(value: Podcast())
    private let showingRelay = BehaviorRelay<Bool>(value: false)
    private let typeRelay = BehaviorRelay<SelectedType>(value: .Search)
    private let suggestionRelay = PublishRelay<Suggestion>()



    // MARK: - Initializer
    init(fetchUseCase: FetchSuggestionUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase

        state = State(
            movieStream: movieSlicedRelay.asObservable(),
            podcastStream: podcastSlicedRelay.asObservable(),
            isShowingResults: showingRelay.asObservable(),
            selectedSuggestion: suggestionRelay.asObservable()
        )

        // Action 처리
        actionSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .fetch(let query):
                self.keywordRelay = query
                self.fetchMovie(query)
                self.fetchPodcast(query)

            case .selectSuggestion(let suggestion):
                self.showingRelay.accept(true)
                self.suggestionRelay.accept(suggestion)
                switch suggestion {
                case .movie(let movies, let index):
                    self.typeRelay.accept(.Movie)
                    let sliced = Array(movies.results[index...])
                    movieSlicedRelay.accept(
                        Movie(
                            resultCount: movies.resultCount, results: sliced
                        )
                    )
                case .podcast(let podcasts, let index):
                    self.typeRelay.accept(.Podcast)
                    let sliced = Array(podcasts.results[index...])
                    podcastSlicedRelay.accept(
                        Podcast(
                            resultCount: podcasts.resultCount,
                            results: sliced
                        )
                    )
                }

            case .enterSuggestion:
                self.showingRelay.accept(true)
                self.typeRelay.accept(.Search)

            case .cancelSearch:
                self.showingRelay.accept(false)
                self.movieSlicedRelay.accept(self.movieRelay.value)
                self.podcastSlicedRelay.accept(self.podcastRelay.value)
                self.typeRelay.accept(.Search)

            }
        })
            .disposed(by: disposeBag)
    }

    // MARK: - 네트워크
    private func fetchMovie(_ query: String) {
        fetchUseCase.executeMovies(query: query)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: {[weak self] movie in
                    self?.movieRelay.accept(movie)
                    self?.movieSlicedRelay.accept(movie)
                },
                onFailure: { error in
                    NSLog("Movie fetch error: \(error)")
                }
            )
            .disposed(by: disposeBag)

    }

    private func fetchPodcast(_ query: String) {
        fetchUseCase.executePodcasts(query: query)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: {[weak self] podcast in
                    self?.podcastRelay.accept(podcast)
                    self?.podcastSlicedRelay.accept(podcast)
                },
                onFailure: { error in
                    NSLog("Movie fetch error: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
}

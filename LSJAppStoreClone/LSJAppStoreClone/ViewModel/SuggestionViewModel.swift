//
//  SuggestionViewModel.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/11/25.
//

import Foundation

import RxSwift
import RxCocoa

final class SuggestionViewModel {

    // MARK: - Properties
    private let disposeBag = DisposeBag()

    private var movieResults = Movie()
    private var podcastResults = Podcast()

    let selectedSuggestion = PublishSubject<Suggestion>()
    let movieSubject    = BehaviorSubject(value: Movie())
    let podcastSubject  = BehaviorSubject(value: Podcast())
    let isShowingSearchResults = BehaviorRelay<Bool>(value: false)
    let selectedType    = BehaviorRelay<SelectedType>(value: .Search)
    let selectedIndex   = BehaviorRelay<Int>(value: 0)
    var currentKeyworkd = ""

    // MARK: - Initializer
    init() {
        selectedSuggestion
                   .map { _ in true }
                   .bind(to: isShowingSearchResults)
                   .disposed(by: disposeBag)

        selectedSuggestion
            .subscribe(onNext: { [weak self] suggestion in
                guard let self = self else { return }
                switch suggestion {
                case .movie(let movies, let index):
                    self.selectedType.accept(.Movie)
                    self.selectedIndex.accept(index)

                case .podcast(let podcasts, let index):
                    self.selectedType.accept(.Podcast)
                    self.selectedIndex.accept(index)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Methods
    func cancelSearch() {
        isShowingSearchResults.accept(false)
    }

    func fetchMovieAndPodcast(to query: String) {
        fetchMovie(to: query)
        fetchPodcast(to: query)
        currentKeyworkd = query
    }

    private func fetchMovie(to query: String) {

        guard let url = URL(string: "\(RequestURLType.Movie.url)\(query)") else { return }

        NetworkManager.shared.fetch(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
            onSuccess: { [weak self] (movie: Movie) in
                let sorted = movie.results.sorted { $0.releaseDate > $1.releaseDate }
                self?.movieSubject.onNext(Movie(
                    resultCount: movie.resultCount,
                    results: sorted
                    ))
            },

            onFailure: { [weak self] error in
                self?.movieSubject.onError(error)
                NSLog("MovieVM FetchMovie Error : \(error)")
            }
        )
            .disposed(by: disposeBag)
    }

    private func fetchPodcast(to query: String) {
        guard let url = URL(string: "\(RequestURLType.Podcast.url)\(query)") else { return }

        NetworkManager.shared.fetch(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
            onSuccess: { [weak self] (podcast: Podcast) in
                let sorted = podcast.results.sorted { $0.releaseDate > $1.releaseDate }
                self?.podcastSubject.onNext(Podcast(
                    resultCount: podcast.resultCount,
                    results: sorted
                    ))
                self?.podcastSubject.onNext(podcast)
            },
            onFailure: { [weak self] error in
                self?.podcastSubject.onError(error)
                NSLog("PodcastVM FetchPodcast Error : \(error)")
            }
        )
            .disposed(by: disposeBag)
    }

}


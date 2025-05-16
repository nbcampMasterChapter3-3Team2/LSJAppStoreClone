//
//  SuggestionRepositoryProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation

import RxSwift

protocol SuggestionRepositoryProtocol {
    func fetchMovies(query: String) -> Single<Movie>
    func fetchPodcasts(query: String) -> Single<Podcast>
}

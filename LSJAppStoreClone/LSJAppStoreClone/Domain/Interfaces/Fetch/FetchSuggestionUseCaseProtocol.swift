//
//  FetchSuggestionUseCaseProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

protocol FetchSuggestionUseCaseProtocol {
    func executeMovies(query: String) -> Single<Movie>
    func executePodcasts(query: String) -> Single<Podcast>
}

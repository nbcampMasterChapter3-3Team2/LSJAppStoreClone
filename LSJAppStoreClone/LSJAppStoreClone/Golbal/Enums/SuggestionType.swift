//
//  SuggestionType.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/13/25.
//

import Foundation

enum Suggestion {
    case movie(movie: Movie, index: Int)
    case podcast(podcast: Podcast, index: Int)
}

enum SelectedType: Int, CaseIterable {
    case Search
    case Movie
    case Podcast
}

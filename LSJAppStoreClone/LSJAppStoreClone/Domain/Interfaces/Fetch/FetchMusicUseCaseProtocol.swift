//
//  FetchMusicUseCaseProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

protocol FetchMusicUseCaseProtocol {
    func execute(season: Season) -> Single<Music>
}

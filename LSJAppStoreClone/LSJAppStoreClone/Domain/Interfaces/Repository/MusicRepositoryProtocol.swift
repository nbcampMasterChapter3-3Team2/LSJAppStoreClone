//
//  MusicRepositoryProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

protocol MusicRepositoryProtocol {
    func fetchMusic(season: Season) -> Single<Music>
}

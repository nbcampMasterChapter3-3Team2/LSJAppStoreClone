//
//  MusicRepositoryProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

protocol MusicRepositoryProtocol {
    /// 시즌별 음악 데이터를 가져옵니다
    func fetchMusic(season: Season) -> Single<Music>
}

//
//  FetchMusicUseCaseProtocol.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation
import RxSwift

protocol FetchMusicUseCaseProtocol {
    /// 비즈니스 로직(정렬·필터링)을 포함해 음악 데이터를 반환합니다
    func execute(season: Season) -> Single<Music>
}

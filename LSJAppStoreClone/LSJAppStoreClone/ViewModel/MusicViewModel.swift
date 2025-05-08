//
//  MusicViewModel.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import Foundation
import RxSwift

class MusicViewModel {

    private let disposBag = DisposeBag()

    let springMusicSubject = BehaviorSubject(value: Music())
    let summerMusicSubject = BehaviorSubject(value: Music())
    let fallMusicSubject = BehaviorSubject(value: Music())
    let winterMusicSubject = BehaviorSubject(value: Music())

    init() {
        Season.allCases.forEach { season in
            fetchMusic(to: season)
        }
    }

    private func fetchMusic(to season: Season) {

        guard let url = URL(string: "\(ApiUrlType.Music.url)\(season.rawValue)") else { return }

        NetworkManager.shared.fetch(url: url)
            .subscribe(
            onSuccess: { [weak self] (music: Music) in
                switch season {
                case .spring:
                    self?.springMusicSubject.onNext(music)
                case .summer:
                    self?.summerMusicSubject.onNext(music)
                case .fall:
                    self?.fallMusicSubject.onNext(music)
                case .winter:
                    self?.winterMusicSubject.onNext(music)
                }
            },
            onFailure: { [weak self] error in
                switch season {
                case .spring:
                    self?.springMusicSubject.onError(error)
                case .summer:
                    self?.summerMusicSubject.onError(error)
                case .fall:
                    self?.fallMusicSubject.onError(error)
                case .winter:
                    self?.winterMusicSubject.onError(error)
                }
            }
        )
            .disposed(by: disposBag)
    }

}

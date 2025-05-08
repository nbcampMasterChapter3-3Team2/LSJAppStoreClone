//
//  MusicViewController.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import UIKit

import RxSwift
import SnapKit
import Then

class MusicViewController: UIViewController {

    private let disposBag = DisposeBag()

    private var springMusics = Music()
    private var summerMusics = Music()
    private var fallMusics = Music()
    private var winterMusics = Music()

    let viewModel = MusicViewModel()


    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        print("binding : \(springMusics.resultCount)-\(springMusics.results.first!)")
        print("binding : \(summerMusics.resultCount)-\(summerMusics.results.first!)")
        print("binding : \(fallMusics.resultCount)-\(fallMusics.results.first!)")
        print("binding : \(winterMusics.resultCount)-\(winterMusics.results.first!)")
    }

    private func binding() {
        viewModel.springMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] musics in
                    self?.springMusics = musics
                },
                onError: {error in
                    NSLog("error binding : \(error.localizedDescription)")
                },
            )
            .disposed(by: disposBag)

        viewModel.summerMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] musics in
                    self?.summerMusics = musics
                },
                onError: {error in
                    NSLog("error binding : \(error.localizedDescription)")
                },
            )
            .disposed(by: disposBag)

        viewModel.fallMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] musics in
                    self?.fallMusics = musics
                },
                onError: {error in
                    NSLog("error binding : \(error.localizedDescription)")
                },
            )
            .disposed(by: disposBag)

        viewModel.winterMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] musics in
                    self?.winterMusics = musics
                },
                onError: {error in
                    NSLog("error binding : \(error.localizedDescription)")
                },
            )
            .disposed(by: disposBag)
    }
    

}


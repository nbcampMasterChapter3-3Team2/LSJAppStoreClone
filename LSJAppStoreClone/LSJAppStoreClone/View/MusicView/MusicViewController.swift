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

final class MusicViewController: UIViewController {

    // MARK: - Properties
    private let disposBag = DisposeBag()
    private let viewModel = MusicViewModel()
    private let cv = MusicViewCollectionViewManager()

    private var springMusics = Music()
    private var summerMusics = Music()
    private var fallMusics = Music()
    private var winterMusics = Music()

    // MARK: - UI Components
    private let searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = "영화, 팟케스트"
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: cv.createCompositionalLayout()).then {
        // 1) Cell 등록
        $0.register(SpringAlbumCell.self,
            forCellWithReuseIdentifier: SpringAlbumCell.id)
        $0.register(OthersAlbumCell.self,
            forCellWithReuseIdentifier: OthersAlbumCell.id)

        // 2) Header 등록
        $0.register(MusicViewSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MusicViewSectionHeaderView.id)

        // 3) 기본 속성
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false

        $0.backgroundColor = .systemBackground
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        setStyle()
        setHierarchy()
        setLayout()
        setDelegate()
        setDataSource()
    }

    // MARK: - Style Helper
    private func setStyle() {
        self.view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Music"
        navigationItem.searchController = searchController
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        view.addSubviews(collectionView)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Deleate Helper
    private func setDelegate() {
        collectionView.delegate = self
    }

    // MARK: - DataSource Helper
    private func setDataSource() {
        collectionView.dataSource = self

    }

    // MARK: - Methods
    private func binding() {
        viewModel.springMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.springMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.spring.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            },
        )
            .disposed(by: disposBag)

        viewModel.summerMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.summerMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.summer.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            },
        )
            .disposed(by: disposBag)

        viewModel.fallMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.fallMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.fall.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            },
        )
            .disposed(by: disposBag)

        viewModel.winterMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.winterMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.winter.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            },
        )
            .disposed(by: disposBag)
    }



    private func configure() {

    }


}

extension MusicViewController: UICollectionViewDelegate {

}

extension MusicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Season(rawValue: section) {
        case .spring: return springMusics.resultCount
        case .summer: return summerMusics.resultCount
        case .fall: return fallMusics.resultCount
        case .winter: return winterMusics.resultCount
        case .none: return 4
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let section = Season(rawValue: indexPath.section)
        let text = "\(indexPath.section)_\(indexPath.item)"

        switch section {
        case .spring:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SpringAlbumCell.id,
                for: indexPath
            ) as? SpringAlbumCell
                else { return UICollectionViewCell() }
            cell.configure(text: text)
            cell.backgroundColor = .red
            return cell

        case .summer, .fall, .winter:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OthersAlbumCell.id,
                for: indexPath
            ) as? OthersAlbumCell
                else { return UICollectionViewCell() }
            cell.configure(text: text)
            cell.backgroundColor = .red
            return cell

        case .none:
            return UICollectionViewCell()
        }
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Season.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MusicViewSectionHeaderView.id,
            for: indexPath
        ) as? MusicViewSectionHeaderView else { return UICollectionReusableView() }

        let sectionType = Season.allCases[indexPath.section]
        headerView.configure(season: sectionType)

        return headerView
    }
}


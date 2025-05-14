//
//  MusicViewController.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class MusicViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = MusicViewModel()
    private var suggestVC: SuggestionViewController {
        return searchController.searchResultsController as! SuggestionViewController
    }

    private let cv = CollectionViewManager()

    private var springMusics = Music()
    private var summerMusics = Music()
    private var fallMusics = Music()
    private var winterMusics = Music()

    // MARK: - UI Components
    private let searchController = UISearchController(
        searchResultsController: SuggestionViewController()
    ).then {
        $0.searchBar.placeholder = "영화, 팟캐스트"
        $0.definesPresentationContext = true
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: cv.createCompositionalLayout(of: .Music)).then {
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
        setStyle()
        setHierarchy()
        setLayout()
        setDelegate()
        setDataSource()
        binding()
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
        searchController.searchBar.delegate = self
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
            }
        )
            .disposed(by: disposeBag)

        viewModel.summerMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.summerMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.summer.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            }
        )
            .disposed(by: disposeBag)

        viewModel.fallMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.fallMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.fall.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            }
        )
            .disposed(by: disposeBag)

        viewModel.winterMusicSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] musics in
                self?.winterMusics = musics
                self?.collectionView.reloadSections(IndexSet(integer: Season.winter.rawValue))
            },
            onError: { error in
                NSLog("error binding : \(error.localizedDescription)")
            }
        )
            .disposed(by: disposeBag)

        searchBarBinding()

    }

    private func searchBarBinding() {
        self.searchController.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .bind { [weak self] text in
            self?.suggestVC.fetchMovieAndPodcast(to: text)
        }.disposed(by: disposeBag)
    }

    private func configure() {

    }
}

extension MusicViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            let section = Season.allCases[section]
            switch section {
            case .spring: return springMusics.results.count
            case .summer: return summerMusics.results.count
            case .fall: return fallMusics.results.count
            case .winter: return winterMusics.results.count
            }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch Season.allCases[indexPath.section] {
            case .spring:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SpringAlbumCell.id,
                    for: indexPath
                ) as? SpringAlbumCell else {
                    return UICollectionViewCell()
                }
                let album = springMusics.results[indexPath.item]
                cell.configure(data: album)
                return cell

            case .summer:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: OthersAlbumCell.id,
                    for: indexPath
                ) as? OthersAlbumCell else {
                    return UICollectionViewCell()
                }

                let album = summerMusics.results[indexPath.item]
                cell.configure(data: album)
                return cell

            case .fall:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: OthersAlbumCell.id,
                    for: indexPath
                ) as? OthersAlbumCell else {
                    return UICollectionViewCell()
                }
                let album = fallMusics.results[indexPath.item]
                cell.configure(data: album)

                return cell

            case .winter:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: OthersAlbumCell.id,
                    for: indexPath
                ) as? OthersAlbumCell else {
                    return UICollectionViewCell()
                }

                let album = winterMusics.results[indexPath.item]
                cell.configure(data: album)

                return cell
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
        ) as? MusicViewSectionHeaderView else {
            return UICollectionReusableView()
        }

        let sectionType = Season.allCases[indexPath.section]
        headerView.configure(season: sectionType)

        return headerView
    }
}

extension MusicViewController: UICollectionViewDelegate {

}

extension MusicViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        searchBar.resignFirstResponder()
        suggestVC.searchAndShowResult(keyword)
    }
}


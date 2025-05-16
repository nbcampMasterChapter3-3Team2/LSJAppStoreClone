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
    private let suggestVC = SuggestionViewController()
    private let cv = CollectionViewManager()

    // MARK: - UI Components
    private lazy var searchController = UISearchController(
        searchResultsController: suggestVC
    ).then {
        $0.searchBar.placeholder = "영화, 팟캐스트"
        $0.definesPresentationContext = true
        $0.obscuresBackgroundDuringPresentation = true
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: cv.createCompositionalLayout(of: .Music)).then {
        $0.register(SpringAlbumCell.self,
            forCellWithReuseIdentifier: SpringAlbumCell.id)
        $0.register(OthersAlbumCell.self,
            forCellWithReuseIdentifier: OthersAlbumCell.id)

        $0.register(MusicViewSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MusicViewSectionHeaderView.id)

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
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false
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
        let streams = Season.allCases.compactMap { viewModel.state.musicStreams[$0]
        }

        Observable.combineLatest(streams)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            self?.collectionView.reloadData()
        })
            .disposed(by: disposeBag)

        searchBarBinding()
    }

    private func searchBarBinding() {
        self.searchController.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .bind { [weak self] text in
            self?.suggestVC.fetchMovieAndPodcast(to: text)
        }.disposed(by: disposeBag)

        /// SuggesVC SearchController 밑에 입력한 text(또는 view)를 클릭시
        /// searchController 해제 함수 (Closure 함수)
        suggestVC.onSearchHeaderTap = { [weak self] in
            self?.searchController.isActive = false
        }
    }
}

extension MusicViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let season = Season.allCases[section]
        return viewModel.relay(for: season).value.results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let season = Season.allCases[indexPath.section]
        let album = viewModel.relay(for: season).value.results[indexPath.item]
        switch season {
        case .spring:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SpringAlbumCell.id,
                for: indexPath
            ) as? SpringAlbumCell else {
                return UICollectionViewCell()
            }
            cell.configure(data: album)
            return cell
        case .summer, .fall, .winter:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OthersAlbumCell.id, for: indexPath) as? OthersAlbumCell else {
                return UICollectionViewCell()
            }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        let season = Season.allCases[indexPath.section]
        let item = viewModel.relay(for: season).value.results[indexPath.item]

        let snapshot = cell.contentView.snapshotView(afterScreenUpdates: false)!
        let originalFrame = cell.convert(cell.bounds, to: view)
        snapshot.frame = originalFrame
        view.addSubview(snapshot)
        cell.isHidden = true

        let detailVC = DetailViewController()
        detailVC.configure(type: .Music, to: item)

        detailVC.modalPresentationStyle = .overFullScreen
        self.present(detailVC, animated: false) {
            snapshot.removeFromSuperview()
            cell.isHidden = false
        }
    }
}

extension MusicViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        searchBar.resignFirstResponder()
        suggestVC.searchAndShowResult(keyword)
    }
}


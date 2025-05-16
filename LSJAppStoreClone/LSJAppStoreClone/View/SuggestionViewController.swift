//
//  SuggestionViewController.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/11/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class SuggestionViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = SuggestionViewModel()

    var onSearchHeaderTap: (() -> Void)?

    // MARK: - UI Components
    private let tableView = UITableView().then {
        $0.register(SuggestionTableViewCell.self, forCellReuseIdentifier: SuggestionTableViewCell.id)
        $0.rowHeight = 50
        $0.backgroundColor = .systemBackground
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CollectionViewManager().createCompositionalLayout(of: .Search)
    ).then {
        $0.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.id)
        $0.register(
            SearchResultHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchResultHeaderView.id
        )
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
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        view.addSubviews(tableView, collectionView)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Deleate Helper
    private func setDelegate() {
        tableView.delegate = self
        collectionView.delegate = self
    }

    // MARK: - DataSource Helper
    private func setDataSource() {
        tableView.dataSource = self
        collectionView.dataSource = self
    }

    // MARK: - Methods
    private func binding() {
        viewModel.state.movieStream
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
            self?.tableView.reloadData()
            self?.collectionView.reloadData()
        })
            .disposed(by: disposeBag)

        viewModel.state.podcastStream
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] podcasts in
            self?.tableView.reloadData()
            self?.collectionView.reloadData()
        })
            .disposed(by: disposeBag)

        viewModel.state.isShowingResults
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.state.isShowingResults
            .map { !$0 }
            .bind(to: collectionView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.state.selectedSuggestion
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
            self?.collectionView.reloadData()
        })
            .disposed(by: disposeBag)
    }

    func fetchMovieAndPodcast(to kw: String) {
        viewModel.action.onNext(.cancelSearch)
        viewModel.action.onNext(.fetch(query: kw))
    }

    func searchAndShowResult(_ kw: String) {
        viewModel.action.onNext(.cancelSearch)
        viewModel.action.onNext(.fetch(query: kw))
        viewModel.action.onNext(.enterSuggestion)

    }

    private var displayedSections: [SelectedType] {
        switch viewModel.selectedTypeValue {
        case .Search: return [.Search, .Movie, .Podcast]
        case .Movie: return [.Search, .Movie]
        case .Podcast: return [.Search, .Podcast]
        }
    }
}

// MARK: - UITableView
extension SuggestionViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ talbleView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return section == 0 ? viewModel.movies.results.count : viewModel.podcasts.results.count
    }

    func tableView(_ talbleView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = talbleView.dequeueReusableCell(
            withIdentifier: SuggestionTableViewCell.id,
            for: indexPath
        ) as? SuggestionTableViewCell else {
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            cell.configureMovie(with: viewModel.movies.results[indexPath.row])
        } else {
            cell.configurePodcast(with: viewModel.podcasts.results[indexPath.row])
        }
        return cell
    }
}

extension SuggestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let suggestion: Suggestion = indexPath.section == 0
        ? .movie(movie: viewModel.movies, index: indexPath.row)
        : .podcast(podcast: viewModel.podcasts, index: indexPath.row)
        viewModel.action.onNext(.selectSuggestion(suggestion))
    }
}

// MARK: - UICollectionView
extension SuggestionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        displayedSections.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch displayedSections[section] {
        case .Movie: return viewModel.movies.results.count
        case .Podcast: return viewModel.podcasts.results.count
        case .Search: return 0
        }
    }
    func collectionView(
        _ cv: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = cv.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.id,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }

        switch displayedSections[indexPath.section] {
        case .Movie:
            cell.configureMovie(with: viewModel.movies.results[indexPath.item])
        case .Podcast:
            cell.configurePodcast(with: viewModel.podcasts.results[indexPath.item])
        case .Search:
            break
        }
        return cell
    }
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return .init() }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SearchResultHeaderView.id,
            for: indexPath
        ) as? SearchResultHeaderView else {
            return UICollectionReusableView()
        }

        switch displayedSections[indexPath.section] {
        case .Search:
            header.configure(text: viewModel.keywordRelay, section: .Search)
            header.onTap = { [weak self] in
                self?.viewModel.action.onNext(.cancelSearch)
                self?.onSearchHeaderTap?()
            }
        case .Movie:
            header.configure(text: viewModel.movies.results.isEmpty ? "" : "Movie", section: .Movie)
            header.onTap = nil
        case .Podcast:
            header.configure(text: viewModel.podcasts.results.isEmpty ? "" : "Podcast", section: .Podcast)
            header.onTap = nil
        }
        return header
    }
}

extension SuggestionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        let section = displayedSections[indexPath.section]
        var selectedItem: Any? = nil
        var type: RequestURLType? = nil

        switch section {
        case .Search: break
        case .Movie:
            selectedItem = viewModel.movies.results[indexPath.item]
            type = .Movie
        case .Podcast:
            selectedItem = viewModel.podcasts.results[indexPath.item]
            type = .Podcast
        }

        guard let snapshot = cell.contentView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        let originalFrame = cell.convert(cell.bounds, to: view)
        snapshot.frame = originalFrame
        view.addSubview(snapshot)
        cell.isHidden = true

        let detailVC = DetailViewController()
        detailVC.configure(type: type ?? .Movie, to: selectedItem)

        detailVC.modalPresentationStyle = .overFullScreen
        self.present(detailVC, animated: false) {
            snapshot.removeFromSuperview()
            cell.isHidden = false
        }

    }

}

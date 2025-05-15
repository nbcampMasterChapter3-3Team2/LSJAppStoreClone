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

    private var movieResults = Movie()
    private var podcastResults = Podcast()

    private let cv = CollectionViewManager()

    var onSearchHeaderTap: (() -> Void)?

    // MARK: - UI Components
    private let tableView = UITableView().then {
        $0.register(SuggestionTableViewCell.self,
            forCellReuseIdentifier: SuggestionTableViewCell.id)
        $0.rowHeight = 50
        $0.isHidden = false
        $0.backgroundColor = .systemBackground
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: cv.createCompositionalLayout(of: .Search)).then {
        $0.register(SearchResultCell.self,
            forCellWithReuseIdentifier: SearchResultCell.id)

        $0.register(SearchResultHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchResultHeaderView.id)


        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false

        $0.isHidden = true
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
        view.backgroundColor = .systemBackground
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        self.view.addSubviews(tableView, collectionView)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Delegate Helper
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
        viewModel.movieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] movies in
                self?.movieResults = movies
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
            },
            onError: { error in
                NSLog("error binding movie : \(error.localizedDescription)")
            }
        )
            .disposed(by: disposeBag)


        viewModel.podcastSubject
            .observe(on: MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] podcasts in
                self?.podcastResults = podcasts
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
            },
            onError: { error in
                NSLog("error binding movie : \(error.localizedDescription)")
            }
        )
            .disposed(by: disposeBag)

        viewModel.isShowingSearchResults
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.isShowingSearchResults
            .map { !$0 }
            .bind(to: collectionView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.selectedSuggestion
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] suggestion in
            guard let self = self else { return }
            switch suggestion {
            case .movie(let movies, let index):
                let sliced = Array(movies.results[index...])
                self.movieResults = Movie(
                    resultCount: movies.resultCount,
                    results: sliced
                )

            case .podcast(let podcasts, let index):
                let sliced = Array(podcasts.results[index...])
                self.podcastResults = Podcast(
                    resultCount: podcasts.resultCount,
                    results: sliced
                )
            }

            self.tableView.reloadData()
            self.collectionView.reloadData()
        })
            .disposed(by: disposeBag)
    }

    func fetchMovieAndPodcast(to kw: String) {
        viewModel.cancelSearch()
        viewModel.fetchMovieAndPodcast(to: kw)
    }

    func searchAndShowResult(_ kw: String) {
        viewModel.cancelSearch()
        viewModel.selectedIndex.accept(0)
        viewModel.isShowingSearchResults.accept(true)
        viewModel.selectedType.accept(.Search)
        viewModel.fetchMovieAndPodcast(to: kw)
    }

    private var displayedSections: [SelectedType] {
        switch viewModel.selectedType.value {
        case .Search:
            return [.Search, .Movie, .Podcast]
        case .Movie:
            return [.Search, .Movie]
        case .Podcast:
            return [.Search, .Podcast]
        }
    }
}

extension SuggestionViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return movieResults.results.count
        case 1: return podcastResults.results.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SuggestionTableViewCell.id,
            for: indexPath
        ) as? SuggestionTableViewCell else {
            return UITableViewCell()
        }
        switch indexPath.section {
        case 0:
            let result = movieResults.results[indexPath.row]
            cell.configureMovie(with: result)
        case 1:
            let result = podcastResults.results[indexPath.row]
            cell.configurePodcast(with: result)
        default:
            return UITableViewCell()
        }
        return cell
    }
}

extension SuggestionViewController: UITableViewDelegate {
    // 셀 선택 시 동작
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let suggestion: Suggestion = indexPath.section == 0
            ? .movie(movie: movieResults, index: indexPath.row)
        : .podcast(podcast: podcastResults, index: indexPath.row)
        viewModel.selectedSuggestion.onNext(suggestion)
    }
}

// TODO: - 도전과제 : 아이템 선택시 상세화면 뷰 이동
extension SuggestionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        let section = displayedSections[indexPath.section]
        var selectedItem: Any? = nil
        var type: RequestURLType? = nil

        switch section {
        case .Search: break
        case .Movie:
            selectedItem = movieResults.results[indexPath.item]
            type = .Movie
        case .Podcast:
            selectedItem = podcastResults.results[indexPath.item]
            type = .Podcast
        }

        let snapshot = cell.contentView.snapshotView(afterScreenUpdates: false)!
        let originalFrame = cell.convert(cell.bounds, to: view)
        snapshot.frame = originalFrame
        view.addSubview(snapshot)
        cell.isHidden = true

        let detailVC = DetailViewController()
        detailVC.configure(type: type!, to: selectedItem)

        detailVC.modalPresentationStyle = .overFullScreen
        self.present(detailVC, animated: false) {
            snapshot.removeFromSuperview()
            cell.isHidden = false
        }

    }
}

extension SuggestionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayedSections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = displayedSections[section]
        switch section {
        case .Search: return 0
        case .Movie: return movieResults.results.count
        case .Podcast: return podcastResults.results.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.id,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }
        switch displayedSections[indexPath.section] {
        case .Movie:
            let movie = movieResults.results[indexPath.item]
            cell.configureMovie(with: movie)
        case .Podcast:
            let podcast = podcastResults.results[indexPath.item]
            cell.configurePodcast(with: podcast)
        case .Search:
            return UICollectionViewCell()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SearchResultHeaderView.id,
            for: indexPath
        ) as? SearchResultHeaderView else {
            return UICollectionReusableView()
        }

        switch displayedSections[indexPath.section] {
        case .Search:
            headerView.configure(text: viewModel.currentKeyworkd, section: .Search)
            headerView.onTap = { [weak self] in
                self?.viewModel.cancelSearch()
                self?.onSearchHeaderTap?()
            }
        case .Movie:
            headerView.configure(text: movieResults.results.isEmpty ? "" : "Movie", section: .Movie)
            headerView.onTap = nil

        case .Podcast:
            headerView.configure(text: podcastResults.results.isEmpty ? "" : "Podcast", section: .Podcast)
            headerView.onTap = nil
        }
        return headerView
    }
}


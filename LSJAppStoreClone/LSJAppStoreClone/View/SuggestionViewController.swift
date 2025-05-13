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

    private let disposeBag = DisposeBag()
    private let viewModel = SuggestionViewModel()

    private var movieResults = Movie()
    private var podcastResults = Podcast()

    private var selectedIndex = 0
    private var selectedType: SelectedType = .Movie

    private let cv = CollectionViewManager()

    // MARK: - UI Components
    private let tableView = UITableView().then {
        $0.register(SuggestionTableViewCell.self,
            forCellReuseIdentifier: SuggestionTableViewCell.id)
        $0.rowHeight = 50
        $0.isHidden = false
        $0.backgroundColor = .systemBackground
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: cv.createCompositionalLayout(of: .Search)).then {
        // 1) Cell 등록
        $0.register(SearchResultCell.self,
            forCellWithReuseIdentifier: SearchResultCell.id)

        // 3) 기본 속성
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
        binding()
    }

    // MARK: - Style Helper
    private func setStyle() {
        view.backgroundColor = .systemBackground
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        view.addSubviews(tableView, collectionView)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Delegate/DataSource Helper
    private func setDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - Methods
    func fetchMovieAndPodcast(to kw: String) {
        self.selectedIndex = 0
        viewModel.cancelSearch()
        viewModel.fetchMovieAndPodcast(to: kw)
    }

    func searchAndShowResult(_ kw: String) {
        viewModel.cancelSearch()
        viewModel.isShowingSearchResults.accept(true)
        viewModel.fetchMovieAndPodcast(to: kw)
    }

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
                self.selectedType = .Movie
                self.selectedIndex = index
                let sliced = Array(movies.results[index...])
                self.movieResults = Movie(
                    resultCount: movies.resultCount,
                    results: sliced
                )
            case .podcast(let podcasts, let index):
                self.selectedType = .Podcast
                self.selectedIndex = index
                let sliced = Array(podcasts.results[index...])
                self.podcastResults = Podcast(
                    resultCount: sliced.count,
                    results: sliced
                )
                self.podcastResults = Podcast(resultCount: podcasts.resultCount, results: sliced)
            }

            self.tableView.reloadData()
            self.collectionView.reloadData()
        })
            .disposed(by: disposeBag)

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

        self.selectedType = indexPath.section == 0 ? .Movie : .Podcast
        self.selectedIndex = indexPath.item

        let suggestion: Suggestion = indexPath.section == 0 ?
            .movie(movie: self.movieResults, index: indexPath.item): .podcast(podcast: self.podcastResults, index: indexPath.item)
        viewModel.selectedSuggestion.onNext(suggestion)
    }
}

extension SuggestionViewController: UICollectionViewDelegate { }

extension SuggestionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return movieResults.results.count
        case 1: return podcastResults.results.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.id,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }

        switch indexPath.section {
        case 0:
            let movie = movieResults.results[indexPath.item]
            cell.configureMovie(with: movie)
        case 1:
            let podcast = podcastResults.results[indexPath.item]
            cell.configurePodcast(with: podcast)
        default:
            return UICollectionViewCell()
        }
        return cell
    }
}


//
//  DetailViewController.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/15/25.
//

import UIKit

import SnapKit
import Then

class DetailViewController: UIViewController {
    // MARK: - Properties
    var intoType: APIEndpoints?

    // MARK: - UI Components
    private let closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark.circle.fill")?.resize(newWidth: 32), for: .normal)
        $0.tintColor = .white

    }
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }

    private let overlayView = UIView().then {
        $0.backgroundColor = UIColor(white: 0, alpha: 0.6)
    }

    private let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .white
        $0.numberOfLines = 1
    }

    private let artistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .customSecondary
        $0.numberOfLines = 1
    }

    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.text = sampleDesc
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        setHierarchy()
        setLayout()
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        setDelegate()
    }

    // MARK: - Style Helper
    private func setStyle() {
        view.backgroundColor = .systemBackground
        modalPresentationCapturesStatusBarAppearance = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        scrollView.addSubview(contentView)
        contentView.addSubviews(albumImageView, overlayView, descriptionLabel)
        overlayView.addSubviews(trackNameLabel, artistNameLabel)
        view.addSubviews(scrollView, closeButton)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        // ScrollView
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        // Album Image
        albumImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(contentView)
            $0.height.equalTo(400)
        }
        // Overlay View
        overlayView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(albumImageView.snp.bottom).offset(-60)
            $0.height.equalTo(60)
        }
        // Track Name
        trackNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview().offset(-8)
            $0.trailing.equalToSuperview().inset(16)
        }
        // Artist Name
        artistNameLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(trackNameLabel)
            $0.top.equalTo(trackNameLabel.snp.bottom)
        }
        // Description Label
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(overlayView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(trackNameLabel)
            $0.bottom.equalTo(contentView.snp.bottom)
        }
        // Close Button
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view).inset(20)
            $0.trailing.equalTo(view).inset(20)
        }
    }

    // MARK: - Delegate Helper
    private func setDelegate() {
        scrollView.delegate = self
    }

    // MARK: - Methods
    func configure(type: APIEndpoints, to results: Any?) {
        guard results != nil else { return }

        switch type {
        case .Movie:
            guard let item = results as? MovieResult else { return }
            apply(item: item)
        case .Music:
            guard let item = results as? MusicResult else { return }
            apply(item: item)
        case .Podcast:
            guard let item = results as? PodcastResult else { return }
            apply(item: item)
        }
    }

    private func apply(item: MusicResult) {
        if let url = URL(string: item.artworkUrl100) {
            albumImageView.kf.setImage(with: url)
        }
        trackNameLabel.text = item.trackName
        artistNameLabel.text = item.artistName
    }

    private func apply(item: MovieResult) {
        if let url = URL(string: item.artworkUrl100) {
            albumImageView.kf.setImage(with: url)
        }
        trackNameLabel.text = item.trackName
        artistNameLabel.text = item.artistName
        descriptionLabel.text = item.longDescription
    }

    private func apply(item: PodcastResult) {
        if let url = URL(string: item.artworkUrl600) {
            albumImageView.kf.setImage(with: url)
        }
        trackNameLabel.text = item.trackName
        artistNameLabel.text = item.artistName
    }

    @objc private func dismissSelf() {
        dismiss(animated: false, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -250 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.dismissSelf()
            })
        }
    }
}

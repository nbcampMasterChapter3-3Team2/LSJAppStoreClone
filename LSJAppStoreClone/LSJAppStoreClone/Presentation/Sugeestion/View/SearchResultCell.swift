//
//  SearchResultCell.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/12/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class SearchResultCell: UICollectionViewCell {

    // MARK: - Properties
    static let id = "SearchResultCell"

    // MARK: - UI Components
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }

    private let overlayView = UIView().then {
        $0.backgroundColor = UIColor(white: 0, alpha: 0.6)
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }

    private let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .white
        $0.numberOfLines = 1
    }


    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyle()
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Style Helper
    private func setStyle() {
        self.contentView.backgroundColor = .systemGray5
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true

    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        contentView.addSubviews(backgroundImageView, overlayView)
        overlayView.addSubviews(trackNameLabel)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(60)
        }

        trackNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - Methods
    func configureMovie(with data: MovieResult) {
        guard let backgroundImageUrl = URL(string: data.artworkUrl100) else {
            return
        }

        backgroundImageView.kf.setImage(with: backgroundImageUrl)
        trackNameLabel.text = data.trackName
    }

    func configurePodcast(with data: PodcastResult) {
        guard let backgroundImageUrl = URL(string: data.artworkUrl600) else {
            return
        }
        backgroundImageView.kf.setImage(with: backgroundImageUrl)
        trackNameLabel.text = data.trackName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImageView.image = nil
        trackNameLabel.text = nil
    }

}


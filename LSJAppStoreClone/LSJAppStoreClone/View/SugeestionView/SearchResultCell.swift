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
    private let titleLabel = UILabel().then {
        $0.text = "테스트"
        $0.textColor = .label
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        contentView.addSubviews(titleLabel)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
    }

    func configureMovie(with data: MovieResult) {
        titleLabel.text = data.trackName
    }

    func configurePodcast(with data: PodcastResult) {
        titleLabel.text = data.trackName
    }


    override func prepareForReuse() {
        super.prepareForReuse()
    }

}


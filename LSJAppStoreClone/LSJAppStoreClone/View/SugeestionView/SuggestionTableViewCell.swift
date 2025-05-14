//
//  SuggestionTableViewCell.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/12/25.
//

import UIKit

import SnapKit
import Then

final class SuggestionTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let id = "SuggestionTableViewCell"

    // MARK: - UI Components
    private let iconLabel = UIImageView().then {
        $0.tintColor = .customSecondary
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 2
    }


    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        contentView.addSubviews(iconLabel, titleLabel)
    }
    // MARK: - Layout Helper
    private func setLayout() {
        iconLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }

    // MARK: - Methods
    func configureMovie(with result: MovieResult) {
        iconLabel.image = UIImage(systemName: "movieclapper")
        titleLabel.text = result.trackName
    }

    func configurePodcast(with result: PodcastResult) {
        iconLabel.image = UIImage(systemName: "antenna.radiowaves.left.and.right.circle")
        titleLabel.text = result.trackName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconLabel.image = nil
        titleLabel.text = nil
    }
}


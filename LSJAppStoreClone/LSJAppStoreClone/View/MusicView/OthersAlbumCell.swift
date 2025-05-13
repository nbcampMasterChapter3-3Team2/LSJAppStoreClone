//
//  OthersAlbumCell.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class OthersAlbumCell: UICollectionViewCell {

    // MARK: - Properties
    static let id = "OthersAlbumCell"

    // MARK: - UI Components
    private let artworkImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }

    private let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }

    private let artistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }

    private let divider = UIView().then {
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 1
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
        contentView.addSubviews(artworkImageView, trackNameLabel, artistNameLabel, divider)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        artworkImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(50)
        }

        trackNameLabel.snp.makeConstraints {
            $0.top.equalTo(artworkImageView.snp.top).offset(8)
            $0.leading.equalTo(artworkImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-8)
        }

        artistNameLabel.snp.makeConstraints {
            $0.leading.equalTo(trackNameLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-8)
            $0.top.equalTo(trackNameLabel.snp.bottom).offset(4)
        }

        divider.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func configure(data: Music, index: Int) {
        guard let artworkImageUrl = URL(string: data.results[index].artworkUrl100) else {
            NSLog("ERROR : Configure \(index)")
            return
        }

        artworkImageView.kf.setImage(with: artworkImageUrl)
        trackNameLabel.text = data.results[index].trackName
        artistNameLabel.text = data.results[index].artistName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        divider.layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
    }

}

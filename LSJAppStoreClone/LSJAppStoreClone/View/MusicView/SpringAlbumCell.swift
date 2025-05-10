//
//  SpringAlbumCell.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class SpringAlbumCell: UICollectionViewCell {

    // MARK: - Properties
    static let id = "SpringAlbumCell"

    // MARK: - UI Components
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
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

    private let artistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .cSecondary
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
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        addSubviews(backgroundImageView, overlayView)
        overlayView.addSubviews(trackNameLabel, artistNameLabel)
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
            $0.centerY.equalToSuperview().offset(-8)
        }

        artistNameLabel.snp.makeConstraints {
            $0.leading.equalTo(trackNameLabel)
            $0.top.equalTo(trackNameLabel.snp.bottom)
        }

    }

    // MARK: - Methods
    func configure(data: Music, index: Int) {
        guard let backgroundImageUrl = URL(string: data.results[index].artworkUrl100) else {
            NSLog("ERROR : Configure \(index)")
            return
        }

        backgroundImageView.kf.setImage(with: backgroundImageUrl)
        trackNameLabel.text = data.results[index].trackName
        artistNameLabel.text = data.results[index].artistName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImageView.image = nil
    }
}


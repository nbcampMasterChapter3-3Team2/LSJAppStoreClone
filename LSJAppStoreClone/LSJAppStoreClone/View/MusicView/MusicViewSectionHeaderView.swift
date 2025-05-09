//
//  MusicViewSectionHeaderView.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import UIKit

import SnapKit
import Then

final class MusicViewSectionHeaderView: UICollectionReusableView {
    static let id = "MusicViewSectionHeader"

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textColor = .label
    }

    private let descLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setHierarchy() {
        addSubviews(titleLabel, descLabel)
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
        }

        descLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
    }

    func configure(season: Season) {
        titleLabel.text = season.query
    }

}

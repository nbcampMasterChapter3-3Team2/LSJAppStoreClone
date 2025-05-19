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

    // MARK: - Properties
    static let id = "MusicViewSectionHeader"

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .label
    }

    private let descLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .secondaryLabel
    }


    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hierarchy Helper
    private func setHierarchy() {
        addSubviews(titleLabel, descLabel)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
        }

        descLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }

    // MARK: - Methods
    func configure(season: Season) {
        titleLabel.text = season.title
        descLabel.text = season.description
    }

}

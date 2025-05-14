//
//  SearchResultHeaderView.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/13/25.
//

import UIKit

import SnapKit
import Then

final class SearchResultHeaderView: UICollectionReusableView {

    // MARK: - Properties
    static let id = "SearchResultViewSectionHeader"

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        $0.textColor = .label
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
        addSubviews(titleLabel)
    }

    // MARK: - Layout Helper
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
        }
    }

    // MARK: - Methods
    func configure(text: String) {
        titleLabel.text = text
    }

}


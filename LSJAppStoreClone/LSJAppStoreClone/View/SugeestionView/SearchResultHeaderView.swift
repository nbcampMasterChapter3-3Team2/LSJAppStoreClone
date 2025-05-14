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

    var onTap: (() -> Void)?

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .label
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setLayout()
        setupGesture()
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
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - Methods
    func configure(text: String, section: SelectedType) {
        titleLabel.text = text
        switch section {
        case .Movie:
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        case .Podcast:
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        case .Search:
            titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }
    }
    private func setupGesture() {
        // 뷰가 탭을 받을 수 있게
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        addGestureRecognizer(tap)
    }

    // MARK: - @objc Methods
    @objc private func didTapHeader() {
        onTap?()
    }
}


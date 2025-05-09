//
//  OthersAlbumCell.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/8/25.
//

import UIKit

import SnapKit
import Then

final class OthersAlbumCell: UICollectionViewCell {
    static let id = "OthersAlbumCell"

    private let label = UILabel().then {
        $0.text = "가"
        $0.textColor = .label
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setStyle() {
        self.contentView.backgroundColor = .systemBlue
    }

    private func setHierarchy() {
        addSubview(label)
    }

    private func setLayout() {
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func configure(text: String) {
        label.text = text

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

}

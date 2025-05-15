//
//  UIButton+.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/15/25.
//

import UIKit
import Foundation

extension UIButton {

    func setImage(systemName: String) {
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill

        imageView?.contentMode = .scaleAspectFit

        setImage(UIImage(systemName: systemName), for: .normal)
    }
}

//
//  SizeLiterals+.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/9/25.
//

import UIKit

struct SizeLiterals {
    struct Screen {
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        /// 사용법 :  $0.width.equalTo(SizeLiterals.Screen.screenWidth * 25 / 402)
        /// ==> 기기별 넓이 25사이즈 대응
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
        /// 사용법 :  $0.height.equalTo(SizeLiterals.Screen.screenHeight * 25 / 874)
        /// ==> 기기별 높이 25사이즈 대응
        static let deviceRatio: CGFloat = screenWidth / screenHeight

        static let isSmallDevice: Bool = min(screenWidth, screenHeight) <= 375
    }
}

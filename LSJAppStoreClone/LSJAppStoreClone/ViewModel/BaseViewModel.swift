//
//  BaseViewModel.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/15/25.
//

import Foundation
import RxSwift

protocol BaseViewModel {
    associatedtype Action
    associatedtype State

    var disposeBag: DisposeBag { get }          // DisposeBag
    var action: AnyObserver<Action> { get }     // Action을 주입받을 통로
    var state: State { get }                    // View 쪽에 전달되는 상태 스트림
}

//
//  DIContainerManager.swift
//  LSJAppStoreClone
//
//  Created by yimkeul on 5/16/25.
//

import Foundation

final class DIContainerManager {
    static let shared = DIContainerManager()
    private var factories = [String: () -> Any]()

    private init() {}

    // ① 타입을 키로 팩토리 등록
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    // ② 등록된 팩토리로 인스턴스 생성
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard
            let factory = factories[key],
            let instance = factory() as? T
        else {
            fatalError("No registration for \(key)")
        }
        return instance
    }
}

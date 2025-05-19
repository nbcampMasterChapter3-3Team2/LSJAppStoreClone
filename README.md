# LSJAppStoreClone
내일배움캠프 Ch 3. 앱개발 심화 주차 과제 - Challenge

## 사용 라이브러리
라이브러리 | 사용 목적 | Management Tool
:---------:|:----------:|:---------:
SnapKit | UI Layout | SPM
Then | UI 선언 | SPM
Alamofire | HTTP 네트워크 | SPM
Kingfisher | URL 이미키 캐싱 | SPM
RxSwift | 비동기 처리 | SPM

## 프로젝트 설계
CleanArchitecture + MVVM (State-Action 패턴)

## 폴더구조
📁 프로젝트 폴더 구조
```
LSJAppStoreClone
└── LSJAppStoreClone
    ├── App
    │   ├── DIContainerManager.swift
    │   ├── AppDelegate.swift
    │   ├── Info.plist
    │   └── SceneDelegate.swift
    │
    ├── Data
    │   ├── Network
    │   │   ├── APIEndpoints.swift
    │   │   ├── DefaultNetworkService.swift
    │   │   └── NetworkErrorType.swift
    │   └── Repository
    │       ├── MusicRepository.swift
    │       └── SuggestionRepository.swift
    │
    ├── Domain
    │   ├── Entities
    │   │   ├── Enums
    │   │   ├── Movie.swift
    │   │   ├── Music.swift
    │   │   ├── Podcast.swift
    │   │   └── Suggestion.swift
    │   └── Interfaces
    │       ├── Fetch
    │       │   ├── FetchMusicUseCaseProtocol.swift
    │       │   └── FetchSuggestionUseCaseProtocol.swift
    │       ├── Network
    │       │   └── NetworkServiceProtocol.swift
    │       ├── Repository
    │       │   ├── MusicRepositoryProtocol.swift
    │       │   └── SuggestionRepositoryProtocol.swift
    │       └── UseCases
    │           ├── FetchMusicUseCase.swift
    │           └── FetchSuggestionUseCase.swift
    │
    ├── Golbal
    │   ├── Extensions
    │   │   ├── UIButton+.swift
    │   │   ├── UIColor+.swift
    │   │   ├── UIImage+.swift
    │   │   └── UIView+.swift
    │   ├── Literals
    │   │   ├── SampleText.swift
    │   │   └── SizeLiterals.swift
    │   └── Manager
    │       └── NetworkManager.swift
    │
    ├── Presentation
    │   ├── Common
    │   │   ├── BaseProtocols
    │   │   │   └── BaseViewModel.swift
    │   │   └── Layouts
    │   │       └── CollectionViewManager.swift
    │   ├── Detail
    │   │   └── View
    │   │       └── DetailViewController.swift
    │   ├── Music
    │   │   ├── View
    │   │   │   ├── MusicViewController.swift
    │   │   │   ├── MusicViewSectionHeaderView.swift
    │   │   │   ├── OthersAlbumCell.swift
    │   │   │   └── SpringAlbumCell.swift
    │   │   └── ViewModel
    │   │       └── MusicViewModel.swift
    │   └── Sugeestion
    │       ├── View
    │       │   ├── SearchResultCell.swift
    │       │   ├── SearchResultHeaderView.swift
    │       │   ├── SuggestionTableViewCell.swift
    │       │   └── SuggestionViewController.swift
    │       └── ViewModel
    │           └── SuggestionViewModel.swift
    │
    ├── Resource
    │   └── Assets.xcassets
    │
    └── Storyboard
        └── LaunchScreen.storyboard
```

## 시연영상
|    실행 기기    |   스크린샷(또는 GIF)   |
| :-------------: | :----------: |
| iPhone - 16 Pro <br> Music 화면 + Detail View | <img src = "https://github.com/user-attachments/assets/2bbab67e-baaa-4e25-9261-691a9dc2b47e" width ="250">|
| iPhone - 16 Pro <br> SuggestionView(검색화면) | <img src = "https://github.com/user-attachments/assets/bbca045b-225d-4afe-9c2e-f19e6e326c94" width ="250">|
| iPhone - 16 Pro <br> SuggestionView(검색결과화면) + Detail View| <img src = "https://github.com/user-attachments/assets/3c3a69de-f5e8-4dfc-b04f-9420dbd7ea97" width ="250">|









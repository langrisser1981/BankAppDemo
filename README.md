# BankAppDemo

## 系統環境
* 發布平台: iOS 16
* 開發環境: xcode 15.4
* 第三方函式庫
  * SnapKit

編譯時會使用到 swiftlint & swiftformat，如果系統沒有安裝，編譯過程會出現報警黃自，但不影響輸出

## 操作流程
1. 啟動程式後，可以在起始畫面選擇三種情境，分別呼叫不同的後端端點
2. 進入程式後會根據情境顯示對應的畫面
3. 點擊登出按鈕，會回到起始畫面，方便測試不同的情境
4. 畫面下方的標籤列可以點擊，會跳到對應的畫面，目前保留空白僅顯示畫面名稱
5. KO(支付碼按鈕嗎？)支援不規則圖形，點擊後會present一個空的支付畫面
6. 下拉表格支援更新資料
7. 在搜尋框輸入姓名，會過濾顯示的朋友清單(針對 status= 1|2 進行過濾，不過濾收到的邀請)

因為時間關係，**尚未支援**
1. 收到邀請的清單支援收合
2. 點擊搜尋框畫面上推

## 單元測試
1. 利用注入 mock model 的方式，驗證 LoginCoordinator 處理登入行為是否正確
2. 利用本地端json，驗證 FriendViewModel 收到不同的清單時，是否有正確處理

第一項是多做的，只是展示透過依賴注入進行單元測試的方式， 第二項是利用策略模式，注入不同的資料來源，來讓測資固定

## 系統流程

```
BankAppDemo/
│
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppCoordinator.swift
│
├── Core/
│   ├── Coordinator.swift
│   ├── NavigationCoordinator.swift
│   └── TabCoordinator.swift
│   └── DataSourceStrategy.swift
│
├── Coordinators/
│   ├── LoginCoordinator.swift
│   └── HomeCoordinator.swift
│   └── FriendsCoordinator.swift
│   └── MockCoordinator.swift
│   └── PaymentCoordinator.swift
│
├── ViewModels/
│   ├── LoginViewModel.swift
│   └── FriendsListViewModel.swift
│
├── Views/
│   ├── LoginViewController.swift
│   └── FriendsListViewController.swift
│   └── FriendCell.swift
│   └── InvitationCell.swift
│   └── PaymentViewController.swift
│   └── UIStackView+Extension.swift
│   └── UIButton+Extension.swift
│   └── UILabel+Extension.swift
│
├── Models/
│   └── User.swift
│   └── Friend.swift
│   └── UserSession.swift
│
├── Services/
│   ├── APIService.swift
│   └── friend1.json
│   └── friend2.json
│   └── friend3.json
│   └── friend4.json
│   └── man.json
│
└── Resources/
    └── Color+Additions.swift
    └── Assets.xcassets
    └── Info.plist
    └── BankAppDemo.xctestplan
    └── LaunchScreen.storyboard

BankAppDemoTests/
│
├── LoginCoordinatorTests.swift
├── FriendsViewModelTests.swift

```

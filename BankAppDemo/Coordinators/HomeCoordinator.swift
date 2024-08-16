//
//  HomeCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation
import UIKit

final class HomeCoordinator: TabCoordinator {
	override func setupSubscriptions() {
		print("開始取得使用者資訊")
	}

	override func start() {
		super.start()
		embeddedNavigationController.setViewControllers([embeddedTabBarController], animated: false)

		//        let moneyCoordinator = MoneyCoordinator(navigationController: UINavigationController())
		//        let friendsCoordinator = FriendsCoordinator(navigationController: UINavigationController())
		//        let paymentCoordinator = PaymentCoordinator(navigationController: UINavigationController())
		//        let accountingCoordinator = AccountingCoordinator(navigationController: UINavigationController())
		//        let settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController())

		//        embeddedTabBarController.viewControllers = [
		//            moneyCoordinator.navigationController,
		//            friendsCoordinator.navigationController,
		//            paymentCoordinator.navigationController,
		//            accountingCoordinator.navigationController,
		//            settingsCoordinator.navigationController
		//        ]
	}
}

/*


     override func start() {
         super.start()

         homeCoordinator = HomeCoordinator(userDataProvider: userDataProvider, transactionDataProvider: transactionDataProvider)
         homeCoordinator.delegate = self
         orderManagementCoordinator = OrderManagementCoordinator(userDataProvider: userDataProvider, transactionDataProvider: transactionDataProvider)
         feeCoordinator = FeeCoordinator(userDataProvider: userDataProvider, transactionDataProvider: transactionDataProvider)
         settingsCoordinator = SettingsCoordinator(userDataProvider: userDataProvider)
         settingsCoordinator.delegate = delegate

         // 建立標籤列元件，並綁訂到對應的頁面
         addTabBarItem(title: "首頁", iconImageName: "homePage", viewController: homeCoordinator)
         addTabBarItem(title: "訂單", iconImageName: "orderManagement", viewController: orderManagementCoordinator)
         addTabBarItem(title: "收款碼", iconImageName: "空圖片", viewController: UIViewController()) // 因為中央要用自訂按鈕，所以這邊等於是佔位
         addTabBarItem(title: "手續費", iconImageName: "handlingFee", viewController: feeCoordinator)
         addTabBarItem(title: "設定", iconImageName: "setting", viewController: settingsCoordinator)
         createCustomPaymentButton() // 建立中央下方的自訂按鈕(付款鈕)

         let tabBarAppearance = UITabBarAppearance()
         tabBarAppearance.configureWithDefaultBackground()
         tabBarAppearance.backgroundColor = .neutralWhite
         tabBarAppearance.shadowColor = .clear // 移除標籤列陰影底線
         embeddedTabBarController.tabBar.standardAppearance = tabBarAppearance
         embeddedTabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance

         // 設定標籤列陰影
         embeddedTabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
         embeddedTabBarController.tabBar.layer.shadowRadius = 32
         embeddedTabBarController.tabBar.layer.shadowColor = UIColor.lightInk006.cgColor
         embeddedTabBarController.tabBar.layer.shadowOpacity = 1

         embeddedTabBarController.delegate = self
         // embeddedTabBarController.tabBar.backgroundColor = .white // 設定標籤列的背景
         embeddedTabBarController.selectedIndex = 0 // 將首頁設為預設的啟動頁面
     }

     func addTabBarItem(title: String, iconImageName: String, viewController: UIViewController) {
         let image = UIImage(named: iconImageName)?.withRenderingMode(.alwaysOriginal) // 一般狀態圖片
         let selectedImage = UIImage(named: "\(iconImageName)_selected")?.withRenderingMode(.alwaysOriginal) // 創建一個自訂的選取圖片，命名規則為iconImageName＋_selected by Arthur
         let newTabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage) // 創建新的TabBarItem

         // 設定View Controller對應的TabBarItem，要有這個步驟，標籤列才會有對應的按鈕
         // 如果不指定自訂的項目，就會使用頁面的title屬性做為預設的標籤
         viewController.tabBarItem = newTabBarItem

         // 在現有的TabBar Controller中添加新的View Controller
         if let tabBarController = embeddedTabBarController {
             var viewControllers = tabBarController.viewControllers ?? []
             viewControllers.append(viewController) // 將傳入的頁面加入標籤列，要有這個步驟，才會將頁面跟標籤列產生關聯
             tabBarController.setViewControllers(viewControllers, animated: true) // 將傳入的頁面設為顯示的頁面
         }
     }

     // 客製化收款按鈕
     func createCustomPaymentButton() {
         // 自訂標籤文字
         let label = UILabel(frame: CGRect(x: 0, y: 0, width: 36, height: 17))
         label.text = "收款碼"
         label.font = EMFontStyle.pingFangMediumWithSize12.value
         label.textColor = .white
         // 設定標籤文字的位置
         label.center = CGPoint(x: embeddedTabBarController.tabBar.bounds.midX,
                                y: embeddedTabBarController.tabBar.bounds.midY + 15)

         // 自訂按鈕
         let customPaymentButton = UIButton(type: .custom)
         // 設定按鈕的圖片
         let image = UIImage(named: "qrcode_white_normal")
         customPaymentButton.setImage(image, for: .normal)
         customPaymentButton.adjustsImageWhenHighlighted = false // 點擊按鈕時圖片不要高亮
         customPaymentButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10)
         customPaymentButton.backgroundColor = .easyCardBlue
         // 將按鈕裁切成圓形
         customPaymentButton.clipsToBounds = true
         customPaymentButton.layer.cornerRadius = 36 // 元件長寬72，圓角半徑設為36，外觀就會變成圓形
         // 設定按鈕的尺寸與位置
         customPaymentButton.frame.size = CGSize(width: 72, height: 72)
         customPaymentButton.center = CGPoint(x: embeddedTabBarController.tabBar.bounds.midX,
                                              y: embeddedTabBarController.tabBar.bounds.midY)
         // 設定按鈕的行為，點了要出現付款頁面
         customPaymentButton.addTarget(self, action: #selector(didTapPaymentButton), for: .touchUpInside)

         // UI上此按鈕有一圈白色邊框
         customPaymentButton.layer.borderColor = UIColor.neutralWhite.cgColor
         customPaymentButton.layer.borderWidth = 5

         // 將自訂按鈕與標籤添加到標籤列上
         embeddedTabBarController.tabBar.addSubview(customPaymentButton)
         embeddedTabBarController.tabBar.addSubview(label)
     }

     // Handle payment button tap
     @objc func didTapPaymentButton() {
         // embeddedTabBarController.selectedIndex = 2
         store.send(.payment) // 通知store顯示首頁
     }

     // MARK: Private

     private var authProvider: AuthProvider
     private var userDataProvider: UserDataProvider
     private var transactionDataProvider: TransactionDataProvider // 交易資料提供者

     // Set up coordinators for each nav controller
     private var homeCoordinator: HomeCoordinator!
     private var orderManagementCoordinator: OrderManagementCoordinator!
     private var paymentCoordinator: PaymentCoordinator?
     private var feeCoordinator: FeeCoordinator!
     private var settingsCoordinator: SettingsCoordinator!
     private var agreementViewController: TWQRAgreementViewController?
 }

 // MARK: MainTabFlowDelegate

 extension MainTabFlowController: MainTabFlowDelegate {
     func switchToTab(tabIndex: Int) {
         guard canSwitchTab(previousDestination) else {
             print("Status is .twqrTerms, exiting...")
             return
         }
         // 判斷是否有被 present 的 view controller，如果有就將顯示的頁面關閉
         if presentedViewController != nil {
             dismiss(animated: false)
         }

         // 如果有導覽打開的頁面，就切回到首頁
         if let tabBarController = embeddedTabBarController { // 取得標籤管理器
             if let navigationController = tabBarController.selectedViewController as? NavigationCoordinator { // 取得標籤管理器顯示的頁面
                 navigationController.navigateToRoot(animated: false) // 將 NavigationController 的子視圖 pop 到 root
             }
         }

         if tabIndex >= 0, tabIndex < embeddedTabBarController.viewControllers?.count ?? 0 {
             embeddedTabBarController.selectedIndex = tabIndex // 切換到指定的頁面
         }
     }

     func switchToHome() {
         switchToTab(tabIndex: 0) // 切換到首頁標籤
     }

     func switchToOrders(merchantNumber: String? = nil, orderNumber: String? = nil) {
         if let merchantNumber {
             if let foundStore = userDataProvider.merchants.findStore(withID: merchantNumber) {
                 // 確保有特店編號
                 print("找到了特店：\(foundStore.name)")
                 userDataProvider.currentMerchant = foundStore // 更新userDataProvider中被選取的特店，讓管道更新所有訂閱
             } else {
                 // 沒有找到特店
                 print("找不到符合該ID的特店")
             }
         } else {
             // merchantNumber 是 nil 的情況
             print("特店編號是空值")
         }

         switchToTab(tabIndex: 1) // 切換到訂單標籤
         orderManagementCoordinator.switchToOrderList(orderNumber: orderNumber) // 切換到訂單列表，並根據是否有傳入訂單編號，決定是否載入訂單明細
     }

     func canSwitchTab(_ destination: Destination?) -> Bool {
         switch destination {
         case .twqrTerms:
             return false
         case .payment:
             dismiss { [weak self] in
                 guard let self else { return }
                 paymentCoordinator = nil
                 previousDestination = nil
             }
             return true
         case .none:
             return true
         }
     }
 }

 // MARK: UITabBarControllerDelegate

 extension MainTabFlowController: UITabBarControllerDelegate {
     func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
         // 因為第三個標籤是自訂按鈕，所以禁用原本的標籤
         let index = tabBarController.viewControllers?.firstIndex(of: viewController) // 取得目前點擊標籤所對應的索引
         if index == 2 {
             return false // 禁用標籤選擇
         }

         // 檢查權限，如果是手續費就要檢查使用者權限
         let currentPermissionLevel = userDataProvider.currentPermissionLevel
         // print("切換到標籤頁: \(viewController.className), 使用者權限：\(currentPermissionLevel)")
         if viewController is FeeCoordinator && // 如果要切換的頁面是手續費
             currentPermissionLevel == .clerk {
             // 權限不足，拒絕切換
             警告視窗.權限不足.present()
             return false
         } else {
             // 權限符合，允許切換
             return true
         }
     }
 }

 // MARK: PaymentFlowDelegate

 extension MainTabFlowController: PaymentFlowDelegate {
     func loadTermsStatus() {
         store.send(.twqrTermsFeature(.loadTermsStatus))
     }

     func showTWQRTermsAndConditions() {
         guard let selectedStore = userDataProvider.currentMerchant else { return }
         if let store = store.scope(state: \.destination?.twqrTerms, action: \.destination.twqrTerms) {
             store.send(.setMerchantInfo(merchant: selectedStore))
             print("顯示TWQR條約視窗")
             agreementViewController = TWQRAgreementViewController(store: store)
             present(agreementViewController!)
         }
     }

     func showPaymentCode() {
         guard let selectedStore = userDataProvider.currentMerchant else { return }
         if let store = store.scope(state: \.destination?.payment, action: \.destination.payment) {
             store.send(.setMerchantInfo(merchant: selectedStore))
             print("顯示支付碼視窗")
             paymentCoordinator = PaymentCoordinator(
                 userDataProvider: userDataProvider,
                 store: store
             )
             paymentCoordinator?.delegate = self
             present(paymentCoordinator!)
         }
     }
 }
  */

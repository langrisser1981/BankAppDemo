// AppDelegate.swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator?.start()
        return true
    }
}

// AppCoordinator.swift
import UIKit

class AppCoordinator: Coordinator {
    let window: UIWindow
    var childCoordinators = [Coordinator]()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let loginCoordinator = LoginCoordinator(window: window)
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
}

// LoginCoordinator.swift
import UIKit

class LoginCoordinator: Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let loginVC = LoginViewController()
        let loginVM = LoginViewModel()
        loginVC.viewModel = loginVM
        loginVM.didLogin = { [weak self] in
            self?.showHome()
        }
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
    }
    
    func showHome() {
        let homeCoordinator = HomeCoordinator(window: window)
        homeCoordinator.start()
    }
}

// HomeCoordinator.swift
import UIKit

class HomeCoordinator: Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let friendsListVC = FriendsListViewController()
        let friendsListVM = FriendsListViewModel()
        friendsListVC.viewModel = friendsListVM
        window.rootViewController = UINavigationController(rootViewController: friendsListVC)
    }
}

// LoginViewModel.swift
import Foundation

class LoginViewModel {
    var didLogin: (() -> Void)?
    private let authService = AuthenticationService()
    
    func login(username: String, password: String) {
        authService.login(username: username, password: password) { [weak self] success in
            if success {
                self?.didLogin?()
            }
        }
    }
}

// FriendsListViewModel.swift
import Foundation

class FriendsListViewModel {
    private let friendsService = FriendsService()
    var friends: [Friend] = []
    
    func fetchFriends(completion: @escaping () -> Void) {
        friendsService.getFriends { [weak self] friends in
            self?.friends = friends
            completion()
        }
    }
}

// LoginViewController.swift
import UIKit

class LoginViewController: UIViewController {
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI
    }
    
    @objc func loginButtonTapped() {
        // Assume we have username and password from text fields
        viewModel.login(username: "user", password: "pass")
    }
}

// FriendsListViewController.swift
import UIKit

class FriendsListViewController: UIViewController {
    var viewModel: FriendsListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI
        loadFriends()
    }
    
    func loadFriends() {
        viewModel.fetchFriends { [weak self] in
            // Reload table view
        }
    }
}

// Friend.swift
struct Friend: Codable {
    let id: String
    let name: String
}

// AuthenticationService.swift
import Foundation

class AuthenticationService {
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        // Simulated login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
}

// FriendsService.swift
import Foundation

class FriendsService {
    func getFriends(completion: @escaping ([Friend]) -> Void) {
        // Simulated friends fetch
        let friends = [
            Friend(id: "1", name: "Alice"),
            Friend(id: "2", name: "Bob"),
            Friend(id: "3", name: "Charlie")
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(friends)
        }
    }
}

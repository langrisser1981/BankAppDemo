import UIKit

enum FriendsSectionType: Int, CaseIterable {
    case quickActions
    case personalInfo
    case pendingInvitations
    case functionTabs
    case searchBar
    case friendsList
}

class FriendsViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<FriendsSectionType, AnyHashable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        applyInitialSnapshots()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        collectionView.register(QuickActionsCell.self, forCellWithReuseIdentifier: "QuickActionsCell")
        collectionView.register(PersonalInfoCell.self, forCellWithReuseIdentifier: "PersonalInfoCell")
        collectionView.register(PendingInvitationsCell.self, forCellWithReuseIdentifier: "PendingInvitationsCell")
        collectionView.register(FunctionTabsCell.self, forCellWithReuseIdentifier: "FunctionTabsCell")
        collectionView.register(SearchBarCell.self, forCellWithReuseIdentifier: "SearchBarCell")
        collectionView.register(FriendCell.self, forCellWithReuseIdentifier: "FriendCell")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionType = FriendsSectionType(rawValue: sectionIndex)!
            
            switch sectionType {
            case .quickActions:
                return self.createQuickActionsSection()
            case .personalInfo:
                return self.createPersonalInfoSection()
            case .pendingInvitations:
                return self.createPendingInvitationsSection()
            case .functionTabs:
                return self.createFunctionTabsSection()
            case .searchBar:
                return self.createSearchBarSection()
            case .friendsList:
                return self.createFriendsListSection()
            }
        }
        
        return layout
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<FriendsSectionType, AnyHashable>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let sectionType = FriendsSectionType(rawValue: indexPath.section)!
            
            switch sectionType {
            case .quickActions:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickActionsCell", for: indexPath) as! QuickActionsCell
                // Configure cell
                return cell
            case .personalInfo:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonalInfoCell", for: indexPath) as! PersonalInfoCell
                // Configure cell
                return cell
            case .pendingInvitations:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PendingInvitationsCell", for: indexPath) as! PendingInvitationsCell
                // Configure cell
                return cell
            case .functionTabs:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FunctionTabsCell", for: indexPath) as! FunctionTabsCell
                // Configure cell
                return cell
            case .searchBar:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchBarCell", for: indexPath) as! SearchBarCell
                // Configure cell
                return cell
            case .friendsList:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
                // Configure cell with friend data
                return cell
            }
        }
    }
    
    private func applyInitialSnapshots() {
        var snapshot = NSDiffableDataSourceSnapshot<FriendsSectionType, AnyHashable>()
        
        snapshot.appendSections(FriendsSectionType.allCases)
        
        // Add items to each section as needed
        snapshot.appendItems([QuickActionsItem()], toSection: .quickActions)
        snapshot.appendItems([PersonalInfoItem()], toSection: .personalInfo)
        snapshot.appendItems([PendingInvitationsItem()], toSection: .pendingInvitations)
        snapshot.appendItems([FunctionTabsItem()], toSection: .functionTabs)
        snapshot.appendItems([SearchBarItem()], toSection: .searchBar)
        
        // Add friend items to the friends list section
        let friends = [Friend(id: "1", name: "Alice"), Friend(id: "2", name: "Bob")]
        snapshot.appendItems(friends, toSection: .friendsList)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Section Layouts
    
    private func createQuickActionsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createPersonalInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createPendingInvitationsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createFunctionTabsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createSearchBarSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createFriendsListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}

// MARK: - Model Classes

struct QuickActionsItem: Hashable {}
struct PersonalInfoItem: Hashable {}
struct PendingInvitationsItem: Hashable {}
struct FunctionTabsItem: Hashable {}
struct SearchBarItem: Hashable {}
struct Friend: Hashable {
    let id: String
    let name: String
}

// MARK: - Custom Cells

class QuickActionsCell: UICollectionViewCell {
    // Implement cell with quick action buttons
}

class PersonalInfoCell: UICollectionViewCell {
    // Implement cell with personal info and avatar
}

class PendingInvitationsCell: UICollectionViewCell {
    // Implement cell with pending invitations list (collapsible)
}

class FunctionTabsCell: UICollectionViewCell {
    // Implement cell with function tabs (Friends and Chat)
}

class SearchBarCell: UICollectionViewCell {
    // Implement cell with search bar
}

class FriendCell: UICollectionViewCell {
    // Implement cell for individual friend in the list
}

// MARK: - Tab Bar Controller Setup

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moneyVC = UIViewController()
        moneyVC.tabBarItem = UITabBarItem(title: "錢錢", image: UIImage(systemName: "dollarsign.circle"), tag: 0)
        
        let friendsVC = FriendsViewController()
        friendsVC.tabBarItem = UITabBarItem(title: "朋友", image: UIImage(systemName: "person.2"), tag: 1)
        
        let paymentVC = UIViewController()
        paymentVC.tabBarItem = UITabBarItem(title: "支付", image: UIImage(systemName: "creditcard"), tag: 2)
        
        let accountingVC = UIViewController()
        accountingVC.tabBarItem = UITabBarItem(title: "記帳", image: UIImage(systemName: "book"), tag: 3)
        
        let settingsVC = UIViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "設定", image: UIImage(systemName: "gear"), tag: 4)
        
        viewControllers = [moneyVC, friendsVC, paymentVC, accountingVC, settingsVC]
        
        selectedIndex = 1 // Set Friends tab as default
        
        // Customize the middle tab bar item (Payment)
        if let items = tabBar.items {
            let paymentItem = items[2]
            paymentItem.image = UIImage(systemName: "creditcard.circle.fill")?.withRenderingMode(.alwaysOriginal)
            paymentItem.imageInsets = UIEdgeInsets(top: -15, left: 0, bottom: 15, right: 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust the frame of the middle tab bar item to make it larger
        if let items = tabBar.items {
            let paymentItem = items[2]
            if let view = paymentItem.value(forKey: "view") as? UIView {
                view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - 15, width: view.frame.size.width, height: view.frame.size.height + 15)
            }
        }
    }
}

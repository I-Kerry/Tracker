
import UIKit

final class TabBarViewController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = .ypBlue
        self.tabBar.unselectedItemTintColor = .ypGray
        
        let trackerVC = TrackerViewController()
        let trackerNav = UINavigationController(rootViewController: trackerVC)
        let statisticsVC = StatisticsViewController()
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        trackerVC.tabBarItem = UITabBarItem(title: String(localized: .trackers),
                                            image: UIImage(named: "trackerIcon"),
                                            selectedImage: UIImage(named: "trackerIcon")
        )
        
        statisticsVC.tabBarItem = UITabBarItem(title: String(localized: .stats),
                                               image: UIImage(named: "statisticsIcon"),
                                               selectedImage: UIImage(named: "statisticsIcon")
        )
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.gray.cgColor
        
        self.viewControllers = [trackerNav, statisticsNav]
    }
}

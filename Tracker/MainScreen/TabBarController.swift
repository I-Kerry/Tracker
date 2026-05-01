
import UIKit

final class TabBarViewController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = .ypBlue
        self.tabBar.unselectedItemTintColor = .ypGray
        
        let trackerVC = TrackerViewController()
        let trackerNav = UINavigationController(rootViewController: trackerVC)
        let statisticsVC = StatisticsViewController()
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры",
                                            image: UIImage(named: "trackerIcon"),
                                            selectedImage: UIImage(named: "trackerIcon")
        )
        
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика",
                                               image: UIImage(named: "statisticsIcon"),
                                               selectedImage: UIImage(named: "statisticsIcon")
        )
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.gray.cgColor
        
        self.viewControllers = [trackerNav, statisticsNav]
    }
}

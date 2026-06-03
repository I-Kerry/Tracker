
import UIKit

final class CreateTrackerViewController: UIViewController {
    
    weak var delegateHabit: HabitViewDelegate?
    
    weak var delegateIrregular: IrregularViewControllerDelegate?
    
    private var colors = Colors()
    
    private let habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitle(String(localized: .habit), for: .normal)
        button.setTitleColor(.blackNight, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let irregularButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitle(String(localized: .irregularEvent), for: .normal)
        button.setTitleColor(.blackNight, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        habitButton.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        irregularButton.addTarget(self, action: #selector(didTapIrregularButton), for: .touchUpInside)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        setupUI()
        setupConstraints()
        setupTitle()
    }
    
    private func setupUI() {
        view.addSubview(habitButton)
        view.addSubview(irregularButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            irregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapHabitButton() {
        let habitVC = HabitView()
        let navHabitVC = UINavigationController(rootViewController: habitVC)
        habitVC.delegate = delegateHabit
        present(navHabitVC, animated: true)
    }
    
    @objc private func didTapIrregularButton() {
        let irregularVC = IrregularViewController()
        let navIrregularVC = UINavigationController(rootViewController: irregularVC)
        irregularVC.delegate = delegateIrregular
        present(navIrregularVC, animated: true)
    }
    
    private func setupTitle() {
        navigationItem.title = String(localized: .creatingTracker)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackDay
        ]
    }
}

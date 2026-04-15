
import UIKit

final class CreateTrackerViewController: UIViewController {
    
    weak var delegateHabit: HabitViewDelegate?
    
    weak var delegateIrregular: IrregularViewControllerDelegate?
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .blackDay
        titleLabel.text = "Создание трекера"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let irregularButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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
}

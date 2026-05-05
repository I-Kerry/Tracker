
import UIKit

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var numberValue: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
    
    var shortNames: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ weekday: [Weekday])
}

final class ScheduleViewController: UIViewController {
    private var selectedDays: [Weekday] = []
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.rowHeight = 75
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        navigationItem.backBarButtonItem = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstrains()
        setupTitle()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(button)
        view.backgroundColor = .white
        tableView.backgroundColor = .white
    }
    
    private func setupConstrains() {
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTitle() {
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackDay
        ]
    }
    
    @objc private func didTapDone() {
        delegate?.didSelectDays(selectedDays)
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate {
    
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = Weekday.allCases[indexPath.row].rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.textLabel?.textColor = .blackDay
        cell.backgroundColor = .backgroundDay
        
        let switchView = UISwitch()
        switchView.isOn = false
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        cell.accessoryView = switchView
        switchView.isOn = selectedDays.contains(Weekday.allCases[indexPath.row])
        return cell
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        let weekday = Weekday.allCases[sender.tag]
        if sender.isOn {
            selectedDays.append(weekday)
        } else {
            selectedDays.removeAll {$0 == weekday}
        }
    }
}

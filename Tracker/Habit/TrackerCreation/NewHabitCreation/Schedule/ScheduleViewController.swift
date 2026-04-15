
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
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ weekday: [Weekday])
}

final class ScheduleViewController: UIViewController {
    private var selectedDays: [Weekday] = []
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .blackDay
        titleLabel.text = "Расписание"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
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
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        button.addTarget(self, action: #selector(didTapDOne), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstrains()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(button)
    }
    
    private func setupConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapDOne() {
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

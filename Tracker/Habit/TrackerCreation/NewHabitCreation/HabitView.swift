
import UIKit

protocol HabitViewDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}

final class HabitView: UIViewController {
    
    weak var delegate: HabitViewDelegate?
    
    private var selectedDays: [Weekday] = []
    
    private var items: [String] = [
        "Категория",
        "Расписание"
    ]
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .blackDay
        titleLabel.text = "Новая привычка"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private var searchBar: UITextField = {
        let searchBar = UITextField()
        searchBar.borderStyle = .roundedRect
        searchBar.placeholder = "Введите название трекера"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(HabitViewCell.self, forCellReuseIdentifier: HabitViewCell.reuseIdentifier)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.backgroundColor = .white
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = UIColor(resource: .red).cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private let createButton: UIButton = {
        let createButton = UIButton()
        createButton.backgroundColor = .ypGray
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        return createButton
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        
        createButton.addTarget(self, action: #selector(tapCreateButton), for: .touchUpInside)
        
        searchBar.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        setupConstraints()
        setupUIGesture()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(stack)
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func tapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc func tapCreateButton() {
        guard let trackerName = searchBar.text,
              !trackerName.isEmpty else { return }
        let tracker = Tracker(id: UUID(),
                              name: trackerName,
                              color: UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1),
                              emoji: "",
                              schedule: selectedDays)
        delegate?.didCreateTracker(tracker, category: "Общее")
        view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc func textChanged() {
        createButton.isEnabled = !(searchBar.text?.isEmpty ?? true)
        createButton.backgroundColor = createButton.isEnabled ? .blackDay : .ypGray
    }
    
    private func setupUIGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension HabitView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitViewCell.reuseIdentifier, for: indexPath) as! HabitViewCell
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cell.textLabel?.textColor = .blackDay
        cell.backgroundColor = .backgroundDay
        return cell
    }
}

extension HabitView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationVC: UIViewController
        
        switch indexPath.row {
        case 0:
            destinationVC = CategoryViewController()
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            destinationVC = scheduleVC
        default:
            return
        }
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension HabitView: ScheduleViewControllerDelegate {
    func didSelectDays(_ weekday: [Weekday]) {
        self.selectedDays = weekday
        print("выбранные дни: \(weekday.map { $0.rawValue })")
    }
}

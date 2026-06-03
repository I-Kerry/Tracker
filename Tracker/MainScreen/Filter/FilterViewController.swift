

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterChosen(filter: TrackerFilter)
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilter: TrackerFilter?
    private var colors = Colors()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FilterViewCell.self, forCellReuseIdentifier: FilterViewCell.reuseIdentifier)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        view.addSubview(tableView)
        setupConstraints()
        setupTitle()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(TrackerFilter.allCases.count) * 75)
        ])
    }
    
    private func setupTitle() {
        navigationItem.title = String(localized: .filters)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackDay
        ]
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.delegate?.filterChosen(filter: TrackerFilter.allCases[indexPath.row])
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterViewCell.reuseIdentifier, for: indexPath) as? FilterViewCell else {
            return UITableViewCell()
        }
        cell.configure(text: TrackerFilter.allCases[indexPath.row].localized)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.textLabel?.textColor = .blackDay
        cell.backgroundColor = .backgroundDay
        let filter = TrackerFilter.allCases[indexPath.row]
        let isResetFilter = filter == .allTrackers || filter == .todayTrackers
        cell.accessoryType = (!isResetFilter && filter == selectedFilter) ? .checkmark : .none
        
        return cell
    }
}

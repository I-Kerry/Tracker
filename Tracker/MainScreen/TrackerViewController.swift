
import UIKit

final class TrackerViewController: UIViewController, TrackerViewCellDelegate {
    
    private var titleLabel: UILabel!
    private var searchField: UISearchBar!
    private var filterButton: UIButton!
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let colors = Colors()
    
    private var visibleCategories: [TrackerCategory] = []
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentFilter: TrackerFilter {
        get { TrackerFilter(rawValue: UserDefaultsService.shared.isActiveFilterOn) ?? .allTrackers }
        set { UserDefaultsService.shared.isActiveFilterOn = newValue.rawValue }
    }
    
    let datepicker = UIDatePicker()
    private var currentDate: Date = Date()
    private let trackerList: [String] = []
    
    private let cellIdentifier = "cell"
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var placeholder: UIView = {
        let view = UIView()
        view.backgroundColor = colors.viewBackgroundColor
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(resource: .noStatsFound))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = String(localized: .whatTracking)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
                
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        view.backgroundColor = .clear

        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colors.viewBackgroundColor
        
        setupUI()
        setupConstraints()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        trackerStore.delegate = self
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        
        categories = trackerCategoryStore.fetchCategories()
        reloadVisibleCategories()
        
        updatePlaceholder()
        setupUIGesture()
        
        completedTrackers = (try? trackerRecordStore.fetchAllRecords()) ?? []
        self.currentFilter = .allTrackers
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        categories = trackerCategoryStore.fetchCategories()
        reloadVisibleCategories()
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: "open", screen: "Main", item: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: "close", screen: "Main", item: nil)
    }

    
    //MARK: funcs
    
    private func setupUI() {
        setupAddTrackerButton()
        setupTitle()
        setupSearchBar()
        setupDate()
        setupPlaceholder()
        setupCollectionView()
        setupButton()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    }
    
    private func setupAddTrackerButton() {
        let button = UIBarButtonItem(image: UIImage(named: "addTracker"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(tapAddTrackerButton))
        button.tintColor = .blackDay
        navigationItem.leftBarButtonItem = button
    }
    
    @objc private func tapAddTrackerButton() {
        
        let createTrackerVC = CreateTrackerViewController()
        let navCreateTrackerVC = UINavigationController(rootViewController: createTrackerVC)
        createTrackerVC.delegateIrregular = self
        createTrackerVC.delegateHabit = self
        present(navCreateTrackerVC, animated: true)
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "add_track")
    }
    
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = String(localized: .trackers)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .blackDay
    }
    
    private func setupSearchBar() {
        searchField = UISearchBar()
        searchField.placeholder = String(localized: .search)
        searchField.showsCancelButton = false
        searchField.searchBarStyle = .minimal
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.delegate = self
        searchField.searchTextField.backgroundColor = UIColor(red: 118/255.0, green: 118/255.0, blue: 128/255.0, alpha: 0.12)
        view.addSubview(searchField)
    }
    
    private func setupButton() {
        filterButton = UIButton()
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .ypBlue
        filterButton.setTitle(String(localized: .filters), for: .normal)
        filterButton.layer.masksToBounds = true
        filterButton.layer.cornerRadius = 16
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.addTarget(self, action: #selector(tapFilterButton), for: .touchUpInside)
    }
    
    @objc func tapFilterButton() {
        let filterVC = FilterViewController(selectedFilter: currentFilter)
        filterVC.delegate = self
        let navVC = UINavigationController(rootViewController: filterVC)
        present(navVC, animated: true)
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "filter")
    }
    
    private func setupDate() {
        datepicker.preferredDatePickerStyle = .compact
        datepicker.datePickerMode = .date
        datepicker.locale = Locale(identifier: "ru_RU")
        let datePickerItem = UIBarButtonItem(customView: datepicker)
        datepicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = datePickerItem
        datepicker.translatesAutoresizingMaskIntoConstraints = false
        datepicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        datepicker.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    @objc func datePickerValueChanged() {
        currentDate = datepicker.date
        reloadVisibleCategories()
        collectionView.reloadData()
        updatePlaceholder()
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekend = calendar.component(.weekday, from: datepicker.date)
        let filterText = (searchField.text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            let trackerFilter = category.trackerArray.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.isEmpty || tracker.schedule.contains { weekday in
                    weekday.numberValue == filterWeekend
                } == true
                
                let filterCondition: Bool
                
                switch currentFilter {
                case .allTrackers:
                    filterCondition = true
                case .finishedTrackers:
                    filterCondition = completedTrackers.contains {
                        $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }
                case .todayTrackers:
                    filterCondition = true
                case .unfinishedTrackers:
                    filterCondition = !completedTrackers.contains {
                        $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }
                }
                
                return filterCondition && textCondition && dateCondition
            }
            
            return trackerFilter.isEmpty ? nil : TrackerCategory(
                header: category.header,
                trackerArray: trackerFilter)
        }
        collectionView.reloadData()
    }
    
    private func setupPlaceholder() {
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)
    }
    
    private func updatePlaceholder() {
        placeholder.isHidden = !visibleCategories.isEmpty
        collectionView.isHidden = visibleCategories.isEmpty
        filterButton.isHidden = visibleCategories.isEmpty
        let isFilterActive = currentFilter == .finishedTrackers || currentFilter == .unfinishedTrackers
        filterButton.setTitleColor(isFilterActive ? .red : .white , for: .normal)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    func didTapButton(in cell: TrackerViewCell) {
        guard let tracker = cell.tracker else { return }
        let record = TrackerRecord(id: UUID(), trackerId: tracker.id, date: currentDate)
        
        if currentDate > Date() {
            return
        }
        
        if let index = completedTrackers.firstIndex(where: {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.removeTrackerRecord(trackerID: record.trackerId, trackerDate: record.date)
        } else {
            completedTrackers.append(record)
            try? trackerRecordStore.addNewTrackerRecord(record)
        }
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.reloadItems(at: [indexPath])
        }
        visibleCategories = trackerCategoryStore.fetchCategories()
        reloadVisibleCategories()
        updatePlaceholder()
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "track")
    }
    
    private func setupUIGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showDeleteAlert(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: String(localized: .confirmDeletingTracker),
            message: nil,
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: String(localized: .delete), style: .destructive) { [weak self] _ in
            guard let self else { return }
            try? self.trackerStore.deleteTracker(tracker)
            AnalyticsService.shared.report(event: "click", screen: "Main", item: "delete")
        })
        
        alert.addAction(UIAlertAction(title: String(localized: .cancel), style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: UISearchBarDelegate

extension TrackerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadVisibleCategories()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        reloadVisibleCategories()
        searchBar.resignFirstResponder()
    }
}

// MARK: UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerViewCell
        cell?.delegate = self
        let tracker = visibleCategories[indexPath.section].trackerArray[indexPath.row]
        cell?.tracker = tracker
        let isCompleted = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        cell?.configure(with: tracker, isCompleted: isCompleted)
        
        let completedTrackers = completedTrackers.filter { $0.trackerId == tracker.id}.count
        
        cell?.dayLabel.text = String(localized: .daysCount(completedTrackers))
        cell?.dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return cell ?? UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        view.titleLabel.text = visibleCategories[indexPath.section].header
        view.titleLabel.textAlignment = .left
        return view
    }
}

//MARK: UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
}

//MARK: Delegates

extension TrackerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let edit = UIAction(title: String(localized: .edit)) { [weak self] _ in
            guard let self else { return }
            AnalyticsService.shared.report(event: "click", screen: "Main", item: "edit")
            let habitVC = HabitView()
            habitVC.editingTracker = self.visibleCategories[indexPath.section].trackerArray[indexPath.row]
            self.navigationController?.pushViewController(habitVC, animated: true)
            collectionView.reloadData()
        }
        
        let tracker = visibleCategories[indexPath.section].trackerArray[indexPath.row]
        let delete = UIAction(title: String(localized: .delete), handler: { [weak self] _ in
            guard let self else { return }
            self.showDeleteAlert(tracker)
            collectionView.reloadData()
        })
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

extension TrackerViewController: HabitViewDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        if let index = categories.firstIndex(where: {
            $0.header == category }) {
            let updatedCategory = TrackerCategory(header: categories[index].header,
                                                  trackerArray: categories[index].trackerArray + [tracker])
            categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(header: category, trackerArray: [tracker])
            categories.append(newCategory)
        }
        try? trackerStore.addNewTracker(tracker, with: category)
        
        reloadVisibleCategories()
        updatePlaceholder()
        presentingViewController?.dismiss(animated: true)
        collectionView.reloadData()
    }
}

extension TrackerViewController: IrregularViewControllerDelegate {
    func didCreateIrregularTracker(_ tracker: Tracker, category: String) {
        if let index = categories.firstIndex(where: {
            $0.header == category }) {
            let updatedCategory = TrackerCategory(header: categories[index].header, trackerArray: categories[index].trackerArray + [tracker])
            categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(header: category, trackerArray: [tracker])
            categories.append(newCategory)
        }
        try? trackerStore.addNewTracker(tracker, with: category)
        
        reloadVisibleCategories()
        updatePlaceholder()
        dismiss(animated: true)
        collectionView.reloadData()
    }
}

extension TrackerViewController: FilterViewControllerDelegate {
    func filterChosen(filter: TrackerFilter) {
        currentFilter = filter
        if filter == .todayTrackers {
            datepicker.date = Date()
            currentDate = Date()
        }
        print(visibleCategories)
        reloadVisibleCategories()
        print(visibleCategories)
        updatePlaceholder()
        dismiss(animated: true)
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrakerStore(_ update: TrackerStoreUpdate) {
        visibleCategories = trackerCategoryStore.fetchCategories()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCategoryStoreDelegate {
    func didUpdateTrackerCategory(_ update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.fetchCategories()
        reloadVisibleCategories()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func didUpdateRecordStore(_ update: TrackerRecordStoreUpdate) {
        visibleCategories = trackerCategoryStore.fetchCategories()
        collectionView.reloadData()
    }
}


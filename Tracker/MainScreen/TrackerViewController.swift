
import UIKit

final class TrackerViewController: UIViewController, TrackerViewCellDelegate {
    
    private var titleLabel: UILabel!
    private var searchField: UISearchBar!
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var visibleCategories: [TrackerCategory] = []
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
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
        view.backgroundColor = .white
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(named: "noTrackers"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        trackerStore.delegate = self
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        
        categories = trackerCategoryStore.fetchCategories()
        visibleCategories = categories
        
        setupUI()
        setupConstraints()
        updatePlaceholder()
        setupUIGesture()
    }
    
    private func setupUI() {
        setupAddTrackerButton()
        setupTitle()
        setupSearchBar()
        setupDate()
        setupPlaceholder()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
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
    }
    
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .black
    }
    
    private func setupSearchBar() {
        searchField = UISearchBar()
        searchField.placeholder = "Поиск"
        searchField.showsCancelButton = false
        searchField.searchBarStyle = .minimal
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.delegate = self
        searchField.searchTextField.backgroundColor = UIColor(red: 118/255.0, green: 118/255.0, blue: 128/255.0, alpha: 0.12)
        view.addSubview(searchField)
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
                
                return filterText.isEmpty ? (textCondition && dateCondition) : textCondition
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
            placeholder.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
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
//            let record = TrackerRecord(id: UUID(), trackerId: tracker.id, date: currentDate)
            completedTrackers.append(record)
            try? trackerRecordStore.addNewTrackerRecord(record)
        }
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.reloadItems(at: [indexPath])
        }
        updatePlaceholder()
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

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrakerStore(_ update: TrackerStoreUpdate) {
//        visibleCategories = trackerCategoryStore.fetchCategories()
//        collectionView.performBatchUpdates({
//            let insertedIndexes = update.insertedIndexes.map { IndexPath(item: $0, section: 0)}
//            let deletedIndexes = update.deletedIndexes.map { IndexPath(item: $0, section: 0)}
//            collectionView.insertItems(at: insertedIndexes)
//            collectionView.deleteItems(at: deletedIndexes)
//        })
        visibleCategories = trackerCategoryStore.fetchCategories()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCategoryStoreDelegate {
    func didUpdateTrackerCategory(_ update: TrackerCategoryStoreUpdate) {
//        collectionView.performBatchUpdates({
//            update.insertedIndexes.forEach({
//                collectionView.insertSections(IndexSet(integer: $0))
//            })
//            update.deletedIndexes.forEach({
//                collectionView.deleteSections(IndexSet(integer: $0))
//            })
//        }, completion: { _ in
//            self.visibleCategories = self.trackerCategoryStore.fetchCategories()
//        })
        visibleCategories = trackerCategoryStore.fetchCategories()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func didUpdateRecordStore(_ update: TrackerRecordStoreUpdate) {
        visibleCategories = trackerCategoryStore.fetchCategories()
        collectionView.reloadData()
//        collectionView.performBatchUpdates({
//            for index in update.insertedIndexes {
//                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
//            }
//            for index in update.deletedIndexes {
//                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
//            }
//        })
    }
}

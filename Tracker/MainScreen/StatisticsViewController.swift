
import UIKit

final class StatisticsViewController: UIViewController {
    
    private var statistics: [StatisticsType] = StatisticsType.allCases
    private var trackerRecordStore = TrackerRecordStore()
    private var colors = Colors()
    private var recordsCount: Int = 0
    private var trackerCategoryStore = TrackerCategoryStore()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: .stats)
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholder: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(resource: .noStatsFound))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = String(localized: .nothingAnalize)
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
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = colors.viewBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        updatePlaceholder()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updateData()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(placeholder)
        collectionView.register(StatisticsViewCell.self, forCellWithReuseIdentifier: StatisticsViewCell.reuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 4 * 90 + 3 * 12)
        ])
    }
    
    private func updatePlaceholder() {
        placeholder.isHidden = recordsCount != 0
        collectionView.isHidden = recordsCount == 0
    }
    
    private func updateData() {
        guard let count = try? trackerRecordStore.fetchAllRecords().count else { return }
        recordsCount = count
        updatePlaceholder()
        collectionView.reloadData()
    }
    
    private func calculateAverage() -> Int {
        let records = (try? trackerRecordStore.fetchAllRecords()) ?? []
        let uniqueDays = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        let average = uniqueDays.isEmpty ? 0 : records.count / uniqueDays.count
        return average
    }
    
    private func calculateBestPeriod() -> Int {
        let records = (try? trackerRecordStore.fetchAllRecords()) ?? []
        let grouped = Dictionary(grouping: records) { $0.trackerId }
        var bestPeriod = 0
        
        for (_, trackerRecords) in grouped {
            let sortedDates = trackerRecords.map { Calendar.current.startOfDay(for: $0.date)}.sorted()
            
            var currentStreak = 1
            var maxStreak = 1
            
            for i in 1..<sortedDates.count {
                let diff = Calendar.current.dateComponents([.day], from: sortedDates[i - 1], to: sortedDates[i]).day ?? 0
                if diff == 1 {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else {
                    currentStreak = 1
                }
            }
            bestPeriod = max(bestPeriod, maxStreak)
        }
        return bestPeriod
    }
    
    private func calculateIdealDay() -> Int {
        let records = (try? trackerRecordStore.fetchAllRecords()) ?? []
        let grouped = Dictionary(grouping: records) { $0.date }
        
        var idealDay = 0
        
        for (date, trackerRecords) in grouped {
            let completedCount = trackerRecords.count
            let weekday = Calendar.current.component(.weekday, from: date)
            let trackers = trackerCategoryStore.fetchCategories()
            let allTrackers = trackers.flatMap { $0.trackerArray }
            let plannedTrackers = allTrackers.filter { tracker in
                tracker.schedule.contains { $0.numberValue == weekday }
            }.count
            if completedCount == plannedTrackers && plannedTrackers > 0 {
                idealDay += 1
            }
        }
        return idealDay
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 90)
    }
}

extension StatisticsViewController: UICollectionViewDelegate {
    
}

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StatisticsType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticsViewCell.reuseIdentifier, for: indexPath) as? StatisticsViewCell else { return UICollectionViewCell() }
        let statisticsType = statistics[indexPath.item]

        let number: Int
        switch statisticsType {
        case .averageValue:
            number = calculateAverage()
        case .bestPeriod:
            number = calculateBestPeriod()
        case .completedTrackers:
            number = recordsCount
        case .idealDays:
            number = calculateIdealDay()
        }
        cell.configure(number: number, type: statisticsType)
        return cell
    }
}

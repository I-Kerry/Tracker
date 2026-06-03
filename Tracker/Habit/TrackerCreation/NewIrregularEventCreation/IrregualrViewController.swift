
import UIKit

protocol IrregularViewControllerDelegate: AnyObject {
    func didCreateIrregularTracker(_ tracker: Tracker, category: String)
}

final class IrregularViewController: UIViewController {
    
    private var items: [String] = [
        String(localized: .category)
    ]
    
    weak var delegate: IrregularViewControllerDelegate?
    
    private let emojiCollection = EmojiCollectionView()
    private let colorCollection = ColorCollectionView()
    private var selectedEmoji: String?
    private var selectedCategory: String?
    
    private var selectedColor: UIColor?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let colors = Colors()
    
    private var tableViewTopConstraint: NSLayoutConstraint?
     
    private var searchBar: UITextField = {
        let searchBar = UITextField()
        searchBar.borderStyle = .roundedRect
        searchBar.placeholder = String(localized: .enterTrackerName)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.clearButtonMode = .whileEditing
        searchBar.backgroundColor = .backgroundDay
        return searchBar
    }()
    
    private let limitLabel: UILabel = {
        let limitLabel = UILabel()
        limitLabel.text = String(localized: .charLimit)
        limitLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        limitLabel.textColor = .red
        limitLabel.isHidden = true
        limitLabel.textAlignment = .center
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        return limitLabel
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(IrregularViewCell.self, forCellReuseIdentifier: IrregularViewCell.reuseIdentifier)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.backgroundColor = .white
        cancelButton.setTitle(String(localized: .cancel), for: .normal)
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
        createButton.setTitle(String(localized: .create), for: .normal)
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupUIGesture()
        setupTitle()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        emojiCollection.delegate = self
        colorCollection.delegate = self
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(searchBar)
        contentView.addSubview(limitLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(stack)
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiCollection)
        contentView.addSubview(colorCollection)
        
        view.backgroundColor = colors.viewBackgroundColor
        scrollView.backgroundColor = .blackNight
        contentView.backgroundColor = .blackNight
        tableView.backgroundColor = .blackNight
    }
    
    private func setupTitle() {
        navigationItem.title = String(localized: .irregularEvent)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackDay
        ]
    }
    
    private func setupConstraints() {
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                        
            searchBar.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            limitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.heightAnchor.constraint(equalToConstant: 60),
            
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 16),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollection.heightAnchor.constraint(equalToConstant: 204)
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
                              color: selectedColor ?? UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1),
                              emoji: selectedEmoji ?? "",
                              schedule: [])
        delegate?.didCreateIrregularTracker(tracker, category: selectedCategory ?? "")
        dismiss(animated: true)
    }
    
    @objc func textChanged() {
        createButton.isEnabled = !(searchBar.text?.isEmpty ?? true)
        createButton.backgroundColor = createButton.isEnabled ? .blackDay : .ypGray
    }
    
    func setupUIGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension IrregularViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IrregularViewCell.reuseIdentifier, for: indexPath) as? IrregularViewCell
        cell?.textLabel?.text = items[indexPath.row]
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cell?.textLabel?.textColor = .blackDay
        cell?.backgroundColor = .backgroundDay
        cell?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell?.accessoryType = .disclosureIndicator
        
        if indexPath.row == 0 {
            cell?.detailTextLabel?.text = selectedCategory ?? ""
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell?.detailTextLabel?.textColor = .ypGray
        }
        return cell ?? UITableViewCell()
    }
}

extension IrregularViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let isOverLimit = updatedText.count > 38
        
        limitLabel.isHidden = !isOverLimit
        
        tableViewTopConstraint?.constant = isOverLimit ? 62 : 24
        
        return updatedText.count <= 38
    }
}

extension IrregularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationVC: UIViewController
        
        switch indexPath.row {
        case 0:
            let categoryVC = CategoryViewController()
            categoryVC.onCategorySelected = { [weak self] title in
                guard let self else { return }
                self.selectedCategory = title
                self.tableView.reloadData()
            }
            destinationVC = categoryVC
        default:
            return
        }
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension IrregularViewController: EmojiCollectionViewDelegate {
    func didSelectEmoji(_ emoji: String) {
        self.selectedEmoji = emoji
    }
}

extension IrregularViewController: ColorCollectionViewDelegate {
    func didSelectColor(_ color: UIColor) {
        self.selectedColor = color
    }
}

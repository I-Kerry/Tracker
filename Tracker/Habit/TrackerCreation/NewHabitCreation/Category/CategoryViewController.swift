
import UIKit

final class CategoryViewController: UIViewController {
    
    private var categoryView = CategoryView()
    private var viewModel = CategoryViewModel()
    
    var onCategorySelected: Binding<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTitle()
        categoryView.tableView.dataSource = self
        categoryView.tableView.delegate = self
        
        viewModel.categoriesBinding = { [weak self] categories in
                                         guard let self else { return }
            self.categoryView.tableView.reloadData()
            self.categoryView.updatePlaceholder(isEmpty: self.viewModel.isEmpty)
        }
        
        viewModel.loadCategories()
        
        categoryView.button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        categoryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryView)
        
        NSLayoutConstraint.activate([
            categoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupTitle() {
        navigationItem.title = String(localized: .creatingTracker)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackDay
        ]
    }
    
    @objc func addCategoryTapped() {
        let vc = NewCategoryViewController()
        vc.onCategoryCreated = { [weak self] title in
            guard let self else { return }
            viewModel.addCategory(title: title)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryViewCell.reuseIdentifier, for: indexPath) as? CategoryViewCell else { return UITableViewCell() }
        let category = viewModel.category(at: indexPath.row)
        cell.configure(text: category.header)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.textLabel?.textColor = .blackDay
        cell.backgroundColor = .backgroundDay
        cell.accessoryType = indexPath.row == viewModel.selectedIndex ? .checkmark : .none
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.selectedIndex = indexPath.row
        onCategorySelected?(viewModel.category(at: indexPath.row).header)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)

    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let edit = UIAction(title: String(localized: .edit)) { [weak self] _ in
            guard let self else { return }
            let newCategoryVC = NewCategoryViewController()
            newCategoryVC.initialTitle = self.viewModel.category(at: indexPath.row).header
            newCategoryVC.onCategoryCreated = { title in
                self.viewModel.updateCategory(at: indexPath.row, newTitle: title)
            }
            self.navigationController?.pushViewController(newCategoryVC, animated: true)
        }
        
        let delete = UIAction(title: String(localized: .delete), attributes: .destructive) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showDeleteAlert(at: indexPath.row)
            }
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

extension CategoryViewController {
    private func showDeleteAlert(at index: Int) {
        let alert = UIAlertController(
            title: String(localized: .confirmDeleting),
            message: nil,
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: String(localized: .delete), style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.deleteCategory(at: index)
        })
        
        alert.addAction(UIAlertAction(title: String(localized: .cancel), style: .cancel))
        
        present(alert, animated: true)
    }
}

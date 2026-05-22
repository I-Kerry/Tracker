
import UIKit

final class NewCategoryViewController: UIViewController {
    private var newCategoryView = NewCategoryView()
    var onCategoryCreated: Binding<String>?
    var initialTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCategoryView.button.isEnabled = false
        newCategoryView.button.backgroundColor = .ypGray
        setupUI()
        setupTitle()
        
        
        newCategoryView.button.addTarget(self,
                                         action: #selector(inputCategory),
                                         for: .touchUpInside)
        newCategoryView.textField.addTarget(self,
                                            action: #selector(textChanged),
                                            for: .editingChanged)
        
        newCategoryView.textField.text = initialTitle
    }
    
    private func setupUI() {
        newCategoryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newCategoryView)
        
        NSLayoutConstraint.activate([
            newCategoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newCategoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            newCategoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newCategoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupTitle() {
        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackDay
        ]
    }
    
    @objc func textChanged() {
        newCategoryView.button.isEnabled = !(newCategoryView.textField.text?.isEmpty ?? true)
        newCategoryView.button.backgroundColor = newCategoryView.button.isEnabled ? .blackDay : .ypGray
    }
    
    @objc func inputCategory() {
        let text = newCategoryView.textField.text ?? ""
        onCategoryCreated?(text)
        navigationController?.popViewController(animated: true)
    }
}

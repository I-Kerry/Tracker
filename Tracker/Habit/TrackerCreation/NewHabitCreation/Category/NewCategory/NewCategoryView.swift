
import UIKit

final class NewCategoryView: UIView {
    private let colors = Colors()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите название категории"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        textField.backgroundColor = colors.viewBackgroundColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        
        addSubview(textField)
        addSubview(button)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

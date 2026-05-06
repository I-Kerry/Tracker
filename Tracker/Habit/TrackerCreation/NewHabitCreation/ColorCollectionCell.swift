
import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "ColorCell"
    
    // MARK: - UI
    
    private let colorView: UIView = {
        let colorView = UIView()
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 8
        return colorView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(colorView)
    }
    
    private func setupLayout() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    // MARK: - Configure
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}



import UIKit

enum StatisticsType: String, CaseIterable {
    case bestPeriod
    case idealDays = "perfectDays"
    case completedTrackers
    case averageValue
    
    var localized: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}

final class StatisticsViewCell: UICollectionViewCell {
    static let reuseIdentifier = "StatisticsViewCell"
    
    var number: Int = 0
    
    var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var statNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradientBorder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        addSubview(numberLabel)
        addSubview(statNameLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            statNameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 7),
            statNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func addGradientBorder() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0, green: 0.48, blue: 0.98, alpha: 1).cgColor,
            UIColor(red: 0.27, green: 0.9, blue: 0.62, alpha: 1).cgColor,
            UIColor(red: 0.99, green: 0.3, blue: 0.29, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = contentView.bounds
        
        let mask = CAShapeLayer()
        mask.lineWidth = 1
        mask.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 1, dy: 1), cornerRadius: 15).cgPath
        mask.strokeColor = UIColor.black.cgColor
        mask.fillColor = UIColor.clear.cgColor
        gradient.mask = mask
        
        contentView.layer.addSublayer(gradient)
    }
    
    func configure(number: Int, type: StatisticsType) {
        numberLabel.text = "\(number)"
        statNameLabel.text = type.localized
    }
}

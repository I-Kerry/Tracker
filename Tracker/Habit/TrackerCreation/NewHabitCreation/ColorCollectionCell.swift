
import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    private let colorView: UIView = {
        let colorView = UIView()
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 8
        return colorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}



import UIKit

protocol TrackerViewCellDelegate: AnyObject {
    func didTapButton(in cell: TrackerViewCell)
}

final class TrackerViewCell: UICollectionViewCell {
    weak var delegate: TrackerViewCellDelegate?
    var tracker: Tracker?
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    var cellColored: UIView = {
       let cellColored = UIView()
        cellColored.layer.masksToBounds = true
        cellColored.layer.cornerRadius = 16
        return cellColored
    }()
    
    var emoji: UILabel = {
        let emoji = UILabel()
        emoji.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emoji.layer.masksToBounds = true
        emoji.layer.cornerRadius = 12
        return emoji
    }()
    
    var dayLabel: UILabel = {
        let dayLabel = UILabel()
        return dayLabel
    }()
    
    var button: UIButton! = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.tintColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cellColored)
        cellColored.translatesAutoresizingMaskIntoConstraints = false
        
        cellColored.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        cellColored.addSubview(emoji)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellColored.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellColored.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellColored.heightAnchor.constraint(equalToConstant: 90),
            cellColored.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emoji.topAnchor.constraint(equalTo: cellColored.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: cellColored.leadingAnchor, constant: 12),
            emoji.heightAnchor.constraint(equalToConstant: 24),
            emoji.widthAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: cellColored.leadingAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: cellColored.bottomAnchor, constant: -12),

            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.topAnchor.constraint(equalTo: cellColored.bottomAnchor, constant: 16),
            
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button.topAnchor.constraint(equalTo: cellColored.bottomAnchor, constant: 8),
            button.heightAnchor.constraint(equalToConstant: 34),
            button.widthAnchor.constraint(equalToConstant: 34)
        ])
        
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool) {
        self.tracker = tracker
        emoji.text = tracker.emoji
        label.text = tracker.name
        cellColored.backgroundColor = tracker.color.withAlphaComponent(0.3)
        button.backgroundColor = tracker.color
//        cellColored.alpha = 0.3
        
        if isCompleted {
            button.setImage(UIImage(systemName: "checkmark"), for: .normal)
            button.alpha = 0.3
        } else {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.alpha = 1
        }
        button.tintColor = .white
    }
    
    @objc func tapButton() {
        delegate?.didTapButton(in: self)
    }
}

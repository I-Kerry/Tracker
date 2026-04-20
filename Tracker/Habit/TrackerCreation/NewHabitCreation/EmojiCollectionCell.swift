

import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    let emoji: UILabel = {
        let emoji = UILabel()
        emoji.font = UIFont.systemFont(ofSize: 32)
        return emoji
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        emoji.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emoji)

        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        
    }
}


import UIKit

protocol ColorCollectionViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

final class ColorCollectionView: UIView {
    
    weak var delegate: ColorCollectionViewDelegate?
    
    private let colorArray = [
        UIColor.colorSection1, UIColor.colorSection2, UIColor.colorSection3, UIColor.colorSection4, UIColor.colorSection5, UIColor.colorSection6, UIColor.colorSection7, UIColor.colorSection8, UIColor.colorSection9, UIColor.colorSection10, UIColor.colorSection11, UIColor.colorSection12, UIColor.colorSection13, UIColor.colorSection14, UIColor.colorSection15, UIColor.colorSection16, UIColor.colorSection17, UIColor.colorSection18, 
    ]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.reuseIdentifier, for: indexPath) as! ColorCollectionCell
        cell.configure(with: colorArray[indexPath.item])
        return cell
    }
}

extension ColorCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 5 * 5) / 6, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        view.titleLabel.text = "Цвет"
        view.titleLabel.textAlignment = .left
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCollectionCell
        cell.layer.borderColor = colorArray[indexPath.item].withAlphaComponent(0.3).cgColor
        cell.layer.borderWidth = 3
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 8
        collectionView.allowsMultipleSelection = false
        delegate?.didSelectColor(colorArray[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCollectionCell
        cell.layer.borderWidth = 0
    }
}


import UIKit

protocol IrregularViewCellDelegate: AnyObject {
    
}

final class IrregularViewCell: UITableViewCell {
    static let reuseIdentifier = "irregularCell"
    
    weak var delegate: IrregularViewCellDelegate?
}

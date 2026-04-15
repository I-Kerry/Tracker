
import UIKit

protocol HabitViewCellDelegate: AnyObject {
    
}

final class HabitViewCell: UITableViewCell {
    static let reuseIdentifier = "habitViewCell"
    
    weak var delegate: HabitViewCellDelegate?
    
}

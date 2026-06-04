
import Foundation

enum TrackerFilter: String, CaseIterable {
    case allTrackers
    case todayTrackers
    case finishedTrackers
    case unfinishedTrackers
    
    var localized: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}

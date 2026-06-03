
import Foundation

enum TrackerFilter: String, CaseIterable {
    case allTrackers = "allTrackers"
    case todayTrackers = "todayTrackers"
    case finishedTrackers = "finishedTrackers"
    case unfinishedTrackers = "unfinishedTrackers"
    
    var localized: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}

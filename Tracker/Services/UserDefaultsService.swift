

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    private init() {}
    
    private enum Key {
        static let onboardingCompleted = "onboardingCompleted"
        static let activeFilter = "activeFilter"
    }
    
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Key.onboardingCompleted) }
    }
    
    var isActiveFilterOn: String {
        get { defaults.string(forKey: Key.activeFilter) ?? TrackerFilter.allTrackers.rawValue }
        set { defaults.set(newValue, forKey: Key.activeFilter) }
    }
}

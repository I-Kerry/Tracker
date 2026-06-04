

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}
    
    func report(event: MainScreenEvent, screen: Screen, item: Item?) {
        var params : [String: String] = ["event": event.rawValue, "screen" : screen.rawValue]
        if let item {
            params["item"] = item.rawValue
        }
        AppMetrica.reportEvent(name: event.rawValue, parameters: params, onFailure: { error in
            print("AppMetrica error: \(error)")
        } )
    }
}

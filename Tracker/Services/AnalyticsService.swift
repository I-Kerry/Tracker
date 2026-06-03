

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}
    
    func report(event: String, screen: String, item: String?) {
        var params : [String: String] = ["event": event, "screen" : screen]
        if let item = item {
            params["item"] = item
        }
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("AppMetrica error: \(error)")
        } )
    }
}

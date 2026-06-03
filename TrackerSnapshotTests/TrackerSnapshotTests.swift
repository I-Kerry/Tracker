import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {
    func testTrackerVC() {
        let trackerVC = TrackerViewController()
        
        assertSnapshot(matching: trackerVC, as: .image)
    }
    
    func testTrackerVCLight() {
        let trackerVC = TrackerViewController()
        
        assertSnapshot(matching: trackerVC, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackerVCDark () {
        let trackerVC = TrackerViewController()
        
        assertSnapshot(matching: trackerVC, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}


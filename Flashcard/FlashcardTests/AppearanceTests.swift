import XCTest
@testable import Flashcard

final class AppearanceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear any existing stored appearance for isolation
        UserDefaults.standard.removeObject(forKey: "appearance")
    }

    func testAppearanceAppStorageRoundtrip() {
        // Write a value and read it back via UserDefaults to simulate AppStorage behavior
        UserDefaults.standard.set("dark", forKey: "appearance")
        let stored = UserDefaults.standard.string(forKey: "appearance")
        XCTAssertEqual(stored, "dark")
    }

    func testAppearanceOptionCasesAndLabels() {
        let cases = AppearanceOption.allCases.map { $0.rawValue }
        XCTAssertTrue(cases.contains("system"))
        XCTAssertTrue(cases.contains("light"))
        XCTAssertTrue(cases.contains("dark"))

        // Labels
        let labels = Dictionary(uniqueKeysWithValues: AppearanceOption.allCases.map { ($0.rawValue, $0.label) })
        XCTAssertEqual(labels["system"], "System")
        XCTAssertEqual(labels["light"], "Light")
        XCTAssertEqual(labels["dark"], "Dark")
    }
}

import XCTest

final class PulseUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify all three tabs exist
        XCTAssertTrue(app.tabBars.buttons["Workout"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        XCTAssertTrue(app.tabBars.buttons["Exercises"].exists)

        // Navigate between tabs
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].exists)

        app.tabBars.buttons["Exercises"].tap()
        XCTAssertTrue(app.navigationBars["Exercises"].exists)

        app.tabBars.buttons["Workout"].tap()
        XCTAssertTrue(app.navigationBars["Workout"].exists)
    }

    @MainActor
    func testStartWorkoutFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap start workout button
        let startButton = app.buttons["Start Workout"]
        if startButton.exists {
            startButton.tap()
            // Verify we're in active workout mode
            XCTAssertTrue(app.buttons["Finish"].exists)
        }
    }
}

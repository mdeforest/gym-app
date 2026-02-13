---
name: write-ui-tests
description: Create UI test scenarios based on UX flows described in DESIGN.md.
triggers:
  - "generate UI tests"
  - "test user flow"
---

Steps:

1. Review a UX flow from DESIGN.md.
2. Use the UI test framework (e.g., XCTest + XCUITest for iOS).
3. Create a UI test script that simulates:
   - Navigation through the feature
   - Tap/gesture interactions
   - Assertion of expected UI state or outputs
4. Suggest:
   > "Would you like me to test this on multiple simulators or dynamic type settings?"

Example (Swift/XCUITest):

```swift
func testAddExerciseFlow() {
    let app = XCUIApplication()
    app.launch()

    app.buttons["Start Workout"].tap()
    app.buttons["Add Exercise"].tap()
    app.searchFields["Search exercises"].tap()
    app.searchFields["Search exercises"].typeText("Squat")
    app.cells.staticTexts["Barbell Squat"].tap()
    XCTAssert(app.staticTexts["Barbell Squat"].exists)
}
```

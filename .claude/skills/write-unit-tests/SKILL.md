---
name: write-unit-tests
description: Generate unit tests for a selected function, model, or viewmodel using the project's test framework.
triggers:
  - "write tests"
  - "generate unit tests"
  - "add coverage"
---

Steps:

1. Identify the function, model, or class to be tested.
2. Use the test framework configured in the project (e.g., XCTest for iOS).
3. Create a corresponding test file if it doesn't exist:
   - e.g., `Tests/ModelNameTests.swift` or `Tests/ViewModelTests.swift`
4. Write tests that:
   - Cover expected input/output
   - Handle edge cases and invalid inputs
   - Assert side effects if relevant
5. Ask:
   > "Should I include test cases for error handling or performance?"

Example (Swift/XCTest):

```swift
func testWorkoutInitialization() {
    let workout = Workout(date: Date())
    XCTAssertEqual(workout.sets.count, 0)
}
```

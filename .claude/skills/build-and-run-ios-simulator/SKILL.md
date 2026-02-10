---
name: build-and-run-ios-simulator
description: Build and run the iOS app on a specified simulator, and automatically troubleshoot build/run errors using Claude.
triggers:
  - "run app in simulator"
  - "build and launch"
  - "fix build errors"
---

Use Xcode's command-line tools to build and run the app on an iOS simulator.

Steps:
1. Ensure the project is opened in Xcode at least once.
2. Use `xcodebuild` to build the target for the specified simulator.
3. If build fails, capture the error message and use Claude to suggest and apply a fix.
4. Retry the build after attempting each fix.
5. Use `xcrun simctl` to boot the simulator and launch the app.

Example terminal commands:
```bash
# List available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 16 Pro Max"

# Build the app
xcodebuild \
  -scheme Pulse \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  build 2>&1 | tee build.log

# If build fails, analyze `build.log`:
# Claude should review the error output and suggest:
# - Missing dependencies
# - Code signing issues
# - Syntax or compilation errors
# Fix common issues and rerun build.

# Launch the simulator only if not already running
open -a Simulator
```

Error Fix Strategy:
- Parse `build.log` for errors.
- Prompt Claude: "Here is a failed iOS build log, identify the issue and suggest a fix."
- Implement changes in code or config as needed, confirm build success.
- Use the simulator named "iPhone 16 Pro Max"

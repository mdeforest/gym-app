#!/bin/bash

xcrun simctl terminate booted com.pulse.Pulse && \
xcodebuild -scheme Pulse -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' -quiet build && \
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/Pulse-*/Build/Products/Debug-iphonesimulator/Pulse.app && \
xcrun simctl launch booted com.pulse.Pulse

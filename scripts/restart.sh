#!/bin/bash

xcrun simctl terminate booted com.gymapp.GymApp && \
xcodebuild -scheme GymApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' -quiet build && \
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/GymApp-*/Build/Products/Debug-iphonesimulator/Gym\ App.app && \
xcrun simctl launch booted com.gymapp.GymApp

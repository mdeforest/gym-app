# Gym App

A minimal, no-nonsense workout tracker for iOS. Log weight training and cardio sessions fast, track progressive overload, and review training history — all without the bloat of social features, paywalls, or unnecessary complexity.

## Features

- **Workout logging** — Start a session, add exercises, and log sets (weight, reps) with minimal taps
- **Cardio logging** — Cardio exercises use dedicated time/distance inputs instead of weight/reps
- **Rest timer** — Auto-starts on set completion (configurable per exercise). Floating pill with countdown, expandable to full controls (+30s, -30s, Skip). Haptic + sound on completion; local notification when backgrounded. Timer continues counting in the background.
- **Exercise library** — Pre-populated list of 51 common lifts categorized by muscle group, plus custom exercises
- **Exercise detail panel** — Tap any exercise to view how-to instructions, primary muscles, rest timer config, and recent workout history
- **Workout history** — Browse past workouts by date with full session details; auto-navigates to detail after finishing a workout. Only completed sets are saved.
- **Edit completed workouts** — Tap Edit on any past workout to change start/end time, add/remove sets, modify weight/reps, or update cardio inputs
- **Last-session reference** — Sets are pre-filled with last session's weight/reps for easy progressive overload tracking
- **Set management** — Swipe left to delete sets; editing a set auto-populates remaining incomplete sets
- **Cancel workout** — Dedicated cancel button with confirmation to discard an in-progress workout

## Design Goals

- **Tone**: Minimal and functional — get in, log, get out
- **Style**: Dark mode by default, clean typography, high-contrast inputs
- **UX**: Optimized for one-handed use in a gym setting; logging a set takes 2-3 taps

## Tech Stack

| Layer          | Technology                |
|----------------|---------------------------|
| Platform       | iOS 17+                   |
| Language       | Swift 6                   |
| UI Framework   | SwiftUI                   |
| Persistence    | SwiftData                 |
| Architecture   | MVVM                      |
| Project Gen    | XcodeGen                  |

## Project Structure

```
GymApp/
├── App/
│   ├── GymApp.swift              # App entry point + SwiftData ModelContainer
│   └── ContentView.swift         # 3-tab layout (Workout, History, Exercises)
├── Models/
│   ├── MuscleGroup.swift         # Muscle group enum (7 groups)
│   ├── Exercise.swift            # Exercise definition (name, muscle group, custom flag)
│   ├── Workout.swift             # Workout session (start/end date, exercises)
│   ├── WorkoutExercise.swift     # Exercise within a workout (+ cardio fields)
│   └── ExerciseSet.swift         # Individual set (weight, reps, completion)
├── ViewModels/
│   ├── WorkoutViewModel.swift
│   ├── ExerciseLibraryViewModel.swift
│   ├── ExerciseDetailViewModel.swift
│   └── HistoryViewModel.swift
├── Views/
│   ├── Workout/
│   │   ├── WorkoutView.swift
│   │   ├── ActiveWorkoutView.swift
│   │   └── AddExerciseView.swift
│   ├── ExerciseLibrary/
│   │   ├── ExerciseLibraryView.swift
│   │   ├── ExerciseDetailView.swift
│   │   └── AddCustomExerciseView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── WorkoutDetailView.swift
│   └── Components/               # Reusable UI components
│       ├── PrimaryButton.swift
│       ├── SecondaryButton.swift
│       ├── DestructiveButton.swift
│       ├── PillButton.swift
│       ├── NumberInputField.swift
│       ├── ExerciseCard.swift
│       ├── SetRowView.swift
│       ├── EmptyStateView.swift
│       ├── StatCard.swift
│       ├── FeaturedStatCard.swift
│       ├── StatGrid.swift
│       ├── ProgressBar.swift
│       ├── CircularActionButton.swift
│       ├── CircularProgressRing.swift
│       └── RestTimerView.swift
├── Theme/
│   └── AppTheme.swift            # Design tokens (colors, spacing, layout)
├── Services/
│   ├── DataService.swift         # ModelContainer factory
│   ├── ExerciseSeedData.swift    # 51 pre-populated exercises
│   └── ExerciseInstructions.swift # How-to instructions for all exercises
└── Resources/
    ├── Assets.xcassets
    └── exercises.json          # Exercise seed data (51 exercises with rest defaults)
GymAppTests/
└── GymAppTests.swift             # Unit tests (Swift Testing)
GymAppUITests/
└── GymAppUITests.swift           # UI tests (XCTest)
project.yml                       # XcodeGen project configuration
```

## Requirements

- Xcode 16+
- macOS 15 (Sequoia) or later
- iOS 17+ device or simulator
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/yourname/gym-app.git
   cd gym-app
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open the project in Xcode:
   ```bash
   open GymApp.xcodeproj
   ```

4. Select a simulator or connected device (iOS 17+)

5. Build and run (`⌘R`)

## Testing

Run the full test suite in Xcode:

- **Unit tests**: `⌘U` or Product > Test
- **UI tests**: Included in the `GymAppUITests` target

```bash
# CLI alternative
xcodebuild test -scheme GymApp -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Deployment

### TestFlight (Beta)

1. Set up an app record in [App Store Connect](https://appstoreconnect.apple.com)
2. In Xcode, set the bundle identifier and enable **Automatic Signing** with your team
3. Archive the app: Product > Archive
4. Upload to App Store Connect via the Organizer
5. Distribute to testers via TestFlight

### App Store (Production)

1. Complete the App Store listing (screenshots, description, privacy policy)
2. Submit the build for App Review
3. Once approved, release to the App Store

### Code Signing

This project uses **Automatic Signing**. Ensure your Apple Developer account is configured in Xcode under Settings > Accounts.

## License

This project is licensed under the MIT License.

## Author

Made by Michaela DeForest

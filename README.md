<p align="center">
  <img src="Pulse/Resources/Assets.xcassets/Logo.imageset/Logo.png" alt="Pulse" width="300">
</p>

<p align="center">
  A minimal, no-nonsense workout tracker for iOS. Log weight training and cardio sessions fast, track progressive overload, and review training history — all without the bloat of social features, paywalls, or unnecessary complexity.
</p>

## Features

- **Workout logging** — Start a session, add exercises, and log sets (weight, reps) with minimal taps
- **Cardio logging** — Cardio exercises use dedicated time/distance inputs instead of weight/reps
- **Warm-up sets** — Toggle any set between normal and warm-up by tapping the set number. Warm-up sets display a "W" badge in warning color and are excluded from progress stats and PR calculations.
- **RPE tracking** — Optional RPE (Rate of Perceived Exertion) rating per set, 6.0–10.0 in 0.5 increments. Color-coded badges (green/yellow/red) and an inline horizontal picker. RPE data shown on strength progression charts.
- **Supersets** — Link two or more exercises to perform back-to-back. Grouped exercises render with a purple bracket and "SUPERSET" label. Rest timer only starts after the last exercise in a superset. Link/unlink via purple pill buttons between exercise groups.
- **Exercise reordering** — Move exercises (or superset groups) up and down during an active workout or while editing a completed workout. Inline arrow buttons in each card header.
- **Workout templates** — Save named routines (e.g. "Push Day") with per-set configuration (individual weight, reps, and warm-up/normal type for each set), superset grouping, and optional defaults. Create templates from scratch or save a completed workout as a template — exact set configurations are captured. Start a pre-populated workout from any template with one tap.
- **Rest timer** — Auto-starts on set completion (configurable per exercise). Floating pill with countdown, expandable to full controls (+30s, -30s, Skip). Haptic + sound on completion; local notification when backgrounded. Timer continues counting in the background.
- **Exercise library** — Pre-populated list of 590 exercises sourced from the Free Exercise DB, categorized across 7 muscle groups and 8 equipment types. Filter by muscle group, equipment type, or favorites; a favorites-only star toggle lives in the toolbar for quick one-tap access. Active filters appear as removable chips below the search bar. Add custom exercises with a name, muscle group, and equipment type.
- **Exercise favorites** — Star up to 10 exercises in the library or detail panel; favorites are prioritized in progress charts
- **Exercise detail panel** — Tap any exercise to view how-to instructions, primary muscles, rest timer config, and recent workout history
- **Personal records (PRs)** — Automatic per-set PR detection for three record types: heaviest weight, best estimated 1RM (Epley formula), and best single-set volume (weight × reps). Gold "PR" badges on set rows during workouts and in history. Animated "New PR!" toast with haptic feedback during active workouts. "Personal Records" section in exercise detail showing all-time bests. Trophy markers on strength progression charts. PR data included in CSV/JSON exports.
- **Progress charts** — Segmented "Progress" view in History with workout frequency (bar chart), muscle group split (donut chart), and per-exercise strength progression (line chart with PR trophy annotations). Filter by time range (1M, 3M, 6M, 1Y, All). Summary stats: workouts this month, total volume, day streak, and personal records. Warm-up sets are excluded from all calculations.
- **Calendar view** — Monthly calendar at the top of the History tab showing workout days with accent-colored dots. Tap a day to filter the workout list; tap again to clear. Navigate to past months with chevron buttons (future months disabled). Select any past day to add a backdated workout.
- **Workout history** — Browse past workouts by date with full session details; auto-navigates to detail after finishing a workout. Only completed sets are saved.
- **Edit completed workouts** — Tap Edit on any past workout to change start/end time, add/remove sets, modify weight/reps, reorder exercises, create/dissolve supersets, or update cardio inputs
- **Last-session reference** — Sets are pre-filled with last session's weight/reps for easy progressive overload tracking
- **Set management** — Swipe left to delete sets; editing a set auto-populates remaining incomplete sets
- **Cancel workout** — Dedicated cancel button with confirmation to discard an in-progress workout
- **Available Equipment** — Configure which equipment you have access to in Settings. Exercises requiring unconfigured equipment are hidden in the Exercise Library and Add Exercise sheet. Exercises with no equipment type or categorized as "Other" always show. Easily reset to show everything with a single tap.
- **Settings page** — Profile setup (name, body weight, weight unit), available equipment configuration, Apple Health sync toggle with authorization status, data export (CSV/JSON via share sheet), clear all data with confirmation, and app version display. Accessed via a profile avatar button on the Workout tab.
- **Data export** — Export full workout history as CSV or JSON. Includes exercise names, muscle groups, sets, weight, reps, set type, RPE, superset group, and cardio data. Share via the iOS share sheet.
- **Apple Health integration** — Sync completed workouts to Apple Health with exercise count and total volume metadata. Read latest body weight from Health. Toggle sync on/off in Settings with authorization status display.
- **Animated splash screen** — Logo fades in centered, then shrinks and slides into position on the Workout tab as the app reveals
- **Calculators** — Quick-access tool menu from the Workout tab (both idle and active states). Includes: Plate Calculator (target weight → plates per side with visual bar + plate breakdown, custom bar weight, lbs/kg support), 1RM Calculator (weight + reps → estimated 1RM with RPE-to-percentage reference table), RPE Chart (reference table with optional 1RM input for weight targets per RPE level), and Stopwatch (MM:SS.cs display with lap splits)

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
| Charts         | Swift Charts              |
| Persistence    | SwiftData                 |
| Architecture   | MVVM                      |
| Project Gen    | XcodeGen                  |

## Project Structure

```
Pulse/
├── App/
│   ├── PulseApp.swift              # App entry point + SwiftData ModelContainer
│   └── ContentView.swift         # 4-tab layout (Workout, History, Exercises, Templates)
├── Models/
│   ├── MuscleGroup.swift         # Muscle group enum (7 groups)
│   ├── Equipment.swift           # Equipment enum (8 types: barbell, dumbbell, cable, machine, bodyweight, kettlebell, bands, other)
│   ├── Exercise.swift            # Exercise definition (name, muscle group, equipment, custom flag)
│   ├── Workout.swift             # Workout session (start/end date, exercises)
│   ├── WorkoutExercise.swift     # Exercise within a workout (+ cardio fields, superset group)
│   ├── ExerciseSet.swift         # Individual set (weight, reps, completion, set type, RPE, PR flags)
│   ├── WorkoutTemplate.swift     # Saved workout routine (name, exercises)
│   ├── TemplateExercise.swift    # Exercise within a template (set count, defaults)
│   └── TemplateSet.swift         # Individual set within a template (weight, reps, type)
├── ViewModels/
│   ├── WorkoutViewModel.swift
│   ├── ExerciseLibraryViewModel.swift
│   ├── ExerciseDetailViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── ProgressViewModel.swift
│   ├── TemplateViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Workout/
│   │   ├── WorkoutView.swift
│   │   ├── ActiveWorkoutView.swift
│   │   ├── SupersetGroupView.swift
│   │   └── AddExerciseView.swift
│   ├── ExerciseLibrary/
│   │   ├── ExerciseLibraryView.swift
│   │   ├── ExerciseDetailView.swift
│   │   ├── ExerciseFilterSheet.swift
│   │   └── AddCustomExerciseView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── CalendarView.swift
│   │   ├── CalendarDayCell.swift
│   │   ├── ProgressView.swift
│   │   ├── WorkoutDetailView.swift
│   │   └── Charts/
│   │       ├── WorkoutFrequencyChart.swift
│   │       ├── MuscleGroupChart.swift
│   │       └── StrengthProgressionChart.swift
│   ├── Templates/
│   │   ├── TemplatesView.swift
│   │   ├── CreateTemplateView.swift
│   │   └── TemplateDetailView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ProfileSectionView.swift
│   │   ├── EquipmentSectionView.swift
│   │   ├── HealthSectionView.swift
│   │   └── DataManagementSectionView.swift
│   ├── Tools/
│   │   ├── ToolsMenuView.swift
│   │   ├── PlateCalculatorView.swift
│   │   ├── OneRMCalculatorView.swift
│   │   ├── RPEChartView.swift
│   │   └── StopwatchView.swift
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
│       ├── RestTimerView.swift
│       ├── TemplateCardView.swift
│       ├── RPEBadgeView.swift
│       ├── RPEPickerView.swift
│       ├── PRBadgeView.swift
│       ├── PRToastView.swift
│       ├── SupersetLinkLabel.swift
│       └── SplashView.swift
├── Theme/
│   └── AppTheme.swift            # Design tokens (colors, spacing, layout)
├── Services/
│   ├── DataService.swift         # ModelContainer factory
│   ├── ExerciseSeedData.swift    # 590 pre-populated exercises (additive seeding on update)
│   ├── ExerciseInstructions.swift # How-to instructions for all exercises
│   ├── ExportService.swift       # CSV/JSON workout data export
│   ├── PersonalRecordService.swift # PR detection, records queries, and backfill
│   ├── PlateCalculatorService.swift # Greedy plate calculation for target weights
│   └── HealthKitService.swift    # Apple Health sync (workouts + body weight)
└── Resources/
    ├── Assets.xcassets           # AppIcon, Logo image, AccentColor
    └── exercises.json          # Exercise seed data (590 exercises with equipment + rest defaults)
PulseTests/
├── PulseTests.swift             # Model, enum, and service unit tests (Swift Testing)
├── ViewModelTests.swift         # ViewModel unit tests (Swift Testing)
└── ProgressViewModelTests.swift # Progress analytics tests (Swift Testing)
PulseUITests/
└── PulseUITests.swift           # UI tests (XCTest)
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
   open Pulse.xcodeproj
   ```

4. Select a simulator or connected device (iOS 17+)

5. Build and run (`⌘R`)

## Testing

Run the full test suite in Xcode:

- **Unit tests**: `⌘U` or Product > Test
- **UI tests**: Included in the `PulseUITests` target

```bash
# CLI alternative
xcodebuild test -scheme Pulse -destination 'platform=iOS Simulator,name=iPhone 16'
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

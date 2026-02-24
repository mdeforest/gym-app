# Project Brief

## Project Name
Pulse

## Summary
A personal workout tracker built for a single user who primarily lifts weights and occasionally does cardio. The app replaces the use of other apps such as Juggernaut AI and Fitbod with a fast, frictionless way to log workouts, track progressive overload, and review training history.

## Target Audience
- **Solo user** — this is a personal tool, not a multi-user platform
- **Pain points**:
  - Existing gym apps are bloated with social features, paywalls, and unnecessary complexity
  - Hard to quickly log sets mid-workout without friction
  - Difficult to see at a glance whether weight/reps are progressing over time

## Goals and Objectives
- **Primary goal**: Provide a fast, minimal interface to log weight training workouts (exercises, sets, reps, weight) and review history
- **Stretch goals (post-MVP)**:
  - ~~Workout templates / saved routines~~ **Delivered** — see Core Features
  - ~~Progress charts and analytics (PR tracking, volume over time)~~ **Delivered** — see Core Features
  - ~~Rest timer~~ **Delivered** — see Core Features
  - ~~Workout calendar view~~ **Delivered** — see Core Features
  - ~~Data export (CSV/JSON)~~ **Delivered** — see Core Features
  - ~~Settings page~~ **Delivered** — see Core Features
  - ~~Advanced workout features (warm-up sets, RPE, supersets)~~ **Delivered** — see Core Features
  - ~~Apple Health integration~~ **Delivered** — see Core Features
  - ~~Personal record tracking~~ **Delivered** — see Core Features
  - ~~Calculators~~ **Delivered** — see Core Features
  - ~~Expanded exercise database~~ **Delivered** — 590 exercises with equipment data and filtering
  - ~~Available equipment filtering~~ **Delivered** — superseded by Gym Profiles
  - ~~Gym Profiles~~ **Delivered** — named equipment presets with machine-type sub-selection, instant switching, and built-in templates
  - Body weight / measurement tracking

## Core Features
- [x] **Workout logging**: Start a workout session, add exercises, and log sets (weight, reps) with minimal taps. Cancel button with confirmation to discard in-progress workouts.
- [x] **Exercise library**: A pre-populated list of 590 exercises (sourced from Free Exercise DB) across 7 muscle groups (Chest, Back, Shoulders, Arms, Legs, Core, Cardio) and 8 equipment types (Barbell, Dumbbell, Cable, Machine, Bodyweight, Kettlebell, Bands, Other). Filterable by muscle group, equipment type, and favorites. Active filters shown as removable chips. Custom exercises include an equipment picker. Additive seeding adds new exercises without touching user data on updates.
- [x] **Exercise detail panel**: Tap any exercise to view how-to instructions (description, primary muscles, step-by-step guide) and recent workout history in a resizable bottom sheet
- [x] **Cardio logging**: Dedicated time (minutes) and distance (km) inputs for cardio exercises, replacing weight/reps UI. Pre-fills from last session.
- [x] **Workout history**: Browse past workouts by date, view full session details. After finishing a workout, the app auto-navigates to the completed workout's detail view in the History tab. Only completed sets are saved; incomplete sets and empty exercises are discarded on finish.
- [x] **Edit completed workouts**: Tap Edit on any past workout to modify start/end time (with live duration preview), add/remove exercises, add/remove sets, and change weight/reps or cardio inputs. Uses the same SetRowView and NumberInputField components as the active workout screen.
- [x] **Last-session reference**: When logging an exercise, sets are pre-filled with last session's weight/reps for easy progressive overload tracking
- [x] **Set management**: Swipe left to delete individual sets. Editing a set's weight/reps auto-propagates values to subsequent incomplete sets.
- [x] **Rest timer**: Auto-starts when completing a set if the exercise has a configured rest duration. Floating pill overlay with countdown, expandable to full controls (±30s, Skip). Haptic + sound on completion; local notification when backgrounded. Each exercise has a configurable `defaultRestSeconds` (editable in Exercise Detail and inline during workouts). Timer uses wall-clock dates so it continues counting while the app is backgrounded.
- [x] **Branding & splash screen**: Custom app icon (dumbbell on dark background) and horizontal logo lockup. Animated splash screen on launch — logo fades in centered, then shrinks and transitions into its resting position on the Workout tab.
- [x] **Workout templates**: Save named routines (e.g. "Push Day") with per-set configuration (individual weight, reps, and warm-up/normal type via `TemplateSet` model). Create templates from scratch via the dedicated Templates tab or save a completed workout as a template — exact set configurations are captured. Start a pre-populated workout from any template with one tap — sets are pre-filled from template defaults, falling back to last-session values. Superset grouping preserved. Edit, rename, reorder exercises, and delete templates. Dedicated 4th tab in the tab bar. Legacy templates auto-migrate to per-set format on first use.
- [x] **Exercise favorites**: Star up to 10 strength exercises in the exercise library or detail panel. Favorites are prioritized in the progress charts exercise picker.
- [x] **Progress charts & analytics**: Segmented "Progress" view within the History tab. Summary stats (workouts this month, total volume lifted, day streak, personal records). Three chart types: weekly workout frequency (bar chart), muscle group split (donut chart with legend), and per-exercise strength progression (line/area chart with max weight over time). Time range filter (1M, 3M, 6M, 1Y, All). Exercise picker prioritizes favorites, falls back to all used exercises. Built with Swift Charts.
- [x] **Calendar view**: Monthly calendar grid embedded at the top of the History tab's Workouts segment. Workout days marked with accent-colored dots. Tap a day to filter the list below to that day's sessions; tap again to deselect. Month navigation via chevron buttons (past only — future months disabled). Select any past day to create a backdated workout that opens in edit mode. Today is highlighted with a muted accent circle.
- [x] **Settings page**: Accessible via profile avatar button on the Workout tab. Profile section (name, body weight, weight unit). Data export (CSV/JSON via share sheet). Clear all data with destructive confirmation. App version display. Presented as a modal sheet with inset grouped list styling.
- [x] **Data export**: Export full workout history as CSV or JSON via `ExportService`. CSV includes date, duration, exercise, muscle group, type, sets, weight, reps, set type, RPE, superset group, and cardio data. JSON includes structured workout objects with ISO 8601 dates. Files are shared via the iOS share sheet (`UIActivityViewController`).
- [x] **Warm-up sets**: Toggle any set between normal and warm-up by tapping the set number. Warm-up sets show a "W" badge in warning color and are excluded from progress stats, volume calculations, and PR tracking. Templates preserve warm-up set counts.
- [x] **RPE tracking**: Optional RPE (Rate of Perceived Exertion) rating per set, 6.0–10.0 in 0.5 increments. Color-coded badges (green 6–7, yellow 7.5–8.5, red 9–10) with inline horizontal picker. RPE data displayed on strength progression chart point marks.
- [x] **Supersets**: Link exercises to perform back-to-back via a purple "Link" pill button between exercise groups. Superset groups render with a purple bracket and "SUPERSET" label. Rest timer only fires after the last exercise in a superset. Superset grouping preserved in templates. Link/unlink available during active workouts and when editing completed workouts.
- [x] **Exercise reordering**: Move exercises or superset groups up/down during active workouts and while editing completed workouts via inline arrow buttons in each card header.
- [x] **Apple Health integration**: Sync completed workouts to Apple Health with exercise count and total volume metadata. Read latest body weight from Health. Toggle sync on/off in Settings with authorization status display and link to system Settings when access is denied. Uses `HealthKitService` singleton with async/await.
- [x] **Personal records (PRs)**: Per-set PR detection for three record types: heaviest weight, best estimated 1RM (Epley formula), and best single-set volume (weight × reps). Gold "PR" badges on set rows throughout the app, animated "New PR!" toast with haptic during active workouts, "Personal Records" section in exercise detail showing all-time bests, and trophy annotations on strength progression charts. PR flags stored on `ExerciseSet` for instant display. One-time backfill stamps PRs on existing workout history. PR data included in CSV/JSON exports.
- [x] **Calculators**: Quick-access tool menu via a `±` toolbar button on the Workout tab (both idle and active workout states). Four tools: **Plate Calculator** (greedy algorithm for plates per side given a target weight; visual bar + plate breakdown with color-coded chips; custom bar weight option; lbs/kg support), **1RM Calculator** (Epley formula estimate from weight + reps; RPE-to-percentage reference table with color-coded badges), **RPE Chart** (reference table mapping RPE 6–10 to percentages and RIR; optional 1RM input shows target weights per RPE level), and **Stopwatch** (MM:SS.cs monospaced display; lap splits with cumulative time and delta; wall-clock date tracking for background accuracy).
- [x] **Gym Profiles**: Save named equipment presets (e.g. "Home Gym", "Commercial Gym", "Travel") that can be switched instantly from a dedicated Settings screen. Each profile stores a selected set of equipment types (barbell, dumbbell, cable, machine, bodyweight, kettlebell, bands, other) and, when Machine is included, a specific subset of 12 machine types (Smith Machine, Leg Press, Leg Extension/Curl, Hack Squat, Calf Machine, Cardio Machines, Chest/Fly Machine, Row Machine, Shoulder Press Machine, Leverage/Plate Machine, Arm Machine, Other Machines). Applying a profile writes to the `availableEquipment` and `availableMachines` `@AppStorage` keys that filter the Exercise Library and Add Exercise sheet in real time. Profiles persisted as JSON in UserDefaults with backward-compatible Codable (new `machinesRaw` field defaults to `""` for existing data). Three built-in templates (Commercial Gym, Home Gym, Travel) available via a "Use Template" shortcut in the edit sheet. A default "My Gym" profile is auto-created on first launch. Active profile name shown as trailing text on the Settings navigation row. Exercises typed as `.other` or with no equipment always show regardless of profile.

## Design and User Experience Vibe
- **Tone**: Minimal and functional — get in, log, get out. No gamification, no fluff
- **Style**: Dark mode by default; clean typography; high-contrast inputs sized for easy tapping mid-workout
- **Key UX principles**:
  - Logging a set should take no more than 2-3 taps
  - The app should be optimized for mobile use in a gym setting (one-handed, sweaty fingers)
  - Previous session data always visible for reference while logging
- **References / inspiration**: Strong (iOS app), JEFIT (exercise library), plain spreadsheet simplicity

## Tech Stack
- Native iOS app (Swift 6 / SwiftUI), deployed via the App Store
- iOS 17+ minimum deployment target
- SwiftData for on-device persistence
- MVVM architecture with `@Observable` ViewModels
- XcodeGen for Xcode project generation (`project.yml`)
- No backend needed for MVP — all data is local on-device
- Deployment via TestFlight (beta) and App Store Connect (production)
- HealthKit integration for workout sync and body weight reading (currently disabled — requires paid Apple Developer account for entitlements)
- iCloud sync is a nice-to-have post-MVP

## Risks / Open Questions
- ~~**Data model complexity**: Supersets, drop sets, and RPE tracking add complexity — keep them out of MVP?~~ **Resolved**: Warm-up sets, RPE tracking, and supersets implemented with additive optional properties on existing models (lightweight SwiftData migration)
- ~~**Exercise library scope**: How large should the default exercise list be?~~ **Resolved**: 51 exercises across 7 muscle groups, seeded on first launch
- **App Store review**: Ensure compliance with Apple's Human Interface Guidelines and App Review Guidelines
- ~~**Cardio UI**: Data model supports cardio (duration/distance fields) but no dedicated input UI yet — needed for MVP?~~ **Resolved**: Dedicated time/distance inputs built for cardio exercises
- ~~**Rest timer**: Originally a stretch goal — should it be included in MVP?~~ **Resolved**: Implemented with per-exercise configurable rest durations, auto-start on set completion, floating timer pill, local notifications, and background-aware countdown

## Success Metrics
- The app is actually used during workouts instead of falling back to notes/spreadsheets
- Logging a full workout session (5-6 exercises, 3-5 sets each) feels fast and painless
- Historical data is easy to find and reference


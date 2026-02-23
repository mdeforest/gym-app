# Changelog

## [0.12.0] - 02/23/26

### Added
- Exercise database expanded from 51 to 590 exercises sourced from the Free Exercise DB (public domain, Unlicense)
- `Equipment` model — 8 types: Barbell, Dumbbell, Cable, Machine, Bodyweight, Kettlebell, Bands, Other
- `ExerciseFilterSheet` — `.medium` detent sheet with `LazyVGrid` grids for muscle group (8 groups + All) and equipment (8 types + Any) filtering; Clear All and Done toolbar buttons
- Exercise library toolbar: favorites star toggle (`showFavoritesOnly`), filter button with active-filter badge dot, and `+` add button
- Active filter chips row — horizontally scrollable accent-colored capsule pills with `×` dismiss buttons appear above the exercise list whenever any filter is active; "Clear All" text button shown when ≥2 filters are active
- `AddCustomExerciseView` now includes an equipment picker (defaults to Other)
- `ExerciseDetailView` instructions fallback — seeded exercises with no `ExerciseInstructions` entry render description + numbered steps from the model; custom exercises show "No instructions available"
- `scripts/prepare_exercises.py` — one-time data preparation script used to generate `exercises.json` from Free Exercise DB
- 43 new unit tests covering models (`SetType`, `PRType`, `ExerciseSet`, `WorkoutExercise`, `TemplateSet`, `TimeRange`), services (`PersonalRecordService`, `PlateCalculatorService`, `ExportService`), and ViewModels (`ExerciseDetailViewModel`, `SettingsViewModel`)

### Changed
- `ExerciseSeedData` — additive seeding: fast-path insert on first launch; on subsequent launches only inserts exercises whose names are not already in the store (preserves user-created exercises)
- `Exercise` model — added `equipment: Equipment` property (defaults to `.other`; lightweight SwiftData migration for existing rows)
- `ExerciseLibraryViewModel` — refactored `seedExercisesIfNeeded()` to use additive seeding; added `selectedEquipment` filter state; `addCustomExercise` now accepts `equipment` parameter
- `NumberInputField` — switched to local `@State localText` buffer with `@FocusState` sync to prevent cursor jumps during mid-edit external value changes
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

## [0.11.0] - 02/22/26

### Added
- Calculators feature — quick-access tool menu via `±` toolbar button on the Workout tab (idle overlay and active workout toolbar)
- `ToolsMenuView` — 2×2 grid sheet presenting four tools with icon, title, and subtitle cards
- `PlateCalculatorView` — greedy plate calculation for a target weight; bar weight pill selector (Standard, Olympic, EZ Bar, Safety Bar, Custom); visual bar diagram with color-coded plate slices; text breakdown per side with color chips; remainder warning; lbs/kg support
- `PlateCalculatorService` — pure computation service using a greedy algorithm to calculate plates per side
- `OneRMCalculatorView` — estimated 1RM from weight + reps (Epley formula via `PersonalRecordService`); result in FeaturedStatCard; RPE-to-percentage reference table with color-coded RPE badges
- `RPEChartView` — RPE reference table (RPE 6–10, percentage of 1RM, RIR); optional 1RM input reveals a Weight column with target loads per RPE level in accent color
- `StopwatchView` — MM:SS.cs monospaced display; Start/Pause, Lap, and Reset controls; lap list with split deltas and cumulative times; wall-clock date tracking for background accuracy

### Changed
- `WorkoutView` — added floating `±` button overlay (alongside profile avatar) to open tools sheet
- `ActiveWorkoutView` — added `±` toolbar button between Cancel and Finish to open tools sheet
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

### Fixed
- Stopwatch display now updates in real time (timer callback was previously a no-op)
- Stopwatch background is fully black from launch (was only filled after first lap)

## [0.10.0] - 02/19/26

### Added
- Personal records (PRs) — per-set PR detection for three record types: heaviest weight, best estimated 1RM (Epley formula), and best single-set volume (weight × reps)
- Gold "PR" badge on set rows during active workouts, workout history detail, and exercise detail history
- Animated "New PR!" toast with trophy icon, PR type labels, and haptic feedback during active workouts
- "Personal Records" section in exercise detail panel showing all-time best weight, estimated 1RM, and volume with gold icons
- Trophy annotations on strength progression chart for estimated 1RM PR data points
- `PersonalRecordService` with PR detection, all-time records queries, and one-time backfill for existing data
- `PRBadgeView` component with compact and detailed styles
- `PRToastView` component with spring animation and auto-dismiss
- `PRType` enum on `ExerciseSet` model with `isWeightPR`, `isEstimated1RMPR`, `isVolumePR` boolean flags
- PR flag columns in CSV and JSON exports
- One-time backfill on first launch stamps PR flags on all existing workout history

### Changed
- `ProgressViewModel.computePRCount()` simplified to use stored PR flags instead of recomputing from scratch
- Strength progression chart point marks now show gold trophy icon for PR data points instead of standard circle
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

## [0.9.0] - 02/19/26

### Added
- Apple Health integration — sync completed workouts to Apple Health with exercise count and total volume metadata
- Read latest body weight from Apple Health and cache in UserDefaults
- Health section in Settings with sync toggle, authorization status display, and link to system Settings when access is denied
- `HealthKitService` singleton with async/await for Health operations
- `HealthSectionView` component for Apple Health settings
- `Pulse.entitlements` with HealthKit capability
- `TemplateSet` SwiftData model — per-set configuration in templates with individual weight, reps, and set type (warmup/normal)
- Per-set CRUD operations in `TemplateViewModel` (add, delete, toggle type)
- Auto-migration from legacy template format to per-set model on first use (`migrateToSetsIfNeeded`)
- Template superset linking/unlinking in `TemplateViewModel`
- Template detail and create views now show individual set rows with warm-up (W) indicators

### Changed
- `WorkoutViewModel.finishWorkout()` now syncs completed workouts to Apple Health when enabled
- `WorkoutViewModel.startWorkout(from:)` copies individual template sets directly, preserving set type and superset grouping
- Settings view expanded from 2 sections to 3 (Profile, Health, Data Management)
- Template creation from completed workouts captures exact per-set configurations instead of just set count
- Strength progression chart uses estimated 1RM (Epley formula) instead of raw max weight
- SwiftData model container updated across all files to include `TemplateSet`
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

## [0.8.0] - 02/17/26

### Added
- Warm-up sets — toggle any set between normal and warm-up by tapping the set number; "W" badge in warning color; excluded from progress stats, volume, and PRs
- RPE tracking — optional per-set RPE rating (6.0–10.0 in 0.5 increments) with color-coded badges (green/yellow/red) and inline horizontal picker
- Supersets — link exercises into groups via purple "Link" pill button between exercise cards; purple bracket and "SUPERSET" label; rest timer only fires after last exercise in group
- Exercise reordering — arrow up/down buttons in exercise card headers and superset group headers during active workouts and history editing
- `RPEBadgeView` component — compact color-coded RPE capsule pill
- `RPEPickerView` component — inline horizontal picker with color-coded pills
- `SupersetGroupView` component — visual wrapper with purple bracket for linked exercises
- `SupersetLinkLabel` component — purple pill button label with dashed connector lines
- `SetType` enum (normal/warmup) on `ExerciseSet` model
- `rpe` optional property on `ExerciseSet` model
- `supersetGroupId` optional property on `WorkoutExercise` model
- `warmupSetCount` and `supersetGroupId` on `TemplateExercise` model
- Superset and warm-up set preservation in templates (create from workout and start from template)
- Exercise group reordering logic shared between `WorkoutViewModel` and `HistoryViewModel`
- Set type, RPE, and superset group columns in CSV/JSON export
- RPE color-coding on strength progression chart point marks
- `supersetAccent` color token (alias for chartPurple)

### Changed
- Warm-up sets excluded from progress stats, volume calculations, and PR tracking
- Set value auto-propagation now only applies to sets of the same type
- Strength progression chart excludes warm-up set data
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

## [0.7.0] - 02/16/26

### Added
- Settings page — accessible via profile avatar button on the Workout tab
- Profile section with name, body weight, and weight unit (lbs/kg) persisted via `@AppStorage`
- Data export — CSV and JSON export of full workout history via `ExportService` and iOS share sheet
- Clear all data option with destructive confirmation alert and success feedback
- App version and build number display in settings
- `SettingsViewModel` with export data generation and clear data logic
- `ExportService` with CSV and JSON formatters and temporary file writing
- Profile avatar component showing user initials or fallback person icon

### Changed
- Toolbar "+" buttons on Exercises and Templates tabs replaced with circular overlay buttons for visual consistency
- Workout tab now shows profile avatar (top-right) when no active workout is in progress
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

### Fixed
- WorkoutDetailView start date picker now constrained to not exceed end date

## [0.6.0] - 02/14/26

### Added
- Calendar view — monthly calendar grid embedded at the top of the History tab's Workouts segment
- Workout day indicators (accent-colored dots) on calendar days with logged workouts
- Date filtering — tap a calendar day to filter the workout list to that day's sessions
- Month navigation with chevron buttons (past months only, future months disabled)
- Backdated workout creation — select any past day and add a workout that opens in edit mode
- Today highlighting with muted accent circle background
- "Clear" pill button (orange) in list header to reset date filter
- "+ Add Workout" prompt when selecting a day with no workouts
- `CalendarDay` model with day number, month membership, today/future flags, and workout indicator
- `CalendarView` and `CalendarDayCell` components
- `canGoToNextMonth` computed property to prevent future month navigation
- 12 new calendar unit tests (grid structure, today marking, date selection, filtering, month navigation)

### Changed
- HistoryView workout list now shows calendar card above workout rows
- Workout rows display accent-colored icons for duration and exercise count
- WorkoutDetailView accepts `initiallyEditing` parameter for backdated workouts
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

## [0.5.0] - 02/14/26

### Added
- Progress charts & analytics — segmented "Progress" view within the History tab
- Workout frequency bar chart (weekly count over time, gradient accent bars)
- Muscle group donut chart with color-coded legend (7 groups)
- Strength progression line/area chart with per-exercise max weight over time
- Summary stat cards: workouts this month, total volume, day streak, personal records
- Time range filter (1M, 3M, 6M, 1Y, All) for all progress data
- Exercise favorites — star up to 10 strength exercises in library or detail panel
- Favorites prioritized in progress charts exercise picker
- `ProgressViewModel` with volume formatting, streak calculation, PR detection
- 3 new chart color tokens: chartPurple, chartBlue, chartPink
- Comprehensive `ProgressViewModelTests` (20 tests) and favorites unit tests

### Changed
- History tab now uses segmented control (Workouts | Progress)
- Exercise model gains `isFavorite` property
- ExerciseLibraryViewModel gains `toggleFavorite` with 10-favorite limit
- ExerciseDetailView toolbar now includes star button for favorites
- ExerciseLibraryView rows now show star toggle for strength exercises
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs
- UI test fix for tab bar button matching

## [0.4.0] - 02/13/26

### Added
- Workout template system — save, create, edit, and start workouts from reusable templates
- `WorkoutTemplate` and `TemplateExercise` SwiftData models with full relationship support
- `TemplateViewModel` with CRUD operations, create-from-workout, exercise reordering
- Template card UI component with muscle group pills and exercise count
- Templates tab in main navigation (4-tab layout)
- Create template from completed workout in workout detail view
- Start workout from template with pre-filled sets (uses template defaults, falls back to last session)
- Comprehensive unit test suite — 89 tests across 14 suites covering all models and ViewModels
- Claude skills for generating unit tests and UI tests

### Changed
- `ContentView` expanded from 3-tab to 4-tab layout with Templates tab
- `AddExerciseView` and `ExerciseLibraryView` refactored for template integration
- Updated `DataService` schema to include template models
- Updated README, PROJECT_BRIEF, DESIGN, and FUTURE_FEATURES docs

## [0.3.0] - 02/10/26

### Added
- App rebrand from "GymApp" to **Pulse** with new bundle ID (`com.pulse.Pulse`)
- Custom app icon (dumbbell on dark background, 1024x1024 PNG)
- Horizontal logo lockup image asset (`Logo.imageset`)
- Animated splash screen — logo fades in centered, holds briefly, then shrinks and slides into its resting position on the Workout tab
- Logo displayed on Workout tab empty state in place of generic SF Symbol
- Text and button fade-in on Workout tab timed with splash completion

### Changed
- Renamed all directories, files, and references from GymApp to Pulse
- Updated `project.yml`, `scripts/restart.sh`, and build skill for new Pulse scheme
- Updated README, PROJECT_BRIEF, and DESIGN docs with branding, splash screen, and logo details

## [0.2.0] - 02/10/26

### Added
- Rest timer with auto-start on set completion (configurable per exercise)
- Floating timer pill overlay with countdown, progress ring, and skip button
- Expanded timer sheet with large progress ring, +30s/-30s adjustment, and skip controls
- Local notification when timer completes while app is backgrounded
- Haptic feedback and completion sound on timer finish
- Per-exercise rest time configuration in Exercise Detail view (pill button picker)
- Inline rest time badge and picker during active workouts
- Background-aware timer using wall-clock dates (timer continues when app is backgrounded)
- `defaultRestSeconds` property on Exercise model with sensible defaults (45s-120s by strength type, null for cardio)
- `exercises.json` seed data file with rest durations for all 51 exercises
- New design system components: CircularActionButton, CircularProgressRing, RestTimerView
- New design system components: StatCard, FeaturedStatCard, StatGrid, PillButton, ProgressBar
- New AppTheme tokens: accentMuted, featuredSurface, featuredGradientEnd, chartActive, chartInactive

### Changed
- Exercise detail sheet now uses full-height `.large` detent instead of `.medium`/`.large`
- Circular progress ring drains (unfills) as time decreases
- Updated README, PROJECT_BRIEF, and DESIGN docs with rest timer feature and new components

### Fixed
- Delete button no longer bleeds through completed set background tint on SetRowView

## [0.1.0] - 02/09/26

### Added
- Edit completed workouts (change time, add/remove sets, modify weight/reps, update cardio)
- Exercise detail panel with how-to instructions and recent workout history
- Cardio logging with dedicated time/distance inputs
- Auto-navigate to workout detail after finishing
- Cancel workout with confirmation dialog
- Exercise instructions service with step-by-step guides
- Custom exercise creation
- FUTURE_FEATURES.md planning doc

### Changed
- Only completed sets are saved when finishing a workout; incomplete sets and empty exercises are discarded
- SetRowView checkmark button is now optional (hidden in history edit mode)
- Tab navigation uses programmatic selection for cross-tab navigation
- Updated README, PROJECT_BRIEF, and DESIGN docs to reflect delivered features

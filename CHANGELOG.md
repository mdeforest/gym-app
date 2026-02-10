# Changelog

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

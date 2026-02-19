# DESIGN.md

> A living document capturing the visual, UX, and architectural design of Pulse.

---

## 1. Visual Design System

### Color Palette

Dark mode by default. Bold, premium aesthetic with warm orange accent. Colors follow iOS semantic naming conventions.

| Role                    | Color         | Usage                                                        |
|-------------------------|---------------|--------------------------------------------------------------|
| Primary (Accent)        | `#FF6A3D`     | Buttons, active states, highlights, links                    |
| Accent Muted            | `#FF6A3D33`   | Accent at 20% opacity — inactive states, subtle highlights, completed-set tint |
| Background              | `#000000`     | Main app background (true black, OLED)                       |
| Surface (Elevated)      | `#1C1C1E`     | Cards, bottom sheets, grouped backgrounds                    |
| Surface (Tertiary)      | `#2C2C2E`     | Input fields, secondary cards, dividers                      |
| Featured Surface        | `#FF6A3D`     | Hero/featured stat card background (solid accent fill)       |
| Featured Gradient End   | `#E8552B`     | Darker end of gradient on featured cards (top-left to bottom-right) |
| Text (Primary)          | `#FFFFFF`     | Headings, body text, primary labels                          |
| Text (Secondary)        | `#EBEBF599`   | Captions, placeholder text, metadata (60% opacity)           |
| Destructive             | `#FF453A`     | Delete actions, error states                                 |
| Success                 | `#30D158`     | Set completion checkmarks, confirmation toasts, save indicators |
| Warning                 | `#FFB340`     | Caution states                                               |
| Chart Active            | `#FF6A3D`     | Active/current bars in charts                                |
| Chart Inactive          | `#3D2A1F`     | Muted warm brown for inactive/past bars in charts            |
| Chart Purple            | `#5E5CE6`     | Arms segment in muscle group donut chart, superset accent (bracket, labels, link buttons) |
| Chart Blue              | `#64D2FF`     | Legs segment in muscle group donut chart                     |
| Chart Pink              | `#FF6482`     | Core segment in muscle group donut chart                     |

> **Note on Accent vs. Destructive**: `#FF6A3D` (warm coral-orange) and `#FF453A` (cooler red) are visually distinct but share a warm hue family. Destructive actions should always include contextual cues (trash icons, alert dialogs, "Delete"/"Discard" labels) beyond color alone.

### Typography

- **Font Family**: SF Pro (system font) — ensures consistency with iOS and automatic Dynamic Type support
- **Size Scale**:

| Style        | Size   | Weight     | Usage                                    |
|--------------|--------|------------|------------------------------------------|
| Hero Display | 40pt   | Bold       | Large stat numbers on featured cards (volume, PR weight) |
| Large Title  | 36pt   | Bold       | Screen titles (History, Library)         |
| Title 2      | 24pt   | Bold       | Section headers                          |
| Headline     | 17pt   | Bold       | Exercise names, card titles              |
| Body         | 17pt   | Regular    | General text, descriptions               |
| Callout      | 16pt   | Medium     | Set data (weight, reps)                  |
| Subheadline  | 15pt   | Regular    | Secondary labels                         |
| Stat Label   | 13pt   | Medium     | Unit labels below hero numbers ("LBS", "REPS", "MIN"). Uppercase, 1pt letter spacing. |
| Footnote     | 13pt   | Regular    | Timestamps, metadata                     |
| Caption      | 12pt   | Regular    | Hints, tertiary info                     |

- **Dynamic Type**: Fully supported. Standard styles use SwiftUI's built-in text styles (`.largeTitle`, `.headline`, `.body`, etc.). Custom styles (Hero Display, Stat Label) use `UIFontMetrics`-scaled values so they respond to accessibility size changes.

### Iconography

- **Icon Set**: SF Symbols (Apple's native system icons)
- **Guidelines**:
  - Use **semibold weight** icons to match the bolder typography
  - On featured/hero cards, use **bold weight** icons at 24–28pt to match the card's visual impact
  - Prefer **filled** variants for tab bar icons (active state) and **outline** variants for inactive states
  - Icon size should match the adjacent text's point size
  - Accent-colored icons use `#FF6A3D`; icons on Featured Surface cards use white
  - Use SF Symbols' built-in rendering modes (monochrome with accent color)

### Branding Assets

- **App Icon**: Custom dumbbell icon on dark charcoal background. Orange accent color matching `#FF6A3D`. 1024×1024 PNG, full-bleed (no transparency). Stored in `Assets.xcassets/AppIcon.appiconset/`.
- **Logo**: Horizontal lockup — icon mark + "PULSE" wordmark in white on transparent/black background. Used on the splash screen and Workout tab empty state. Stored in `Assets.xcassets/Logo.imageset/`.

---

## 2. Layout System

- **Framework**: SwiftUI native layout (`VStack`, `HStack`, `LazyVStack`, `LazyVGrid`, `ScrollView`)
- **Safe Areas**: Always respect safe area insets; content never renders behind the notch or home indicator
- **Spacing Scale**: Multiples of 4pt (4, 8, 12, 16, 20, 24, 32, 40)
- **Content Width**: Full-width on all devices — no max-width constraint (single-column mobile layout)
- **Minimum Touch Target**: 44×44pt per Apple Human Interface Guidelines
- **Card Padding**: 20pt internal padding, 12pt gap between cards
- **Screen Edge Padding**: 20pt horizontal padding from screen edges
- **Section Spacing**: 32pt vertical space between major sections

---

## 3. Components

| Component              | Spec                                                                                         | File                                    | Status |
|------------------------|----------------------------------------------------------------------------------------------|-----------------------------------------|--------|
| **Primary Button**     | Full-width, 52pt height, `#FF6A3D` fill, white label, pill-shaped (26pt corner radius), bold text. Optional trailing `chevron.right` icon for navigation-style actions. | `Views/Components/PrimaryButton.swift`  | Needs update |
| **Secondary Button**   | Full-width, 52pt height, `#2C2C2E` fill, white label, 16pt corner radius                    | `Views/Components/SecondaryButton.swift`| Needs update |
| **Destructive Button** | Full-width, 52pt height, `#FF453A` fill, white label, 16pt corner radius                    | `Views/Components/DestructiveButton.swift` | Needs update |
| **Pill Button**        | Auto-width (not full-width), 36pt height, pill-shaped (18pt corner radius). Primary variant: `#FF6A3D` fill. Secondary variant: `#2C2C2E` fill. White label with optional leading/trailing SF Symbol icon. For inline actions like "+ Add Set", "View All". | `Views/Components/PillButton.swift` | Done |
| **Set Row**            | Horizontal row: set number (tappable to toggle warm-up/normal), weight field, reps field, optional checkmark button, optional RPE badge. Pre-filled from last session. Tap field to edit via numeric keypad. Swipe left to reveal delete button. Editing values propagates to subsequent incomplete sets of the same type. Checkmark is hidden when `onComplete` is nil (e.g., in history edit mode). Confirmed sets get a subtle `#FF6A3D` at 8% opacity background tint. Warm-up sets show "W" in warning color (`#FFB340`) with warm-up-specific tint when completed. RPE badge appears after checkmark when set. | `Views/Components/SetRowView.swift` | Done |
| **Exercise Card**      | Surface (`#1C1C1E`) background, 16pt corner radius, 20pt padding, 12pt gap between cards. Shows exercise name (headline, bold) and last session summary (subheadline, secondary text). | `Views/Components/ExerciseCard.swift` | Needs update |
| **Number Input**       | `#2C2C2E` background, 12pt corner radius, centered text (callout, medium weight), numeric keyboard. Tap to select all for quick overwrite. | `Views/Components/NumberInputField.swift` | Needs update |
| **Stat Card**          | Single metric display for 2-column grids. `#1C1C1E` surface background, 16pt corner radius, 20pt internal padding, 100pt minimum height. Contains: Hero Display number (40pt bold, white) and Stat Label below (13pt medium, uppercase, secondary text color). Optional SF Symbol icon (top-right, 20pt, secondary color). | `Views/Components/StatCard.swift` | Done |
| **Featured Stat Card** | Same layout as Stat Card but with `#FF6A3D` solid fill (or linear gradient to `#E8552B`, top-left to bottom-right). White text for both number and label. 20pt corner radius. Used for primary metrics like "Total Volume" or "Personal Record". Optional icon badge in top-right (white, bold weight). | `Views/Components/FeaturedStatCard.swift` | Done |
| **Stat Grid**          | 2-column `LazyVGrid` with 12pt spacing between items. Each cell is a Stat Card or Featured Stat Card. Full-width with screen edge padding. | `Views/Components/StatGrid.swift` | Done |
| **Workout Summary Header** | Full-width section at the top of workout detail views. Contains a Stat Grid with 2–4 metrics (Duration, Exercises, Sets, Volume). Primary metric uses Featured Stat Card; others use standard Stat Cards. | — | Not yet built |
| **Progress Bar**       | Horizontal bar showing workout/exercise completion. Full width, 6pt height, 3pt corner radius. Track: `#2C2C2E`. Fill: linear gradient `#FF6A3D` to `#E8552B`. | `Views/Components/ProgressBar.swift` | Done |
| **Circular Action Button** | 64pt circle. Primary variant: `#FF6A3D` fill, white icon (e.g., `play.fill`, `pause.fill`). Secondary variant: `#2C2C2E` fill, white icon. Destructive variant: `#FF453A` fill, white icon. For rest timer controls. | `Views/Components/CircularActionButton.swift` | Done |
| **Rest Timer Pill (Collapsed)** | Floating bar anchored to bottom of `ActiveWorkoutView`, above tab bar. Full-width minus screen edge padding (20pt each side). 52pt height, pill-shaped (26pt corner radius). `#1C1C1E` surface background with shadow. Contains: circular progress ring (28pt, 3pt stroke, accent gradient), countdown text (`title2` bold, white, monospacedDigit `M:SS`), exercise name (subheadline, secondary), skip button (`xmark`, secondary text, 44pt touch target). Tap pill to expand. Slides up with spring animation on timer start; slides down on dismiss. | `Views/Components/RestTimerView.swift` | Done |
| **Rest Timer Sheet (Expanded)** | Bottom sheet overlay when collapsed pill is tapped. `#1C1C1E` surface background, 20pt corner radius (top corners only), drag indicator at top. Contains: large circular progress ring (160pt diameter, 6pt stroke, accent-to-`#E8552B` gradient on `#2C2C2E` track), countdown in center (Hero Display 40pt bold), "REST" stat label (13pt medium, uppercase), row of 3 Circular Action Buttons: −30s (secondary), +30s (secondary), Skip (destructive). Exercise name context label below (subheadline, secondary text). | `Views/Components/RestTimerView.swift` | Done |
| **Circular Progress Ring** | Configurable size/stroke. Track: `#2C2C2E` stroke. Fill: accent-to-`#E8552B` linear gradient, round line cap, −90° rotation. Ring drains (unfills) as time decreases. Used in rest timer at 28pt (pill) and 160pt (expanded sheet). | `Views/Components/CircularProgressRing.swift` | Done |
| **Rest Time Picker** | Horizontal `ScrollView` of capsule pill buttons: Off, 30s, 60s, 90s, 2m, 3m. Selected: `#FF6A3D` fill, white text. Unselected: `#2C2C2E` fill, secondary text. Used in Exercise Detail and inline during active workout (via tappable rest time badge). | Inline in views | Done |
| **Template Card**      | Surface (`#1C1C1E`) background, 16pt corner radius, 20pt padding. Shows template name (headline, bold), exercise count (subheadline, secondary), and muscle group pills (capsule badges with accent text on tertiary background). Tappable to view detail. Context menu: View Details, Start Workout, Edit, Delete. Template detail shows per-set configurations with warm-up (W) and working set indicators, individual weight and reps. | `Views/Components/TemplateCardView.swift` | Done |
| **Calendar View**      | Monthly calendar grid (7-column `LazyVGrid`) inside a surface card. Month header: chevron.left, "Month Year" (title3 bold), chevron.right. Weekday row: `shortWeekdaySymbols` (Sun–Sat) in caption/secondary. Day cells: 36pt circle frame with day number. Selected: accent circle + white text. Today: `accentMuted` circle. Workout day: 5pt accent dot below number. Out-of-month/future days: dimmed (30% opacity), disabled. Forward chevron disabled when viewing current month. | `Views/History/CalendarView.swift` | Done |
| **Calendar Day Cell**  | Button wrapping VStack of day number + workout dot. `.buttonStyle(.borderless)` for List compatibility. Accent circle background when selected, `accentMuted` when today, clear otherwise. Dot hidden when selected. Disabled for out-of-month and future days. | `Views/History/CalendarDayCell.swift` | Done |
| **Profile Avatar**     | 40pt circle, `#2C2C2E` fill. Shows user's initials (15pt bold, white) if a name is set via `@AppStorage("userName")`; otherwise shows `person.fill` SF Symbol (18pt semibold, secondary text). Positioned top-right of Workout tab via overlay. Taps open Settings sheet. Hidden during active workout. | `Views/Workout/WorkoutView.swift` | Done |
| **Settings View**      | Modal `NavigationStack` with `.insetGrouped` list style. True black background. "Done" button (semibold, accent) in toolbar. Three sections: Profile (via `ProfileSectionView`), Health (via `HealthSectionView`), and Data Management (via `DataManagementSectionView`). ViewModel lazily initialized on appear. | `Views/Settings/SettingsView.swift` | Done |
| **Profile Section**    | List section with "Profile" header. Name field (`person.fill` icon, trailing text field), Body Weight field (`scalemass.fill` icon, decimal pad, trailing unit label), Weight Unit picker (lbs/kg segmented). All values persisted via `@AppStorage`. | `Views/Settings/ProfileSectionView.swift` | Done |
| **Health Section**     | List section with "Apple Health" header (`heart.fill` icon). Toggle to enable/disable Apple Health sync (`@AppStorage`). Authorization status row with color-coded indicator (green=authorized, orange=not requested, red=denied). When denied, tappable link to open system Settings. Fetches latest body weight from HealthKit on appear if enabled. | `Views/Settings/HealthSectionView.swift` | Done |
| **Data Management Section** | Two list sections. Export Data: format picker (CSV/JSON), "Export Workout Data" button (`square.and.arrow.up` icon) that generates export via `ExportService` and presents iOS share sheet. Bottom section: version info row (`info.circle` icon), "Clear All Data" destructive button with confirmation alert and success alert. | `Views/Settings/DataManagementSectionView.swift` | Done |
| **Tab Bar**            | Standard iOS tab bar, 4 tabs: Workout (`dumbbell.fill`), History (`clock.fill`), Exercises (`list.bullet`), Templates (`doc.on.doc`). True black background, `#FF6A3D` tint. | `App/ContentView.swift` | Done |
| **Workout Frequency Chart** | Bar chart (Swift Charts `BarMark`) showing weekly workout count over time. Gradient bars (accent → `#E8552B`). X-axis: week dates. Y-axis: workout count. Adaptive x-axis stride based on data density. `#1C1C1E` card surface, 16pt corner radius. | `Views/History/Charts/WorkoutFrequencyChart.swift` | Done |
| **Muscle Group Chart** | Donut chart (Swift Charts `SectorMark`) showing exercise distribution by muscle group. Inner radius 0.6, 2pt angular inset. Per-group colors: Chest=accent, Back=success, Shoulders=warning, Arms=chartPurple, Legs=chartBlue, Core=chartPink, Cardio=textSecondary. 2-column legend below chart with color dot, name, and percentage. | `Views/History/Charts/MuscleGroupChart.swift` | Done |
| **Strength Progression Chart** | Area + line chart (Swift Charts `AreaMark`/`LineMark`/`PointMark`) showing max weight over time for a selected exercise. Catmull-Rom interpolation. Gradient fill (accent at 30% → transparent). Point marks color-coded by average RPE when available (green/yellow/red). Warm-up sets excluded from data. When fewer than 2 data points, shows best-set fallback or "no data" message. | `Views/History/Charts/StrengthProgressionChart.swift` | Done |
| **Time Range Filter** | Horizontal `ScrollView` of `PillButton`s: 1M, 3M, 6M, 1Y, All. Selected: primary style. Unselected: secondary style. Used at the top of the progress charts view. | Inline in `Views/History/ProgressView.swift` | Done |
| **Toast**              | Floating pill at bottom of screen above tab bar, auto-dismisses after 3 seconds. Dark surface background with white text. Slide-up animation. Pill-shaped corners. | — | Not yet built |
| **Section Header**     | Title 2 weight (24pt bold), left-aligned, 32pt top margin, 8pt bottom margin               | Used inline in views | Needs update |
| **Empty State**        | Centered text (secondary color) with SF Symbol icon above (semibold weight), and a primary action button below (pill-shaped). On the Workout tab, the Logo image (`Image("Logo")`, 180pt width) replaces the SF Symbol. | `Views/Components/EmptyStateView.swift` | Done |
| **Exercise Detail**    | Full-height bottom sheet (`.large` detent) with drag indicator. Toolbar: star button (top-left, strength exercises only, max 10 favorites) and "Done" button. Header shows muscle group badge (`#FF6A3D` capsule fill) + custom tag. How-to section: description, primary muscles (in accent color), numbered steps. Rest Timer section: "Rest Timer" headline, subtitle, horizontal Rest Time Picker pills. History section: last 5 sessions with sets/reps/weight (or time/distance for cardio). | `Views/ExerciseLibrary/ExerciseDetailView.swift` | Done |
| **Cardio Inputs**      | Two-row layout inside workout exercise section: clock icon + minutes field, run icon + km field. Replaces weight/reps for exercises flagged as cardio. | Inline in `ActiveWorkoutView.swift` | Done |
| **Splash Screen**      | Full-screen overlay on app launch. True black background. Logo (`Image("Logo")`) starts centered at 320pt width, fades in over 1s, holds for ~1.5s. Then background fades to transparent while logo shrinks to 180pt and slides up ~60pt (spring animation, 0.9s). Logo fades out last, revealing the Workout tab with its own logo in place. Text and button on Workout tab fade in simultaneously. Total duration ~3.4s. | `Views/Components/SplashView.swift` | Done |
| **RPE Badge**          | Compact capsule pill displaying RPE value. Shows "RPE" placeholder when nil, "RPE 8" when set. Color-coded: 6–7 green (success), 7.5–8.5 yellow (warning), 9–10 red (destructive). Tappable with `.buttonStyle(.borderless)`. Used in set rows and read-only history views. | `Views/Components/RPEBadgeView.swift` | Done |
| **RPE Picker**         | Inline horizontal picker appearing below a set row. Row of capsule pills: 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10. Each pill color-coded by RPE range. Selected pill: full opacity + white border ring. Unselected: 0.4 opacity. Dismisses on selection. Animated in/out with opacity + move transition. | `Views/Components/RPEPickerView.swift` | Done |
| **Superset Group**     | Visual wrapper for 2+ linked exercises. Purple bracket (4pt wide `RoundedRectangle` in `chartPurple`) on the left edge. "SUPERSET" label (caption bold, `chartPurple`, 1pt kerning) in header. Optional reorder buttons (arrow.up/down.circle.fill) in header when provided. Contains exercise sections with dividers between them. Surface background with standard corner radius. | `Views/Workout/SupersetGroupView.swift` | Done |
| **Superset Link Label** | Button label shown between exercise groups for linking as superset. Purple pill capsule with link icon + "Link" text in `chartPurple`, on 15% opacity purple background. Flanked by subtle purple connector lines. Full-width with screen edge padding. | `Views/Components/SupersetLinkLabel.swift` | Done |

### Design Tokens

All design tokens are centralized in `Theme/AppTheme.swift`:

- `AppTheme.Colors` — accent, accentMuted, background, surface, surfaceTertiary, featuredSurface, featuredGradientEnd, textPrimary, textSecondary, destructive, success, warning, chartActive, chartInactive, chartPurple, supersetAccent (alias for chartPurple), chartBlue, chartPink
- `AppTheme.Spacing` — xxs (4), xs (8), sm (12), md (16), lg (20), xl (24), xxl (32), xxxl (40)
- `AppTheme.Layout` — cornerRadius (16), featuredCardRadius (20), pillButtonRadius (26), buttonHeight (52), circularButtonSize (64), minTouchTarget (44), cardPadding (20), cardSpacing (12), screenEdgePadding (20), statCardMinHeight (100), statGridSpacing (12), sectionSpacing (32)

---

## 4. UX Flows

> Visual note: All accent-colored elements (button fills, active states, highlights, badges) use `#FF6A3D`. Workout summaries use Stat Grid and Featured Stat Card components for bold, stats-forward presentation.

### App Launch
1. Animated splash screen appears — Pulse logo fades in centered at 320pt on true black
2. After ~2.5s, the background fades to transparent and the logo shrinks (320pt → 180pt) and slides upward toward its resting position on the Workout tab
3. The Workout tab is revealed underneath; title text, subtitle, and "Start Workout" button fade in simultaneously
4. Splash overlay is removed once the transition completes (~3.4s total)

### Start Workout
1. User taps the **Workout** tab — the Pulse logo is displayed above "Ready to Train?" with two buttons: **Start Empty Workout** and **Browse Templates**
2. Taps **Start Empty Workout** (primary button) → empty session created with current timestamp, user taps **Add Exercise** to begin
3. OR taps **Browse Templates** → switches to the Templates tab to pick a saved routine

### Add Exercise to Workout
1. Full-screen modal slides up
2. **Search bar** at top — filters exercise list as the user types
3. **Category tabs** below search (All, Chest, Back, Shoulders, Arms, Legs, Core, Cardio)
4. Exercise list filtered by selected category; recently-used exercises pinned at top under "Recent" section
5. Tap an exercise → added to the current workout, modal dismisses

### Log Sets (Strength)
1. After adding a strength exercise, set rows appear pre-filled with last session's values (weight + reps)
2. User taps a number field to adjust → numeric keypad appears, value is auto-selected for quick overwrite
3. Editing a set's weight or reps auto-propagates the values to all subsequent incomplete sets of the same type
4. User taps the **checkmark** button on the row to confirm the set — row gets subtle accent background tint
5. Tap the **set number** to toggle between normal and warm-up. Warm-up sets show "W" in warning color and get a warning-tinted background when completed. Warm-up sets are excluded from progress stats.
6. After confirming a set, tap the **RPE badge** to rate effort. An inline picker appears below the row with color-coded pills (6–10 in 0.5 increments). Tap a value to set; picker auto-dismisses.
7. Tap **+ Add Set** (pill button) to add another row (pre-filled with the same weight/reps as the previous set)
8. Swipe left on a set row to reveal a delete button (hidden when only 1 set remains)
9. Logging a set takes 2-3 taps when values don't change from last session

### Log Cardio
1. After adding a cardio exercise (Running, Cycling, etc.), time and distance inputs appear instead of set rows
2. Two fields: minutes (clock icon) and km (run icon), pre-filled from last session if available
3. No set/rep concept — just duration and distance

### Rest Timer
1. User completes a set by tapping the checkmark — if the exercise has a `defaultRestSeconds` value configured (non-nil), the rest timer auto-starts with that duration
2. A floating timer pill slides up from the bottom of `ActiveWorkoutView` showing a countdown (`M:SS`), small circular progress ring, exercise name, and a skip (X) button
3. Tapping the pill expands it into a larger sheet with a big circular progress ring, the countdown, and adjustment buttons (−30s, +30s, Skip)
4. The user can adjust the timer at any time; −30s/+30s buttons modify remaining time (never below 0). The progress ring and countdown update in real time
5. When the timer reaches 0:00, a haptic buzz and short completion sound play; the pill shows "Rest Complete" briefly (1.5s) before auto-dismissing
6. If the app is backgrounded, a local notification fires when the timer completes ("Rest Complete — time to start your next set")
7. Completing another set while a timer is running resets to the new exercise's rest duration (or continues unchanged if the new exercise has no rest configured)
8. The timer is purely UI state — it does not persist. The local notification is scheduled when the timer starts and canceled on skip/dismiss
9. Each exercise section header shows a small rest time badge (e.g., "90s") when configured. Tapping the badge during a workout opens an inline Rest Time Picker to change the value

### Supersets
1. After adding 2+ exercises, a purple **Link** pill button appears between each exercise group
2. Tap the Link button to combine the two adjacent exercises (or groups) into a superset
3. Superset groups render with a purple bracket on the left and a "SUPERSET" header label
4. Each exercise within a superset has a purple link icon — tap it to access "Remove from Superset" option
5. Rest timer only starts after completing a set on the **last** exercise in the superset group
6. Exercises and superset groups can be reordered via **arrow up/down** buttons in each card/group header
7. Supersets are preserved when saving a workout as a template and restored when starting from that template

### Finish Workout
1. User taps **Finish** button in the navigation bar
2. Centered alert prompt: "Finish workout?" with message "This will save your workout to history."
3. Incomplete sets are discarded; exercises with no completed sets are removed
4. Workout saved with timestamp and duration
5. App switches to the **History** tab and auto-navigates to the completed workout's detail view, which displays the **Workout Summary Header** with stat cards

### Cancel Workout
1. User taps **Cancel** button (red, top-left) in the navigation bar
2. Centered alert prompt: "Discard Workout?" with message "This will delete all exercises and sets from this workout."
3. User confirms with "Discard" (destructive) or cancels with "Keep Training"
4. If discarded, workout is deleted and view returns to "Ready to Train?" empty state

### View Exercise Detail
1. User taps any exercise in the **Exercises** tab
2. A full-height bottom sheet appears (`.large` detent) with drag indicator
3. **Toolbar**: Star button (top-left) to toggle favorite status on strength exercises (max 10 favorites); "Done" button (top-right)
4. **Header**: Muscle group badge (orange accent capsule) and optional "Custom" tag
5. **How to Perform**: Description, primary muscles (in accent color), and numbered step-by-step instructions
6. **Rest Timer**: Configurable rest duration with pill button picker (Off, 30s, 60s, 90s, 2m, 3m)
7. **Recent History**: Last 5 sessions showing date and sets (weight × reps), or time/distance for cardio
8. Custom exercises show "No instructions available" in the how-to section

### View History
1. User taps the **History** tab — a segmented control at the top toggles between **Workouts** and **Progress**
2. **Workouts segment**: A list header ("All Workouts" or selected date with orange "Clear" pill) sits above a monthly **Calendar View** card. Below the calendar, workout rows are listed by date (most recent first), showing date, duration (with accent clock icon), and exercise count (with accent dumbbell icon). Tap a workout → detail view with **Workout Summary Header** (stat grid) followed by all exercises, sets, weights, and reps
3. **Calendar interaction**: Tap a day with a workout dot → filters the list to that day's sessions. Tap the same day again → deselects, shows all workouts. Navigate months with chevron buttons (forward disabled on current month). Select a past day with no workouts → "No workouts on this day" prompt with "+ Add Workout" button to create a backdated workout (opens in edit mode)
4. **Progress segment**: Shows the Progress Charts view (see below)

### View Progress Charts
1. User switches to the **Progress** segment in the History tab
2. **Time range filter** — horizontal pill buttons (1M, 3M, 6M, 1Y, All) filter all data below
3. **Summary stats** — Stat Grid with 4 cards: workouts this month (Featured Stat Card), total volume lifted, day streak, and personal records
4. **Workout Frequency chart** — bar chart showing weekly workout count over the selected time range, with gradient accent bars
5. **Muscle Group chart** — donut chart showing exercise distribution by muscle group with color-coded legend
6. **Strength Progression chart** — line/area chart tracking max weight over time for a selected exercise. Exercise picker (horizontal pill buttons) above the chart; favorites are shown first (up to 10), otherwise all used exercises. When fewer than 2 sessions exist, shows a single "best set" stat or "no data" message
7. Empty state shown when no completed workouts exist yet

### Edit Completed Workout
1. User opens a workout from the **History** tab
2. Taps **Edit** button in the navigation bar (top-right, accent color)
3. View switches to edit mode:
   - **Date pickers** appear at top for start and end time (end constrained to after start)
   - **Duration** in summary header updates live as dates change
   - **Strength exercises**: Set rows become editable via `SetRowView` (no checkmarks shown). Swipe left to delete sets; tap **+ Add Set** to add new sets. Tap set number to toggle warm-up.
   - **Cardio exercises**: Duration and distance fields become editable via `NumberInputField`
   - **Reorder exercises**: Arrow up/down buttons in each exercise card header (and superset group header)
   - **Supersets**: Purple Link pill buttons between exercise groups to create supersets; link icon on superset members to remove from group
   - **Remove exercise**: X button appears on each exercise header
   - **Add exercise**: **+ Add Exercise** button appears at the bottom, opening the standard exercise picker sheet
4. Taps **Done** to apply date changes and exit edit mode. Set and exercise edits are saved immediately via SwiftData.

### Workout Templates
1. User taps the **Templates** tab — shows a list of saved templates (sorted by last used, then created date), or an empty state with a "Create Template" button
2. Tap **+** in the toolbar or the empty state button → **Create Template** sheet appears
3. Enter a template name and tap **+ Add Exercise** to add exercises from the exercise library
4. For each exercise: configure individual sets with weight, reps, and warm-up/normal type. Add or remove sets per exercise. Cardio exercises show duration (min) and distance (km) inputs instead.
5. Tap **Save** to save the template; tap **Cancel** to discard
6. Tap a template card → **Template Detail** sheet shows exercise list with per-set breakdown (warm-up sets marked with "W" in warning color, working sets with weight × reps) plus **Start Workout** and **Edit/Delete** actions
7. Tap **Start Workout** → switches to Workout tab, creates a new workout pre-populated with the template's exercises and individual set configurations (weight, reps, warm-up/normal type). Falls back to last-session values when template defaults are absent. Superset grouping is preserved. Template's `lastUsedDate` is updated.
8. Long-press a template card → context menu: View Details, Start Workout, Edit, Delete

### Settings
1. User taps the **profile avatar** (top-right circle) on the Workout tab — a Settings sheet slides up
2. **Profile section**: Name text field, body weight with decimal pad, weight unit picker (lbs/kg). All values persist via `@AppStorage`
3. **Health section**: Toggle to enable/disable Apple Health sync. Shows authorization status (color-coded: green for authorized, orange for not requested, red for denied). When denied, provides a link to open system Settings. Fetches latest body weight from HealthKit when enabled. Completed workouts are automatically synced to Apple Health when the toggle is on.
4. **Export Data section**: Format picker (CSV or JSON), then "Export Workout Data" button. Tapping generates the export file via `ExportService` and presents the iOS share sheet
5. **Bottom section**: Version info row showing app version and build number. "Clear All Data" destructive button with two-step confirmation — first an alert ("This will permanently delete all workouts, templates, and custom exercises"), then a success alert after clearing
6. Clear All Data deletes all workouts, templates, and custom exercises. Built-in exercises have their `lastUsedDate` and `isFavorite` reset
7. Tap **Done** to dismiss the settings sheet

### Save Workout as Template
1. User opens a completed workout from the **History** tab
2. Taps the **Save as Template** icon (`rectangle.stack.badge.plus`) in the toolbar
3. **Create Template** sheet appears pre-populated with the workout's exercises and exact set configurations (individual weight, reps, and warm-up/normal type for each completed set). Superset grouping is preserved.
4. User names the template and optionally adjusts individual sets, then taps **Save**

### Error States
- **Failed to save**: Toast appears at bottom — "Couldn't save. Try again." with a retry action
- **No exercises found** (search): Inline empty state — "No exercises found" with option to create a custom exercise
- **Empty history**: Centered empty state — "No workouts yet" with illustration and "Start Workout" pill button

---

## 5. Accessibility

- **Dynamic Type**: All text uses SwiftUI semantic text styles; layout adapts to larger accessibility sizes. Custom styles (Hero Display, Stat Label) use `UIFontMetrics` scaling.
- **VoiceOver**: All interactive elements have descriptive accessibility labels (e.g., "Set 1: 135 pounds, 8 reps — tap to edit")
- **Contrast Ratios**: White text on true black exceeds WCAG AAA (21:1). Orange accent (`#FF6A3D`) on black meets WCAG AA for large text (5.2:1 contrast ratio). White text on Featured Surface (`#FF6A3D`) meets WCAG AA for large/bold text only (3.2:1) — Featured Stat Cards exclusively use Hero Display (40pt bold) and Stat Label (13pt bold uppercase), which qualify as large text.
- **Focus States**: Interactive elements show a visible focus ring when navigated via keyboard or switch control
- **Haptic Feedback**: Light haptic on set confirmation, medium haptic on workout finish, success notification haptic + sound on rest timer completion
- **Rest Timer**: VoiceOver reads countdown as "X minutes, Y seconds remaining". Skip button labeled "Skip rest timer". Timer completion announced via `UIAccessibility.post` notification.
- **Reduce Motion**: Respect `UIAccessibility.isReduceMotionEnabled` — disable slide/spring animations when enabled

---

## 6. Inspirations / References

- **PacePro** — bold, stats-forward design with warm orange accent, dramatic typography hierarchy, and premium card-based layouts. Primary inspiration for the current visual direction.
- **Strong (iOS)** — clean workout logging interface, set-by-set input pattern
- **Hevy** — prominent stat displays and workout summary cards with large numbers and clear visual hierarchy
- **JEFIT** — comprehensive exercise library with muscle group categorization
- **Plain spreadsheet** — the simplicity benchmark; logging should feel as fast as typing into a spreadsheet row
- **Apple Fitness** — dark UI patterns, native iOS design language

---

> Keep this document updated as designs evolve.

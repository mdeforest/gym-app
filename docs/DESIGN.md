# DESIGN.md

> A living document capturing the visual, UX, and architectural design of the Gym App.

---

## 1. Visual Design System

### Color Palette

Dark mode by default. Colors follow iOS semantic naming conventions.

| Role              | Color     | Usage                                      |
|-------------------|-----------|--------------------------------------------|
| Primary (Accent)  | `#30D158` | Buttons, active states, highlights, links  |
| Background        | `#000000` | Main app background (true black, OLED)     |
| Surface (Elevated)| `#1C1C1E` | Cards, bottom sheets, grouped backgrounds  |
| Surface (Tertiary)| `#2C2C2E` | Input fields, secondary cards, dividers    |
| Text (Primary)    | `#FFFFFF` | Headings, body text, primary labels        |
| Text (Secondary)  | `#EBEBF599` | Captions, placeholder text, metadata (60% opacity) |
| Destructive       | `#FF453A` | Delete actions, error states               |
| Success           | `#30D158` | Confirmation toasts, save indicators       |
| Warning           | `#FF9F0A` | Caution states                             |

### Typography

- **Font Family**: SF Pro (system font) — ensures consistency with iOS and automatic Dynamic Type support
- **Size Scale**:

| Style        | Size   | Weight     | Usage                              |
|--------------|--------|------------|------------------------------------|
| Large Title  | 34pt   | Bold       | Screen titles (History, Library)   |
| Title 2      | 22pt   | Bold       | Section headers                    |
| Headline     | 17pt   | Semibold   | Exercise names, card titles        |
| Body         | 17pt   | Regular    | General text, descriptions         |
| Callout      | 16pt   | Regular    | Set data (weight, reps)            |
| Subheadline  | 15pt   | Regular    | Secondary labels                   |
| Footnote     | 13pt   | Regular    | Timestamps, metadata               |
| Caption      | 12pt   | Regular    | Hints, tertiary info               |

- **Dynamic Type**: Fully supported. All text uses SwiftUI's built-in text styles (`.largeTitle`, `.headline`, `.body`, etc.) so the app respects the user's system font size preference.

### Iconography

- **Icon Set**: SF Symbols (Apple's native system icons)
- **Guidelines**:
  - Use **medium weight** icons to match SF Pro text weight
  - Prefer **filled** variants for tab bar icons (active state) and **outline** variants for inactive states
  - Icon size should match the adjacent text's point size
  - Use SF Symbols' built-in rendering modes (monochrome with accent color)

---

## 2. Layout System

- **Framework**: SwiftUI native layout (`VStack`, `HStack`, `LazyVStack`, `ScrollView`)
- **Safe Areas**: Always respect safe area insets; content never renders behind the notch or home indicator
- **Spacing Scale**: Multiples of 4pt (4, 8, 12, 16, 20, 24, 32)
- **Content Width**: Full-width on all devices — no max-width constraint (single-column mobile layout)
- **Minimum Touch Target**: 44×44pt per Apple Human Interface Guidelines
- **Card Padding**: 16pt internal padding, 8pt gap between cards
- **Screen Edge Padding**: 16pt horizontal padding from screen edges

---

## 3. Components

| Component          | Spec                                                                                         | File                                    | Status |
|--------------------|----------------------------------------------------------------------------------------------|-----------------------------------------|--------|
| **Primary Button** | Full-width, 50pt height, `#30D158` fill, white label, 12pt corner radius, bold text          | `Views/Components/PrimaryButton.swift`  | Done   |
| **Secondary Button** | Full-width, 50pt height, `#2C2C2E` fill, white label, 12pt corner radius                  | `Views/Components/SecondaryButton.swift`| Done   |
| **Destructive Button** | Full-width, 50pt height, `#FF453A` fill, white label, 12pt corner radius                | `Views/Components/DestructiveButton.swift` | Done |
| **Set Row**        | Horizontal row: set number, weight field, reps field, optional checkmark button. Pre-filled from last session. Tap field to edit via numeric keypad. Swipe left to reveal delete button. Editing values propagates to subsequent incomplete sets. Checkmark is hidden when `onComplete` is nil (e.g., in history edit mode). | `Views/Components/SetRowView.swift` | Done |
| **Exercise Card**  | Surface (`#1C1C1E`) background, 12pt corner radius, 16pt padding. Shows exercise name (headline) and last session summary (subheadline, secondary text). | `Views/Components/ExerciseCard.swift` | Done |
| **Number Input**   | `#2C2C2E` background, 12pt corner radius, centered text (callout weight), numeric keyboard. Tap to select all for quick overwrite. | `Views/Components/NumberInputField.swift` | Done |
| **Tab Bar**        | Standard iOS tab bar, 3 tabs: Workout (`dumbbell.fill`), History (`clock.fill`), Exercises (`list.bullet`). True black background. | `App/ContentView.swift` | Done |
| **Toast**          | Floating pill at bottom of screen above tab bar, auto-dismisses after 3 seconds. Dark surface background with white text. Slide-up animation. | — | Not yet built |
| **Section Header** | Title 2 weight, left-aligned, 24pt top margin, 8pt bottom margin                            | Used inline in views | Done |
| **Empty State**    | Centered text (secondary color) with SF Symbol icon above, and a primary action button below | `Views/Components/EmptyStateView.swift` | Done |
| **Exercise Detail** | Resizable bottom sheet (`.medium`/`.large` detents) with drag indicator. Header shows muscle group badge + custom tag. How-to section: description, primary muscles, numbered steps. History section: last 5 sessions with sets/reps/weight (or time/distance for cardio). | `Views/ExerciseLibrary/ExerciseDetailView.swift` | Done |
| **Cardio Inputs**  | Two-row layout inside workout exercise section: clock icon + minutes field, run icon + km field. Replaces weight/reps for exercises flagged as cardio. | Inline in `ActiveWorkoutView.swift` | Done |

### Design Tokens

All design tokens are centralized in `Theme/AppTheme.swift`:

- `AppTheme.Colors` — accent, background, surface, surfaceTertiary, textPrimary, textSecondary, destructive, success, warning
- `AppTheme.Spacing` — xxs (4), xs (8), sm (12), md (16), lg (20), xl (24), xxl (32)
- `AppTheme.Layout` — cornerRadius (12), buttonHeight (50), minTouchTarget (44), cardPadding (16), cardSpacing (8), screenEdgePadding (16)

---

## 4. UX Flows

### Start Workout
1. User taps the **Workout** tab
2. Taps **Start Workout** button (primary, prominent)
3. Empty session created with current timestamp
4. User taps **Add Exercise** to begin

### Add Exercise to Workout
1. Full-screen modal slides up
2. **Search bar** at top — filters exercise list as the user types
3. **Category tabs** below search (All, Chest, Back, Shoulders, Arms, Legs, Core, Cardio)
4. Exercise list filtered by selected category; recently-used exercises pinned at top under "Recent" section
5. Tap an exercise → added to the current workout, modal dismisses

### Log Sets (Strength)
1. After adding a strength exercise, set rows appear pre-filled with last session's values (weight + reps)
2. User taps a number field to adjust → numeric keypad appears, value is auto-selected for quick overwrite
3. Editing a set's weight or reps auto-propagates the values to all subsequent incomplete sets
4. User taps the **checkmark** button on the row to confirm the set
5. Tap **+ Add Set** to add another row (pre-filled with the same weight/reps as the previous set)
6. Swipe left on a set row to reveal a delete button (hidden when only 1 set remains)
7. Logging a set takes 2-3 taps when values don't change from last session

### Log Cardio
1. After adding a cardio exercise (Running, Cycling, etc.), time and distance inputs appear instead of set rows
2. Two fields: minutes (clock icon) and km (run icon), pre-filled from last session if available
3. No set/rep concept — just duration and distance

### Finish Workout
1. User taps **Finish** button in the navigation bar
2. Centered alert prompt: "Finish workout?" with message "This will save your workout to history."
3. Incomplete sets are discarded; exercises with no completed sets are removed
4. Workout saved with timestamp and duration
5. App switches to the **History** tab and auto-navigates to the completed workout's detail view

### Cancel Workout
1. User taps **Cancel** button (red, top-left) in the navigation bar
2. Centered alert prompt: "Discard Workout?" with message "This will delete all exercises and sets from this workout."
3. User confirms with "Discard" (destructive) or cancels with "Keep Training"
4. If discarded, workout is deleted and view returns to "Ready to Train?" empty state

### View Exercise Detail
1. User taps any exercise in the **Exercises** tab
2. A resizable bottom sheet appears (medium or large height) with drag indicator
3. **Header**: Muscle group badge (green capsule) and optional "Custom" tag
4. **How to Perform**: Description, primary muscles (in accent color), and numbered step-by-step instructions
5. **Recent History**: Last 5 sessions showing date and sets (weight × reps), or time/distance for cardio
6. Custom exercises show "No instructions available" in the how-to section

### View History
1. User taps the **History** tab
2. Workouts listed by date (most recent first), showing date, duration, and exercise count
3. Tap a workout → detail view with all exercises, sets, weights, and reps

### Edit Completed Workout
1. User opens a workout from the **History** tab
2. Taps **Edit** button in the navigation bar (top-right, accent color)
3. View switches to edit mode:
   - **Date pickers** appear at top for start and end time (end constrained to after start)
   - **Duration** in summary header updates live as dates change
   - **Strength exercises**: Set rows become editable via `SetRowView` (no checkmarks shown). Swipe left to delete sets; tap **+ Add Set** to add new sets.
   - **Cardio exercises**: Duration and distance fields become editable via `NumberInputField`
   - **Remove exercise**: X button appears on each exercise header
   - **Add exercise**: **+ Add Exercise** button appears at the bottom, opening the standard exercise picker sheet
4. Taps **Done** to apply date changes and exit edit mode. Set and exercise edits are saved immediately via SwiftData.

### Error States
- **Failed to save**: Toast appears at bottom — "Couldn't save. Try again." with a retry action
- **No exercises found** (search): Inline empty state — "No exercises found" with option to create a custom exercise
- **Empty history**: Centered empty state — "No workouts yet" with illustration and "Start Workout" button

---

## 5. Accessibility

- **Dynamic Type**: All text uses SwiftUI semantic text styles; layout adapts to larger accessibility sizes
- **VoiceOver**: All interactive elements have descriptive accessibility labels (e.g., "Set 1: 135 pounds, 8 reps — tap to edit")
- **Contrast Ratios**: White text on true black exceeds WCAG AAA (21:1). Green accent on black meets WCAG AA for large text
- **Focus States**: Interactive elements show a visible focus ring when navigated via keyboard or switch control
- **Haptic Feedback**: Light haptic on set confirmation, medium haptic on workout finish
- **Reduce Motion**: Respect `UIAccessibility.isReduceMotionEnabled` — disable slide/spring animations when enabled

---

## 6. Inspirations / References

- **Strong (iOS)** — clean workout logging interface, set-by-set input pattern
- **JEFIT** — comprehensive exercise library with muscle group categorization
- **Plain spreadsheet** — the simplicity benchmark; logging should feel as fast as typing into a spreadsheet row
- **Apple Fitness** — dark UI patterns, native iOS design language

---

> Keep this document updated as designs evolve.

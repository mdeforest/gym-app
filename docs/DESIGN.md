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
| **Set Row**        | Horizontal row: set number, weight field, reps field, checkmark button. Pre-filled from last session. Tap field to edit via numeric keypad. | `Views/Components/SetRowView.swift` | Done |
| **Exercise Card**  | Surface (`#1C1C1E`) background, 12pt corner radius, 16pt padding. Shows exercise name (headline) and last session summary (subheadline, secondary text). | `Views/Components/ExerciseCard.swift` | Done |
| **Number Input**   | `#2C2C2E` background, 12pt corner radius, centered text (callout weight), numeric keyboard. Tap to select all for quick overwrite. | `Views/Components/NumberInputField.swift` | Done |
| **Tab Bar**        | Standard iOS tab bar, 3 tabs: Workout (`dumbbell.fill`), History (`clock.fill`), Exercises (`list.bullet`). True black background. | `App/ContentView.swift` | Done |
| **Toast**          | Floating pill at bottom of screen above tab bar, auto-dismisses after 3 seconds. Dark surface background with white text. Slide-up animation. | — | Not yet built |
| **Section Header** | Title 2 weight, left-aligned, 24pt top margin, 8pt bottom margin                            | Used inline in views | Done |
| **Empty State**    | Centered text (secondary color) with SF Symbol icon above, and a primary action button below | `Views/Components/EmptyStateView.swift` | Done |

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

### Log Sets
1. After adding an exercise, set rows appear pre-filled with last session's values (weight + reps)
2. User taps a number field to adjust → numeric keypad appears, value is auto-selected for quick overwrite
3. User taps the **checkmark** button on the row to confirm the set
4. Tap **+ Add Set** to add another row (pre-filled with the same weight/reps as the previous set)
5. Logging a set takes 2-3 taps when values don't change from last session

### Finish Workout
1. User taps **Finish** button in the navigation bar
2. Confirmation prompt: "Finish workout?"
3. Workout saved with timestamp and duration
4. Toast: "Workout saved" — navigates to History or stays on Workout tab (ready for next session)

### View History
1. User taps the **History** tab
2. Workouts listed by date (most recent first), showing date, duration, and exercise count
3. Tap a workout → detail view with all exercises, sets, weights, and reps

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

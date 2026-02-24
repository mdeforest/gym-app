# Future Features

> Ideas and stretch goals for the project beyond current scope.
> These are **not committed**, but may be explored in future iterations.

---

## ✅ Delivered

- [x] **Workout templates** — Save and reuse named routines with exercises, set counts, and defaults
- [x] **Rest timer** — Per-exercise configurable countdown with floating pill, haptics, and background notifications
- [x] **Progress charts** — Workout frequency, muscle group split, and strength progression charts with time range filtering and summary stats
- [x] **Calendar view** — Monthly calendar in History tab with workout day indicators, date filtering, month navigation, and backdated workout creation
- [x] **Settings page** — Profile setup (name, body weight, weight unit), data export, clear all data, app version display
- [x] **Data export** — CSV and JSON export of full workout history via iOS share sheet
- [x] **Warm-up sets** — Toggle sets between normal and warm-up; warm-up sets excluded from stats and PRs
- [x] **RPE tracking** — Per-set RPE rating (6–10) with color-coded badges and inline picker
- [x] **Supersets** — Link exercises into superset groups with purple bracket UI, preserved in templates
- [x] **Exercise reordering** — Move exercises/groups up and down during workouts and history editing
- [x] **Apple Health integration** — Sync completed workouts to Apple Health, read body weight, toggle in Settings with authorization status
- [x] **Track Records (Personal Records)** — Per-set PR detection for weight, estimated 1RM (Epley), and volume. Gold badges on set rows, "New PR!" toast during workouts, personal records section in exercise detail, trophy annotations on strength charts. One-time backfill for existing data.
- [x] **Calculators** — Plate Calculator, 1RM Calculator, RPE Chart, and Stopwatch accessible via a toolbar button on the Workout tab (idle and active states).
- [x] **Exercise Database** — 590 exercises sourced from the Free Exercise DB (public domain) across 7 muscle groups and 8 equipment types. Equipment data enables filtering. Additive seeding adds new exercises on update without touching user data.
- [x] **Available Equipment** — Let the user configure which equipment they have access to; exercises requiring unconfigured equipment are hidden in the library and the Add Exercise sheet. Configured via a dedicated section in Settings (individual rows, iOS Settings-style colored icon squares, checkmarks, Reset button). Persisted via `@AppStorage` as comma-separated rawValues. Exercises with `nil` or `.other` equipment always show regardless of the setting.
- [x] **Gym Profiles** — Named equipment presets (e.g. "Home Gym", "Commercial Gym", "Travel") that can be switched instantly from Settings. Each profile stores equipment types and, for machine exercises, a subset of 12 machine types. Applying a profile updates the exercise filter in real time. Three built-in templates. Active profile shown in the Settings row.

---

## 💡 Feature Ideas

- [ ] **Bodyweight tracking**
  Track weight or measurements weekly with charts and trends; leverage HealthKit body weight data already being read.

- [ ] **Training Partner Mode**
  Share workouts with friends, competitions, workout together, etc.

- [ ] **Workout "suggestions"**
  This is purely based on muscle group recovery

- [ ] **Schedule Workouts**
  Allow the user to schedule workouts for the future.

- [ ] **Video Examples**
  Add videos or gifs to the exercise database.

- [ ] **Group Templates**
  Allow grouping/tagging templates.

- [ ] **Dynamic Island Integration**
  Surface the active rest timer in the Dynamic Island and Live Activity during a workout. The compact view shows a countdown ring + remaining seconds so you can glance from the lock screen without unlocking. The expanded view adds the exercise name and a "Skip" tap target. Uses ActivityKit (`ActivityAttributes` + `ContentState`) with a `RestTimerAttributes` struct. The existing wall-clock-based timer logic maps cleanly onto Live Activity updates — push a new `ContentState` on set completion and cancel the activity when the rest period ends or the workout finishes. Requires iOS 16.2+ and a real device (Dynamic Island hardware on iPhone 14 Pro and later).


---

## 🔍 Experimental or Ambitious

- [ ] AI-based set suggestions (based on history or fatigue estimation)
- [ ] WatchOS companion app
- [ ] Siri shortcuts: “Start Workout” or “Log Set”
- [ ] AI-based full workout plans
- [ ] Personal Trainer AI for chatting/questions
- [ ] More interesting charts
---



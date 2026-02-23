# VEDA

Personal iOS life-management app.

## Tech Stack
- iOS 18, SwiftUI, SwiftData
- WidgetKit + AppIntents (home screen & lock screen widgets)
- No third-party dependencies

## Architecture
Tab-based app (Tasks | Chores | Sleep | Settings) + a widget extension target.

```
VEDA/
├── VEDAApp.swift              # App entry + 5am daily refresh + water fallback scheduling
├── ContentView.swift          # Root TabView
├── Models/
│   ├── Task.swift
│   ├── Chore.swift
│   └── SleepEntry.swift
├── Features/
│   ├── Tasks/                 # TasksView, AddTaskView
│   ├── Chores/                # ChoresView, AddChoreView
│   ├── Sleep/                 # SleepView, SleepEditView
│   └── Settings/              # SettingsView
└── Services/
    ├── NotificationService.swift   # Chore + water reminder notifications
    ├── SharedModelContainer.swift  # App Group SwiftData config (shared with widgets)
    └── SleepHeuristics.swift       # Quality-weighted sleep duration prediction

VEDAWidgets/                   # Widget extension target
├── VEDAWidgetsBundle.swift
├── SleepWidget.swift          # Medium + lock screen widget views + timeline provider
└── SleepWidgetIntents.swift   # LogSleepIntent, LogWakeIntent (AppIntents)
```

App Group: `group.app.vercel.johnnylau.VEDA` — shared SQLite store at `VEDA.sqlite` in the container, used by both the main app and the widget extension.

## Coding Conventions
- **One type per file** — file name must match the Swift type name exactly
- **@Bindable over @State** — pass SwiftData model objects into subviews using `@Bindable`
- **Pure SwiftUI** — no `import UIKit` unless strictly unavoidable (e.g., `UIApplication`)
- **No redundant comments** — only add comments where logic is genuinely non-obvious

## Workflow Rules
- **Always read a file before editing it** — never propose changes to code not read in this session

## Feature Roadmap
- **Tasks**: daily tasks (refresh at 5am), one-off tasks ✓
- **Chores**: recurring by fixed interval or day-of-week; overdue push notifications ✓
- **SleepyTime!**: log sleep/wake + emoji rating (😫😴😐🙂😄); quality-weighted duration prediction; home screen + lock screen widgets; edit/delete history entries ✓
  → Future: upgrade prediction to Core ML / Create ML model
- **Water Reminders**: 8 daily notifications from wake time to 1am; adapts to logged wake time, falls back to configurable default ✓

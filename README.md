# HomeKeep — Home Maintenance Tracker

A simple, beautiful iOS app to track recurring home maintenance tasks. Set it once, get reminded when it's due. No subscription, no backend, no complexity.

## Features

- **30+ Pre-loaded Tasks** — Common home maintenance tasks with recommended frequencies (HVAC filters, gutter cleaning, smoke detectors, etc.)
- **Custom Tasks** — Add your own tasks with custom recurrence schedules
- **Smart Reminders** — Push notifications configurable as day-of, day-before, or week-before
- **Mark Complete** — One-tap completion with date stamps and optional notes
- **Task History** — Full chronological log of every completed task
- **Room/Zone Grouping** — Organize by Kitchen, HVAC, Exterior, Plumbing, Safety, and more
- **Seasonal Dashboard** — See what's due for Spring, Summer, Fall, and Winter prep
- **Urgency Dashboard** — Overdue, this week, and this month at a glance

## Screenshots

*Coming soon*

## Release Docs

- App Store media runbook: `docs/app-store-media-runbook.md`

## Technical Details

- **SwiftUI** — Modern declarative UI
- **SwiftData** — Persistent storage (iOS 17+)
- **UNUserNotificationCenter** — Local push notifications
- **SF Symbols** — Native Apple icons throughout
- **No backend** — Fully offline, your data stays on your device

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Building

1. Open `HomeKeep.xcodeproj` in Xcode
2. Select your development team for signing
3. Build and run on simulator or device

## Architecture

```
HomeKeep/
├── Models/
│   ├── MaintenanceTask.swift    # Core task model with SwiftData
│   ├── CompletionRecord.swift   # Completion history entries
│   ├── Zone.swift               # Room/zone grouping
│   └── TaskLibrary.swift        # 30+ pre-loaded task templates
├── Views/
│   ├── ContentView.swift        # Tab bar root
│   ├── DashboardView.swift      # Home screen with urgency groups
│   ├── TaskLibraryView.swift    # All tasks by zone with toggles
│   ├── TaskDetailView.swift     # Full task detail + settings
│   ├── SeasonalView.swift       # Seasonal task dashboard
│   ├── HistoryView.swift        # Completion history log
│   ├── SettingsView.swift       # App settings
│   ├── AddTaskView.swift        # Create custom task
│   └── Components/
│       └── TaskRow.swift        # Reusable task row component
├── Services/
│   ├── NotificationService.swift # Push notification scheduling
│   └── SeedService.swift        # First-launch data seeding
└── HomeKeepApp.swift            # App entry point
```

## Bundle ID

`ai.e6.homekeep`

## License

Copyright © 2026 e6.ai. All rights reserved.

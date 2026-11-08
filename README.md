# Ovvas

A calm, ad-free habit tracker built with Flutter.

> **Status:** all screens are built. Data is saved on the phone (SQLite via Drift). Google sign-in and cloud sync use Supabase when it is configured; without it, the app keeps data on the phone only. Debug builds start with sample habits on a fresh install.

## Features

- **Today** — check in with one tap. See a progress ring for the day, and go back to edit past days.
- **Three goal types** — Yes/No, Count (e.g. 8 glasses), and Time (in minutes).
- **Flexible schedules** — every day, chosen weekdays, or a number of times per week, with optional start and end dates.
- **Skip days** — skipping a day doesn't break your streak or lower your completion rate.
- **Notes** — add a note to any day's check-in.
- **Reminders** — one or more per habit, plus a default reminder time and quiet hours.
- **Stats** — weekly and monthly views, current and longest streaks, completion rates, and simple insights (for example, "Mondays are your hardest day").
- **Home screen widgets** — design and preview six widget types: single habit, today list, progress ring, week strip, month heatmap, and streak counter. Each has its own sizes, themes, backgrounds, and corner styles. The free version allows 3 widgets.
- **Archive or delete** — archive a habit to keep its history, or delete it completely.
- **Personalisation** — light, dark, or system theme; in-app text size; first day of the week; haptics, animations, and celebrations on or off.
- **Languages** — English and Bangla (বাংলা).

## Getting started

### Requirements

- Flutter with Dart SDK `^3.13.7`

### Run

```bash
flutter pub get
flutter run
```

Localization files are generated automatically from the `.arb` files when you build (`generate: true` in `pubspec.yaml`). To regenerate them by hand:

```bash
flutter gen-l10n
```

After changing the tables in [database.dart](lib/data/local/database.dart), regenerate the database code:

```bash
dart run build_runner build
```

### Cloud backup (Supabase)

Optional. Without it, everything works and stays on the phone.

1. Create a project at [supabase.com](https://supabase.com).
2. Run [supabase/migrations/20261108000000_ovvas_sync.sql](supabase/migrations/20261108000000_ovvas_sync.sql) in the SQL editor (or `supabase db push` with the Supabase CLI). It creates the tables and the rules that keep each user's data private.
3. Turn on Google sign-in: **Authentication → Sign In / Providers → Google**, using a Google Cloud OAuth client ID and secret.
4. Add `ovvas://login-callback` under **Authentication → URL Configuration → Redirect URLs**.
5. Copy `supabase.env.example.json` to `supabase.env.json` (ignored by git) and fill in your project URL and publishable key (**Project Settings → API Keys**). Then run:

```bash
flutter run --dart-define-from-file=supabase.env.json
```

In VS Code, pick the **Ovvas (cloud backup)** launch configuration.

How sync works: every change is saved on the phone first and marked for upload. About two seconds after a change, when the app returns to the foreground, and on **Back up now**, the app uploads marked rows and downloads rows changed elsewhere. If two phones edit the same thing, the later edit wins. Deleted items are kept as "deleted" markers so the deletion reaches every phone.

### Test

```bash
flutter test
```

The widget tests in [test/widget_test.dart](test/widget_test.dart) run the app with a fixed clock and sample data, in both themes and languages, at different screen widths and text sizes. They use an in-memory store and a fake cloud. [test/database_test.dart](test/database_test.dart) checks that data and settings survive a restart, using an in-memory SQLite database.

## Project structure

```
lib/
├── main.dart              # Entry point: opens the database and cloud sync
├── app/                   # App root (MaterialApp, theme, locale) and AppScope
├── core/theme/            # Colors, habit palette, and ThemeData
├── domain/                # Pure Dart models and logic
│   ├── habit.dart         #   Habit, DayEntry, goal and repeat types
│   ├── stats.dart         #   Streaks, completion rates, period summaries
│   ├── widget_config.dart #   Home screen widget options
│   └── dates.dart         #   Date helpers
├── data/                  # State
│   ├── habit_store.dart   #   Habits, check-ins, widgets (memory + database)
│   ├── settings_controller.dart
│   ├── sample_data.dart   #   Demo habits and history
│   ├── local/             #   Drift database and model <-> row converters
│   └── sync/              #   Cloud sync: Supabase, local-only, and a fake for tests
supabase/migrations/       # Server tables and security rules
├── l10n/                  # app_en.arb, app_bn.arb, and generated code
└── ui/
    ├── home_shell.dart    # Bottom navigation: Today, Stats, Widgets, Settings
    ├── today/             # Today screen and habit cards
    ├── habit/             # Habit details and add/edit form
    ├── stats/             # Stats screen
    ├── widgets/           # Widget gallery, builder, and previews
    ├── settings/          # Settings screen
    └── common/            # Shared components, charts, dialogs, formatting
```

### How it fits together

- **Domain** holds plain models and pure functions with no Flutter UI code, so the streak and stats logic is easy to test.
- **Data** exposes `HabitStore` and `SettingsController`, both `ChangeNotifier`s. Screens only talk to these classes. `HabitStore` keeps everything in memory for instant reads, writes each change to the local database in the background, and asks `CloudSync` to back it up.
- **AppScope** passes the store and settings down the widget tree.
- No third-party state management or chart packages are used; charts are drawn with Flutter's own widgets.

## Adding a translation

1. Copy `lib/l10n/app_en.arb` to `lib/l10n/app_<code>.arb` and translate the values.
2. Run `flutter gen-l10n` (or just build the app).
3. Add the language to the language picker options in [settings_screen.dart](lib/ui/settings/settings_screen.dart).

## Roadmap

- [x] Save data on the device
- [x] Account sign-in and cloud backup
- [ ] Real reminder notifications
- [ ] Native home screen widgets on Android and iOS
- [ ] Ovvas Plus (unlimited widgets)

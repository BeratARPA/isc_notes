<div align="center">
  <img src="assets/images/app_logo.png" alt="ISC Notes" width="120" height="120">
  <h1>ISC Notes</h1>
  <p><strong>An offline, rich-text note-taking app for Android, built with Flutter.</strong></p>

  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/SQLite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite">
</div>

## Features

- **Rich-text editor** powered by `flutter_quill`: headings, lists, bold/italic, colors.
- **Categories** with custom icons and colors, managed from their own screen.
- **Pinned notes** stay at the top of the list.
- **Per-note lock**: a note can be protected with a password.
- **Recycle bin**: deleted notes can be restored or removed for good.
- **Themes**: light, dark or follow the system, built on `flex_color_scheme`.
- **Two languages**: Turkish and English.
- **Fully offline**: no account, no server; everything lives in a local SQLite database.

## Tech stack

| Area | Choice |
|---|---|
| UI | Flutter, Material 3, `flex_color_scheme`, Poppins font |
| State | `provider` with a small MVVM layer (`lib/viewmodels`) |
| Storage | `drift` (SQLite) for notes and categories, `shared_preferences` for settings |
| Editor | `flutter_quill` |
| i18n | `flutter_localizations` + ARB files (`lib/l10n`) |

## Project structure

```
lib/
  database/     drift database, tables and repositories
  models/       note and category models
  viewmodels/   one view model per screen
  views/        home, note editor, categories, recycle bin, settings
  widgets/      app bar, drawer, note card
  services/     theme and localization services
  l10n/         Turkish and English strings
```

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if you change the drift tables
flutter run
```

Release builds read the signing config from `android/key.properties`, which is not in the repository. Without it, use `flutter run` or a debug build.

## Note on locked notes

The per-note password is a privacy lock inside the app. It is stored in the local database as is and the note body is not encrypted, so it does not protect data from someone with access to the device's files.

## License

[MIT](LICENSE)

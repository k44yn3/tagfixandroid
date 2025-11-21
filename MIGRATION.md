# Android Port - Migration Notes

This repository has been migrated from a desktop application (Windows/Linux) to an Android-only application.

## What Changed

### Removed
- Windows and Linux platform support
- Python CLI tool (`tagfix.py`)
- Flask web interface (`app.py`)
- Desktop-specific dependencies (`window_manager`, `desktop_drop`)
- FFmpeg binary bundling (replaced with FFmpeg Kit Flutter)

### Added
- Android project structure with proper configuration
- Permission handling for Android storage/media access
- FFmpeg Kit Flutter for audio conversion on Android
- Mobile-optimized UI (portrait/landscape support)
- GitHub Actions workflow for APK builds

### Updated
- Main app to remove desktop window management
- UI layout to be responsive for mobile devices
- FFmpeg integration to use FFmpeg Kit instead of bundled binaries
- README with Android-specific instructions

## Building

See the main [README.md](README.md) for build instructions.

## Cleanup

To remove the old desktop files, run:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

This will delete:
- `flutter_app/windows/`
- `flutter_app/linux/`
- `flutter_app/web/`
- `app.py`, `tagfix.py`, `requirements.txt`
- Other desktop-specific files

## Minimum Android Version

The app supports Android 7.0 (API 24) and above, covering approximately 98% of active Android devices.

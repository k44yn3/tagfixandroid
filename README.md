# TagFix

A powerful audio metadata editor for Android supporting FLAC, MP3, M4A, OGG, OPUS, WMA, and WAV formats.

This project is a port of the original TagFix desktop application to Android.

## Download

[Download the latest APK here](https://github.com/k44yn3/tagfixandroid/releases)

**Minimum Android Version:** Android 7.0 (API 24) and above

## Installation

1. Download the APK from the releases page
2. Enable "Install from Unknown Sources" in your Android settings if prompted
3. Open the APK file to install
4. Grant storage/media permissions when the app requests them

## Features

- **Material Design**: Modern Material You interface with dynamic theming
- **Metadata Editing**: Edit Title, Artist, Album, Year, Genre, Track/Disc numbers
- **Cover Art Management**: View and update album artwork
- **Recursive Scanning**: Process entire directories at once
- **Lyrics Support**: Search and edit synchronized lyrics via LRCLIB
- **MusicBrainz Integration**: Automatic metadata lookup
- **Dark Mode**: Automatic dark/light theme based on system settings
- **Responsive UI**: Optimized for both portrait and landscape orientations

## Permissions

TagFix requires the following permissions:

- **Storage/Media Access**: To read and modify audio files
- **Internet**: To fetch metadata from MusicBrainz and lyrics from LRCLIB

## Building from Source

### Prerequisites

- Flutter SDK (3.24.0 or later)
- Android SDK with API 24+
- Java 17

### Build Steps

```bash
cd flutter_app
flutter pub get
flutter build apk --release
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`

## Credits

- Ported from the original [TagFix]([https](https://github.com/k44yn3/tagfix)
- Flutter
- MusicBrainz
- LRCLIB
- AudioTags Package

## License

See [LICENSE](LICENSE) file for details.

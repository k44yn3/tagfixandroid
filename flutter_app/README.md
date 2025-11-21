# TagFix - Flutter

This is the Flutter port of the TagFix application, supporting Windows, Linux, and macOS.

## Prerequisites

- Flutter SDK installed and in your PATH.
- `ffmpeg` installed (for audio conversion).

## Setup

Since the project was scaffolded manually, you need to run the following command to generate platform-specific files:

```bash
cd flutter_app
flutter create .
```

## Running

```bash
flutter run -d linux  # or windows, macos
```

## Features

- **Material You Design**: Dynamic theming based on seed color.
- **Cross-Platform**: Runs natively on desktop.
- **Metadata Editing**: Edit Title, Artist, Album, Year, Genre, Track/Disc numbers.
- **Cover Art**: View and update cover art.
- **Conversion**: Convert files to WAV or FLAC using system FFmpeg.
- **Recursive Scanning**: Scan folders for audio files.

## Project Structure

- `lib/models`: Data models (`AudioFile`).
- `lib/services`: Core logic (`FileService`, `TagService`, `FfmpegService`).
- `lib/providers`: State management (`AppState`).
- `lib/screens`: UI Screens (`MainScreen`).
- `lib/widgets`: Reusable widgets (`FileList`, `EditorPanel`, `CoverArtWidget`).

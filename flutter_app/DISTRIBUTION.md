# TagFix Distribution Guide

This guide covers building and distributing TagFix for Linux, Windows, and macOS.

## Prerequisites

- Flutter SDK installed and configured
- Platform-specific build tools installed
- FFmpeg binaries already bundled in `assets/ffmpeg/`

---

## Linux Distribution

### Build Release Binary

```bash
cd flutter_app
flutter build linux --release
```

**Output location**: `build/linux/x64/release/bundle/`

### Distribution Options

#### Option 1: AppImage (Recommended)
AppImage is a portable format that works on most Linux distributions.

1. **Install appimagetool**:
```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
```

2. **Create AppDir structure**:
```bash
mkdir -p TagFix.AppDir/usr/bin
mkdir -p TagFix.AppDir/usr/share/applications
mkdir -p TagFix.AppDir/usr/share/icons/hicolor/256x256/apps

# Copy the built app
cp -r build/linux/x64/release/bundle/* TagFix.AppDir/usr/bin/

# Create desktop entry
cat > TagFix.AppDir/usr/share/applications/tagfix.desktop << 'EOF'
[Desktop Entry]
Name=TagFix
Comment=Audio Metadata Editor
Exec=tagfix
Icon=tagfix
Type=Application
Categories=AudioVideo;Audio;
EOF

# Copy icon (create a 256x256 PNG icon first)
cp assets/icon.png TagFix.AppDir/usr/share/icons/hicolor/256x256/apps/tagfix.png

# Create AppRun script
cat > TagFix.AppDir/AppRun << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin/:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib/:${LD_LIBRARY_PATH}"
cd "${HERE}/usr/bin"
exec ./tagfix "$@"
EOF

chmod +x TagFix.AppDir/AppRun

# Build AppImage
./appimagetool-x86_64.AppImage TagFix.AppDir TagFix-x86_64.AppImage
```

**Result**: `TagFix-x86_64.AppImage` (portable, single-file executable)

#### Option 2: Debian Package (.deb)

1. **Install packaging tools**:
```bash
sudo apt install dpkg-dev
```

2. **Create package structure**:
```bash
mkdir -p tagfix_1.0.0_amd64/DEBIAN
mkdir -p tagfix_1.0.0_amd64/opt/tagfix
mkdir -p tagfix_1.0.0_amd64/usr/share/applications
mkdir -p tagfix_1.0.0_amd64/usr/share/icons/hicolor/256x256/apps

# Copy files
cp -r build/linux/x64/release/bundle/* tagfix_1.0.0_amd64/opt/tagfix/

# Create control file
cat > tagfix_1.0.0_amd64/DEBIAN/control << 'EOF'
Package: tagfix
Version: 1.0.0
Section: sound
Priority: optional
Architecture: amd64
Maintainer: Your Name <your.email@example.com>
Description: Audio Metadata Editor
 TagFix is a cross-platform audio metadata editor with support for
 MP3, FLAC, M4A, and more. Features include lyrics management,
 cover art fetching from MusicBrainz, and audio format conversion.
EOF

# Create desktop entry
cat > tagfix_1.0.0_amd64/usr/share/applications/tagfix.desktop << 'EOF'
[Desktop Entry]
Name=TagFix
Comment=Audio Metadata Editor
Exec=/opt/tagfix/tagfix
Icon=tagfix
Type=Application
Categories=AudioVideo;Audio;
EOF

# Copy icon
cp assets/icon.png tagfix_1.0.0_amd64/usr/share/icons/hicolor/256x256/apps/tagfix.png

# Build package
dpkg-deb --build tagfix_1.0.0_amd64
```

**Result**: `tagfix_1.0.0_amd64.deb`

**Install**:
```bash
sudo dpkg -i tagfix_1.0.0_amd64.deb
```

---

## Windows Distribution

### Build Release Binary

```bash
cd flutter_app
flutter build windows --release
```

**Output location**: `build/windows/x64/runner/Release/`

### Distribution Options

#### Option 1: Portable ZIP (Simplest)

```bash
cd build/windows/x64/runner/Release
zip -r TagFix-Windows-x64.zip .
```

**Result**: Users extract and run `tagfix.exe`

#### Option 2: Installer with Inno Setup (Recommended)

1. **Install Inno Setup**: Download from https://jrsoftware.org/isdl.php

2. **Create installer script** (`installer.iss`):
```iss
[Setup]
AppName=TagFix
AppVersion=1.0.0
DefaultDirName={autopf}\TagFix
DefaultGroupName=TagFix
OutputDir=.
OutputBaseFilename=TagFix-Setup-x64
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\TagFix"; Filename: "{app}\tagfix.exe"
Name: "{autodesktop}\TagFix"; Filename: "{app}\tagfix.exe"

[Run]
Filename: "{app}\tagfix.exe"; Description: "Launch TagFix"; Flags: nowait postinstall skipifsilent
```

3. **Build installer**:
```bash
iscc installer.iss
```

**Result**: `TagFix-Setup-x64.exe` (installer)

#### Option 3: MSIX Package (Microsoft Store)

```bash
flutter build windows --release
flutter pub run msix:create
```

Requires configuration in `pubspec.yaml`:
```yaml
msix_config:
  display_name: TagFix
  publisher_display_name: Your Name
  identity_name: com.yourname.tagfix
  msix_version: 1.0.0.0
  logo_path: assets/icon.png
```

---

## macOS Distribution

### Build Release Binary

**On macOS**:
```bash
cd flutter_app
flutter build macos --release
```

**Output location**: `build/macos/Build/Products/Release/tagfix.app`

### Distribution Options

#### Option 1: DMG Installer (Recommended)

1. **Create DMG**:
```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "TagFix" \
  --volicon "assets/icon.icns" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "tagfix.app" 175 120 \
  --hide-extension "tagfix.app" \
  --app-drop-link 425 120 \
  "TagFix-macOS.dmg" \
  "build/macos/Build/Products/Release/tagfix.app"
```

**Result**: `TagFix-macOS.dmg`

Users drag the app to Applications folder.

#### Option 2: ZIP Archive

```bash
cd build/macos/Build/Products/Release
zip -r TagFix-macOS.zip tagfix.app
```

#### Code Signing (Required for Distribution)

To distribute outside the Mac App Store, you need to sign the app:

```bash
# Sign the app
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" tagfix.app

# Notarize with Apple (required for macOS 10.15+)
xcrun notarytool submit TagFix-macOS.dmg --apple-id your@email.com --password app-specific-password --team-id TEAM_ID
```

---

## GitHub Releases (Recommended Distribution Method)

### 1. Create Release on GitHub

```bash
# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 2. Upload Binaries

Go to GitHub → Releases → Create new release

Upload:
- `TagFix-x86_64.AppImage` (Linux)
- `TagFix-Setup-x64.exe` (Windows installer)
- `TagFix-Windows-x64.zip` (Windows portable)
- `TagFix-macOS.dmg` (macOS)

### 3. Release Notes Template

```markdown
## TagFix v1.0.0

Audio metadata editor with lyrics management and online cover art fetching.

### Features
- Edit metadata (title, artist, album, year, genre, etc.)
- Lyrics preview and editing with .lrc/.txt import
- Cover art management (manual + MusicBrainz online fetching)
- Audio conversion (WAV/FLAC) with bundled FFmpeg
- Material 3 design with dark mode support

### Downloads
- **Linux**: TagFix-x86_64.AppImage (portable)
- **Windows**: TagFix-Setup-x64.exe (installer) or TagFix-Windows-x64.zip (portable)
- **macOS**: TagFix-macOS.dmg

### Installation
**Linux**: Make executable and run
**Windows**: Run installer or extract ZIP
**macOS**: Open DMG and drag to Applications

### System Requirements
- Linux: Ubuntu 20.04+ or equivalent
- Windows: Windows 10/11 (64-bit)
- macOS: macOS 10.14+
```

---

## Automated CI/CD with GitHub Actions

Create `.github/workflows/release.yml`:

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
        working-directory: flutter_app
      - run: flutter build linux --release
        working-directory: flutter_app
      - uses: actions/upload-artifact@v3
        with:
          name: linux-build
          path: flutter_app/build/linux/x64/release/bundle/

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
        working-directory: flutter_app
      - run: flutter build windows --release
        working-directory: flutter_app
      - uses: actions/upload-artifact@v3
        with:
          name: windows-build
          path: flutter_app/build/windows/x64/runner/Release/

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
        working-directory: flutter_app
      - run: flutter build macos --release
        working-directory: flutter_app
      - uses: actions/upload-artifact@v3
        with:
          name: macos-build
          path: flutter_app/build/macos/Build/Products/Release/
```

---

## File Sizes (Approximate)

- **Linux AppImage**: ~150-200 MB (includes 79 MB FFmpeg)
- **Windows ZIP/Installer**: ~220-270 MB (includes 192 MB FFmpeg)
- **macOS DMG**: ~150-200 MB (includes 80 MB FFmpeg)

---

## Licensing Considerations

Since you're bundling FFmpeg (GPL/LGPL), you must:

1. **Include FFmpeg license** in your distribution
2. **Provide source code** or offer to provide it
3. **Mention FFmpeg** in your about dialog/documentation

Add to your app:
```dart
// In about dialog
showAboutDialog(
  context: context,
  applicationName: 'TagFix',
  applicationVersion: '1.0.0',
  applicationLegalese: 'Uses FFmpeg (GPL/LGPL)\nMusicBrainz for cover art',
);
```

---

## Quick Start Commands

**Linux**:
```bash
flutter build linux --release
# Then create AppImage or .deb
```

**Windows** (on Windows machine):
```bash
flutter build windows --release
# Then create installer with Inno Setup
```

**macOS** (on macOS machine):
```bash
flutter build macos --release
# Then create DMG with create-dmg
```

---

## Testing Before Release

1. **Test on clean VMs** for each OS
2. **Verify FFmpeg extraction** works on first run
3. **Test all features** (metadata editing, lyrics, cover art, conversion)
4. **Check file permissions** and paths
5. **Verify auto-updates** if implemented

---

## Next Steps

1. Build for your current platform first
2. Test thoroughly
3. Set up CI/CD for automated builds
4. Create GitHub release with binaries
5. Write user documentation
6. Consider adding auto-update functionality

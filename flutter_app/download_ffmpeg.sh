#!/bin/bash

# FFmpeg Binary Download Script for TagFix
# Run this from the flutter_app directory

set -e

echo "=== TagFix FFmpeg Binary Download Script ==="
echo

# Create directories
mkdir -p assets/ffmpeg/{linux,windows,macos}

# Download Linux binary
echo "📥 Downloading Linux ffmpeg..."
cd assets/ffmpeg/linux
wget -q --show-progress https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
tar -xf ffmpeg-release-amd64-static.tar.xz --strip-components=1 --wildcards '*/ffmpeg'
rm -f ffmpeg-release-amd64-static.tar.xz
chmod +x ffmpeg
echo "✅ Linux binary ready"
cd ../../..

# Download Windows binary  
echo "📥 Downloading Windows ffmpeg..."
cd assets/ffmpeg/windows
wget -q --show-progress https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
unzip -q -j ffmpeg-master-latest-win64-gpl.zip "*/bin/ffmpeg.exe"
rm -f ffmpeg-master-latest-win64-gpl.zip
echo "✅ Windows binary ready"
cd ../../..

# Download macOS binary
echo "📥 Downloading macOS ffmpeg..."
cd assets/ffmpeg/macos
wget -q --show-progress https://evermeet.cx/ffmpeg/getrelease/ffmpeg/zip -O ffmpeg.zip
unzip -q ffmpeg.zip
rm -f ffmpeg.zip
chmod +x ffmpeg
echo "✅ macOS binary ready"
cd ../../..

echo
echo "🎉 All ffmpeg binaries downloaded successfully!"
echo
echo "Binary sizes:"
ls -lh assets/ffmpeg/linux/ffmpeg
ls -lh assets/ffmpeg/windows/ffmpeg.exe
ls -lh assets/ffmpeg/macos/ffmpeg
echo
echo "You can now build the Flutter app with: flutter build linux/windows/macos"

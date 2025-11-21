#!/bin/bash
# Cleanup script to remove desktop-specific files

echo "Removing desktop-specific files and folders..."

# Remove Flutter desktop platforms
rm -rf flutter_app/windows
rm -rf flutter_app/linux
rm -rf flutter_app/web

# Remove desktop build scripts
rm -f flutter_app/build_linux.sh
rm -f flutter_app/download_ffmpeg.sh
rm -f flutter_app/DISTRIBUTION.md

# Remove Python CLI and web app
rm -f app.py
rm -f tagfix.py
rm -f requirements.txt
rm -rf static
rm -rf templates
rm -rf __pycache__

# Remove old workflow
rm -f .github/workflows/release.yml

echo "Cleanup complete!"
echo ""
echo "The following files have been removed:"
echo "  - flutter_app/windows/"
echo "  - flutter_app/linux/"
echo "  - flutter_app/web/"
echo "  - flutter_app/build_linux.sh"
echo "  - flutter_app/download_ffmpeg.sh"
echo "  - flutter_app/DISTRIBUTION.md"
echo "  - app.py, tagfix.py, requirements.txt"
echo "  - static/, templates/, __pycache__/"
echo "  - .github/workflows/release.yml"

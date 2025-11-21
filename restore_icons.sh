#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/flutter/flutter/master/examples/hello_world/android/app/src/main/res"
RES_DIR="/home/zuke/tagfixandroid/flutter_app/android/app/src/main/res"

# Download icons for each density
for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    echo "Downloading icon for $density..."
    mkdir -p "$RES_DIR/mipmap-$density"
    curl -s -o "$RES_DIR/mipmap-$density/ic_launcher.png" "$BASE_URL/mipmap-$density/ic_launcher.png"
    
    if [ -f "$RES_DIR/mipmap-$density/ic_launcher.png" ]; then
        echo "Success: $density"
    else
        echo "Failed: $density"
    fi
done

echo "Icon download complete."

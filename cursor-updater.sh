#!/bin/bash
# ----------------------------------------------------------------
# Cursor IDE Auto-Updater for Linux
# 
# This script automatically checks for and installs the latest version
# of Cursor IDE on Linux Ubuntu systems. It downloads the AppImage to
# the user's applications directory and sets up desktop integration.
#
# License: MIT
# Copyright (c) 2025 Lukáš Sukeník
# See LICENSE file for details
# ----------------------------------------------------------------

# Exit on any error
set -e

# Configuration variables
APP_DIR="/opt/cursor"
ICON_PATH="/opt/cursor/cursor.svg"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
ICON_REGISTRY_URL="https://registry.npmmirror.com/@lobehub/icons-static-svg/latest/files/icons/cursor.svg"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Function to display error messages and exit
error_exit() {
    echo -e "\e[31mError: $1\e[0m" >&2
    exit 1
}

# Function to display success messages
success_message() {
    echo -e "\e[32m$1\e[0m"
}

# Function to display information messages
info_message() {
    echo -e "\e[34m$1\e[0m"
}

# Function to check if a command is available
check_command() {
    command -v "$1" &> /dev/null || error_exit "$1 is required but not installed. Please install it with: sudo apt install $1"
}

# Check for required commands
check_command curl
check_command jq

# Create application directory if it doesn't exist
sudo mkdir -p "$APP_DIR" || error_exit "Failed to create directory $APP_DIR"

# Get current Cursor version (if installed)
current_version=""
current_appimage=$(find "$APP_DIR" -name "Cursor-*-x86_64.AppImage" | sort -V | tail -n 1)
if [ -n "$current_appimage" ]; then
    current_version=$(basename "$current_appimage" | sed -E 's/Cursor-(.+)-x86_64.AppImage/\1/')
    info_message "Found existing Cursor installation (version $current_version)"
else
    info_message "No existing Cursor installation found"
fi

# Fetch information about the latest version
info_message "Checking for latest Cursor version..."
api_response=$(curl -s -A "$USER_AGENT" "$API_URL")

# Extract version and download URL using jq
if ! latest_version=$(echo "$api_response" | jq -r '.version'); then
    error_exit "Failed to parse API response"
fi

if ! download_url=$(echo "$api_response" | jq -r '.downloadUrl'); then
    error_exit "Failed to get download URL from API response"
fi

# Check if we need to update
if [ "$current_version" = "$latest_version" ]; then
    success_message "Cursor is already up to date (version $current_version)"
    exit 0
fi

info_message "New version available: $latest_version"
info_message "Downloading Cursor $latest_version..."

# Download the latest version
new_appimage="$APP_DIR/Cursor-$latest_version-x86_64.AppImage"
if ! sudo curl -L -A "$USER_AGENT" -o "$new_appimage" "$download_url"; then
    error_exit "Failed to download Cursor"
fi

# Make the AppImage executable
sudo chmod +x "$new_appimage" || error_exit "Failed to make AppImage executable"

# Remove the old version if it exists
if [ -n "$current_appimage" ] && [ -f "$current_appimage" ]; then
    info_message "Removing old version..."
    sudo rm "$current_appimage" || error_exit "Failed to remove old version"
fi

success_message "Cursor $latest_version has been successfully downloaded to $new_appimage"

# Check for icon and install if needed
if [ ! -f "$ICON_PATH" ]; then    
    # Create icon directory if it doesn't exist
    sudo mkdir -p "$(dirname "$ICON_PATH")" || error_exit "Failed to create icon directory"
    
    # Download icon from npm registry (automatically resolves to latest version)
    info_message "Downloading Cursor icon from registry..."

    if sudo curl -L --silent --fail -A "$USER_AGENT" -o "$ICON_PATH" "$ICON_REGISTRY_URL"; then
        success_message "Icon downloaded successfully"
    else
        info_message "Icon download failed, application will use system default icon"
    fi
fi

# Create desktop entry
info_message "Creating desktop entry..."
cat << EOF | sudo tee "$DESKTOP_FILE" > /dev/null
[Desktop Entry]
Name=Cursor
Exec="$new_appimage" %F
Icon=$ICON_PATH
Terminal=false
Type=Application
StartupWMClass=Cursor
X-AppImage-Version=$latest_version
Comment=AI-first code editor
Categories=Development;IDE;TextEditor;
Keywords=cursor;editor;ide;code;programming;
EOF

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    sudo update-desktop-database || true
fi

success_message "Cursor IDE $latest_version installation complete!"
success_message "You can now launch Cursor from your application menu or run:"
info_message "  $new_appimage"

exit 0

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
readonly APP_DIR="/opt/cursor"
readonly ICON_PATH="/opt/cursor/cursor.svg"
readonly DESKTOP_FILE="/usr/share/applications/cursor.desktop"
readonly API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
readonly ICON_REGISTRY_URL="https://registry.npmmirror.com/@lobehub/icons-static-svg/latest/files/icons/cursor.svg"
readonly USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

main() {
    checkPrerequisites

    local version_info
    version_info=$(checkVersions)

    local latest_version download_url new_appimage
    latest_version="${version_info%|*}"
    download_url="${version_info#*|}"
    new_appimage=$(downloadAndInstall "$latest_version" "$download_url")
    
    setupDesktopIntegration "$new_appimage" "$latest_version"
    display_completion_message "$latest_version" "$new_appimage"
}

checkPrerequisites() {
    check_command curl
    check_command jq
    ensure_directory "$APP_DIR"
}

checkVersions() {
    local current_version
    current_version=$(get_current_version)
    display_installation_info "$current_version"
    
    local version_info latest_version download_url
    version_info=$(get_latest_version_info)
    latest_version="${version_info%|*}"
    download_url="${version_info#*|}"
    
    check_if_update_needed "$current_version" "$latest_version"
    info_message "New version available: $latest_version"
    
    echo "$latest_version|$download_url"
}

downloadAndInstall() {
    local latest_version="$1"
    local download_url="$2"
    local current_version
    current_version=$(get_current_version)
    
    local new_appimage
    new_appimage=$(download_cursor "$latest_version" "$download_url")
    cleanup_old_version "$current_version"
    success_message "Cursor $latest_version has been successfully downloaded to $new_appimage"
    
    echo "$new_appimage"
}

setupDesktopIntegration() {
    local new_appimage="$1"
    local latest_version="$2"
    
    install_icon
    create_desktop_entry "$new_appimage" "$latest_version"
}

# Display functions
error_exit() {
    echo -e "\e[31mError: $1\e[0m" >&2
    exit 1
}

success_message() {
    echo -e "\e[32m$1\e[0m" >&2
}

info_message() {
    echo -e "\e[34m$1\e[0m" >&2
}

# Utility functions
check_command() {
    command -v "$1" &> /dev/null || error_exit "$1 is required but not installed. Please install it with: sudo apt install $1"
}

ensure_directory() {
    local dir="$1"
    sudo mkdir -p "$dir" || error_exit "Failed to create directory $dir"
}

# Core business logic functions
get_current_version() {
    local current_appimage
    current_appimage=$(find "$APP_DIR" -name "Cursor-*-x86_64.AppImage" | sort -V | tail -n 1)
    
    if [ -n "$current_appimage" ]; then
        basename "$current_appimage" | sed -E 's/Cursor-(.+)-x86_64.AppImage/\1/'
    else
        echo ""
    fi
}

get_latest_version_info() {
    info_message "Checking for latest Cursor version..."
    local api_response
    api_response=$(curl -s -A "$USER_AGENT" "$API_URL") || error_exit "Failed to fetch version information"
    
    local latest_version download_url
    latest_version=$(echo "$api_response" | jq -r '.version') || error_exit "Failed to parse version from API response"
    download_url=$(echo "$api_response" | jq -r '.downloadUrl') || error_exit "Failed to get download URL from API response"
    
    echo "$latest_version|$download_url"
}

download_cursor() {
    local cursor_version="$1"
    local download_url="$2"
    local target_file="$APP_DIR/Cursor-$cursor_version-x86_64.AppImage"
    
    info_message "Downloading Cursor $cursor_version..."
    sudo curl -L -A "$USER_AGENT" -o "$target_file" "$download_url" || error_exit "Failed to download Cursor"
    sudo chmod +x "$target_file" || error_exit "Failed to make AppImage executable"
    
    echo "$target_file"
}

cleanup_old_version() {
    local old_cursor_version="$1"
    
    if [ -n "$old_cursor_version" ]; then
        local old_appimage="$APP_DIR/Cursor-$old_cursor_version-x86_64.AppImage"
        if [ -f "$old_appimage" ]; then
            info_message "Removing old version..."
            sudo rm "$old_appimage" || error_exit "Failed to remove old version"
        fi
    fi
}

install_icon() {
    if [ -f "$ICON_PATH" ]; then
        return 0
    fi
    
    ensure_directory "$(dirname "$ICON_PATH")"
    info_message "Downloading Cursor icon from registry..."
    
    if sudo curl -L --silent --fail -A "$USER_AGENT" -o "$ICON_PATH" "$ICON_REGISTRY_URL"; then
        success_message "Icon downloaded successfully"
    else
        info_message "Icon download failed, application will use system default icon"
    fi
}

create_desktop_entry() {
    local cursor_appimage_path="$1"
    local cursor_version="$2"
    
    info_message "Creating desktop entry..."
    cat << EOF | sudo tee "$DESKTOP_FILE" > /dev/null
[Desktop Entry]
Name=Cursor
Exec="$cursor_appimage_path" %F
Icon=$ICON_PATH
Terminal=false
Type=Application
StartupWMClass=Cursor
X-AppImage-Version=$cursor_version
Comment=AI-first code editor
Categories=Development;IDE;TextEditor;
Keywords=cursor;editor;ide;code;programming;
EOF

    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database || true
    fi
}

check_if_update_needed() {
    local current_version="$1"
    local latest_version="$2"
    
    if [ "$current_version" = "$latest_version" ]; then
        success_message "Cursor is already up to date (version $current_version)"
        exit 0
    fi
}

display_installation_info() {
    local current_version="$1"
    
    if [ -n "$current_version" ]; then
        info_message "Found existing Cursor installation (version $current_version)"
    else
        info_message "No existing Cursor installation found"
    fi
}

display_completion_message() {
    local version="$1"
    local appimage_path="$2"
    
    success_message "Cursor IDE $version installation complete!"
    success_message "You can now launch Cursor from your application menu or run:"
    info_message "  $appimage_path"
}

# Run the main function
main "$@"

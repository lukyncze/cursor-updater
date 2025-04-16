# Cursor Updater for Linux

A Bash script that automatically checks for and installs the latest version of Cursor IDE on Linux systems.

## Features

- Automatically detects existing Cursor installations
- Fetches the latest version information from the official API
- Downloads the latest AppImage if an update is available
- Creates desktop integration for easy access
- Cleans up old versions

## Requirements

- Linux (Ubuntu/Debian-based systems)
- `curl`
- `jq`

## Installation

1. Clone this repository or download the script:

   ```bash
   git clone https://github.com/yourusername/cursor-updater.git
   ```

2. Make the script executable:
   ```bash
   chmod +x cursor-updater.sh
   ```

## Usage

Simply run the script:

```bash
./cursor-updater.sh
```

The script will:

1. Check if Cursor is already installed
2. Fetch information about the latest available version
3. Download and install the latest version if needed
4. Create a desktop shortcut for easy access

## Configuration

The script uses the following default paths:

- Apps directory: `~/Documents/apps/`
- Desktop file: `~/.local/share/applications/cursor.desktop`
- Icon path: `~/Pictures/svg-icons/cursor.svg`

You can modify these paths in the script if needed.

## Notes

- The script requires internet access to check for updates
- Administrator privileges are not required for installation
- Currently, the icon download feature is not implemented (marked as TODO)


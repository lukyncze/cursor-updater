# Cursor Updater for Linux

A Bash script that automatically checks for and installs the latest version of Cursor IDE on Linux systems.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Features

- Automatically detects existing Cursor installations
- Fetches the latest version information from the official Cursor API
- Downloads the latest AppImage if an update is available
- Creates system-wide desktop integration
- Downloads and installs the official Cursor icon
- Cleans up old versions automatically

## Requirements

- Linux (Ubuntu/Debian-based systems)
- Internet connection for downloading updates and icon
- `sudo` privileges - required for system-wide installation
- `curl` - for downloading files and API calls
- `jq` - for parsing JSON responses

## Installation

```bash
git clone https://github.com/lukyncze/cursor-updater
cd cursor-updater
chmod +x cursor-updater.sh
```

## Usage

Run the script with sudo privileges:

```bash
sudo ./cursor-updater.sh
```

The script will:

1. Check for required dependencies (`curl` and `jq`)
2. Create the application directory if it doesn't exist
3. Check if Cursor is already installed and display current version
4. Fetch information about the latest available version from Cursor API
5. Compare versions and skip download if already up to date
6. Download and install the latest version if an update is available
7. Download the official Cursor icon from GitHub registry (if not already present)
8. Create a comprehensive desktop entry with proper categorization
9. Update the desktop database for immediate availability
10. Clean up old versions to save disk space

## Configuration

The script uses the following system paths:

- **Application directory**: `/opt/cursor/`
- **Icon path**: `/opt/cursor/cursor-icon.png`
- **Desktop file**: `/usr/share/applications/cursor.desktop`
- **API endpoint**: `https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable`
- **Icon source**: GitHub repository (this project)

These paths ensure proper system-wide integration and can be modified in the script's configuration variables if needed.

## Notes

- The script requires internet access to check for updates and download files
- Administrator privileges (sudo) are required for system-wide installation
- The script automatically handles cleanup of old versions
- Desktop integration is created for all users on the system
- If icon download fails, the application will use the system default icon
- The script uses version-specific filenames (e.g., `Cursor-1.2.3-x86_64.AppImage`)
- Color-coded output: green for success, blue for info, red for errors
- The script exits gracefully if already up to date

## Troubleshooting

If you encounter issues:

1. Ensure you have the required dependencies installed:

```bash
sudo apt update
sudo apt install curl jq
```

2. Make sure you're running the script with sudo privileges

3. Check your internet connection for downloading updates

4. Verify you have sufficient disk space in `/opt/cursor/`

5. If the API is unreachable, check if Cursor's servers are accessible

6. For permission issues, ensure the script has execute permissions (`chmod +x cursor-updater.sh`)


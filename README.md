# Cursor Updater for Linux

A Bash script that automatically checks for and installs the latest version of Cursor IDE on Linux systems.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Features

- Automatically detects existing Cursor installations
- Fetches the latest version information from the official Cursor API
- Downloads the latest AppImage if an update is available
- Creates system-wide desktop integration for easy access
- Downloads and installs the official Cursor icon
- Cleans up old versions automatically
- Uses system-wide installation paths for better integration

## Requirements

- Linux (Ubuntu/Debian-based systems)
- `curl` - for downloading files and API calls
- `jq` - for parsing JSON responses
- `sudo` privileges - required for system-wide installation

## Installation

1. Clone this repository or download the script:

   ```bash
   git clone https://github.com/lukyncze/cursor-updater
   cd cursor-updater
   ```

2. Make the script executable:
   ```bash
   chmod +x cursor-updater.sh
   ```

## Usage

Run the script with sudo privileges:

```bash
sudo ./cursor-updater.sh
```

The script will:

1. Check for required dependencies (`curl` and `jq`)
2. Check if Cursor is already installed and get current version
3. Fetch information about the latest available version from Cursor API
4. Download and install the latest version if an update is available
5. Download the official Cursor icon
6. Create a system-wide desktop entry for easy access
7. Clean up old versions

## Configuration

The script uses the following system paths:

- **Application directory**: `/opt/cursor/`
- **Icon path**: `/opt/cursor/cursor.svg`
- **Desktop file**: `/usr/share/applications/cursor.desktop`

These paths ensure proper system-wide integration and can be modified in the script's configuration variables if needed.

## Notes

- The script requires internet access to check for updates and download files
- Administrator privileges (sudo) are required for system-wide installation
- The script automatically handles cleanup of old versions
- Desktop integration is created for all users on the system
- If icon download fails, the application will use the system default icon

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


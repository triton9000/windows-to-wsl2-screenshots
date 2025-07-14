#!/bin/bash

# Create a shareable package for the Windows-to-WSL2 Screenshot Tool

echo "📦 Creating shareable package..."

# Create a temporary directory for the package
PACKAGE_NAME="windows-to-wsl2-screenshots-installer"
TEMP_DIR="/tmp/$PACKAGE_NAME"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Copy necessary files
cp screenshot-functions.sh "$TEMP_DIR/"
cp auto-clipboard-monitor.ps1 "$TEMP_DIR/"

# Create the all-in-one installer
cat > "$TEMP_DIR/install.sh" << 'EOF'
#!/bin/bash

echo "🚀 Installing Windows-to-WSL2 Screenshot Tool..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Installation directory
INSTALL_DIR="$HOME/dev/projects/windows-to-wsl2-screenshots"

# Create directory
mkdir -p "$INSTALL_DIR"

# Copy files
echo "📂 Copying files..."
cp "$SCRIPT_DIR/screenshot-functions.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/auto-clipboard-monitor.ps1" "$INSTALL_DIR/"

# Create screenshots directory
mkdir -p "$HOME/.screenshots"

# Add to bashrc if not already present
BASHRC_ENTRY='# Auto-start Windows-to-WSL2 screenshot monitor
if [ -f "$HOME/dev/projects/windows-to-wsl2-screenshots/screenshot-functions.sh" ]; then
    source "$HOME/dev/projects/windows-to-wsl2-screenshots/screenshot-functions.sh"
    # Check if monitor is not already running before starting
    if ! check-screenshot-monitor >/dev/null 2>&1; then
        start-screenshot-monitor >/dev/null 2>&1 &
    fi
fi'

if ! grep -q "windows-to-wsl2-screenshots/screenshot-functions.sh" "$HOME/.bashrc"; then
    echo "📝 Adding auto-start to .bashrc..."
    echo "" >> "$HOME/.bashrc"
    echo "$BASHRC_ENTRY" >> "$HOME/.bashrc"
else
    echo "✅ Auto-start already configured"
fi

# Source and start
cd "$INSTALL_DIR"
source screenshot-functions.sh
start-screenshot-monitor

echo ""
echo "✅ Installation complete!"
echo ""
echo "📸 The screenshot monitor is now running!"
echo "   - Take screenshots with Win+Shift+S or Snagit"
echo "   - Paths auto-copy to clipboard for pasting"
echo ""
echo "🔧 Commands:"
echo "   check-screenshot-monitor  - Check status"
echo "   stop-screenshot-monitor   - Stop monitor"
echo "   start-screenshot-monitor  - Start manually"
EOF

# Create simple README
cat > "$TEMP_DIR/README.txt" << 'EOF'
Windows-to-WSL2 Screenshot Tool
==============================

INSTALLATION:
1. Extract this folder anywhere
2. Open WSL2 terminal
3. Navigate to the extracted folder
4. Run: bash install.sh

USAGE:
- Take screenshots in Windows (Win+Shift+S or Snagit)
- Paste the path (Ctrl+V) into Claude Code, VS Code, etc.

The tool auto-starts with new terminals after installation.

REQUIREMENTS:
- Windows 10/11 with WSL2
- Windows Terminal recommended for best clipboard support
EOF

# Make installer executable
chmod +x "$TEMP_DIR/install.sh"

# Create the archive
cd /tmp
tar -czf "$HOME/windows-to-wsl2-screenshots-installer.tar.gz" "$PACKAGE_NAME"
cd - > /dev/null

# Also create a zip for Windows users
cd /tmp
zip -r "$HOME/windows-to-wsl2-screenshots-installer.zip" "$PACKAGE_NAME"
cd - > /dev/null

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Package created successfully!"
echo ""
echo "📦 Share these files with your team:"
echo "   - $HOME/windows-to-wsl2-screenshots-installer.tar.gz (for Linux users)"
echo "   - $HOME/windows-to-wsl2-screenshots-installer.zip (for Windows users)"
echo ""
echo "📋 Installation instructions for team:"
echo "   1. Send them the .zip or .tar.gz file"
echo "   2. They extract it"
echo "   3. They run: bash install.sh"
echo ""
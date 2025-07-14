#!/bin/bash

# Windows-to-WSL2 Screenshot Tool Installer
# One-line install: curl -sSL https://raw.githubusercontent.com/jddev273/windows-to-wsl2-screenshots/main/install.sh | bash

set -e

echo "🚀 Installing Windows-to-WSL2 Screenshot Tool..."

# Determine installation directory
INSTALL_DIR="$HOME/dev/projects/windows-to-wsl2-screenshots"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone or update the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "📦 Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "📦 Cloning repository..."
    git clone https://github.com/jddev273/windows-to-wsl2-screenshots.git "$INSTALL_DIR"
fi

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
    echo "✅ Auto-start already configured in .bashrc"
fi

# Source the functions and start the monitor
cd "$INSTALL_DIR"
source screenshot-functions.sh
start-screenshot-monitor

echo ""
echo "✅ Installation complete!"
echo ""
echo "📸 Screenshot monitor is now running!"
echo "   - Take screenshots with Win+Shift+S or Snagit"
echo "   - Paths auto-copy to clipboard"
echo "   - Auto-starts with new terminals"
echo ""
echo "📁 Screenshots save to: ~/.screenshots/"
echo ""
echo "🛠️  Commands available:"
echo "   check-screenshot-monitor  - Check if running"
echo "   stop-screenshot-monitor   - Stop the monitor"
echo "   start-screenshot-monitor  - Start manually"
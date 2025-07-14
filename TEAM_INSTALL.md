# Quick Install for Team Members

## One-Line Install (Easiest!)

Just run this in your WSL2 terminal:

```bash
curl -sSL https://raw.githubusercontent.com/jddev273/windows-to-wsl2-screenshots/main/install.sh | bash
```

That's it! The tool will:
- ✅ Auto-install everything
- ✅ Start the screenshot monitor
- ✅ Set up auto-start for future sessions
- ✅ Create the screenshots folder

## What Happens After Install

1. **Take a screenshot** in Windows (Win+Shift+S or Snagit)
2. **Paste** (Ctrl+V) the path directly into Claude Code or VS Code
3. The tool runs automatically in the background

## Manual Install (Alternative)

If you prefer to see what's happening:

```bash
# 1. Clone the repo
git clone https://github.com/jddev273/windows-to-wsl2-screenshots.git
cd windows-to-wsl2-screenshots

# 2. Run the installer
./install.sh
```

## Verify It's Working

```bash
check-screenshot-monitor
```

You should see: "✅ Screenshot automation is running"

## Troubleshooting

- **Using Windows Terminal?** Great! It has the best clipboard support
- **Using basic WSL terminal?** Switch to Windows Terminal for better results
- **Not working?** Check the log: `cat ~/.screenshots/monitor.log`

## Support

Having issues? Ask the person who shared this with you, or check the [GitHub repo](https://github.com/jddev273/windows-to-wsl2-screenshots).
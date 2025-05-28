# True automatic clipboard monitor using Windows events
param(
    [string]$SaveDirectory = "~/.screenshots",
    [string]$WslDistro = "auto"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Convert the tilde path to WSL format
if ($SaveDirectory -eq "~/.screenshots") {
    # Try to auto-detect WSL distribution if auto mode is used
    if ($WslDistro -eq "auto") {
        $WslDistros = @(wsl.exe -l -q | Where-Object { 
            $_ -and $_.Trim() -ne "" -and $_ -notlike "*docker*" 
        } | ForEach-Object { 
            $_.Trim() -replace '\s+', '' -replace '\x00', ''
        })
        if ($WslDistros.Count -gt 0) {
            $WslDistro = $WslDistros[0]
            Write-Host "🔍 Auto-detected WSL distribution: $WslDistro"
        }
    }
    $SaveDirectory = "\\wsl.localhost\$WslDistro\home\$env:USERNAME\.screenshots"
}

if (!(Test-Path $SaveDirectory)) {
    New-Item -ItemType Directory -Path $SaveDirectory -Force | Out-Null
}

Write-Host "🚀 WINDOWS-TO-WSL2 SCREENSHOT AUTOMATION STARTED"
Write-Host "📁 Auto-saving images to: $SaveDirectory"
Write-Host "🛑 Press Ctrl+C to stop"
Write-Host ""
Write-Host "🔥 MAGIC WORKFLOW:"
Write-Host "   1. Take screenshot (Win+Shift+S, Win+PrintScreen, etc.)"
Write-Host "   2. Image automatically saved to WSL2!"
Write-Host "   3. Path automatically copied to both Windows & WSL2 clipboards!"
Write-Host "   4. Just Ctrl+V in Claude Code or any application!"
Write-Host ""

Write-Host "👀 Monitoring clipboard events and directory changes..."
$previousHash = $null
$lastFileTime = Get-Date

# Function to copy path to both clipboards
function Set-BothClipboards($path) {
    try {
        [System.Windows.Forms.Clipboard]::SetText($path)
        $wslCommand = "echo '$path' | clip.exe"
        wsl.exe -d $WslDistro -e bash -c $wslCommand
        return $true
    } catch {
        Start-Sleep -Milliseconds 200
        try {
            [System.Windows.Forms.Clipboard]::SetText($path)
            $wslCommand = "echo '$path' | clip.exe" 
            wsl.exe -d $WslDistro -e bash -c $wslCommand
            return $true
        } catch {
            Write-Warning "Could not set clipboard: $_"
            return $false
        }
    }
}

while ($true) {
    try {
        Start-Sleep -Milliseconds 500
        
        # Monitor clipboard for new images
        if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
            $image = [System.Windows.Forms.Clipboard]::GetImage()
            if ($image) {
                $ms = New-Object System.IO.MemoryStream
                $image.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
                $imageBytes = $ms.ToArray()
                $ms.Dispose()
                $currentHash = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash($imageBytes))
                
                if ($currentHash -ne $previousHash) {
                    Write-Host "📸 New screenshot detected in clipboard"
                    
                    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
                    $filename = "screenshot_$timestamp.png"
                    $filepath = Join-Path $SaveDirectory $filename
                    $image.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
                    
                    # Update the latest.png symlink
                    $latestPath = Join-Path $SaveDirectory "latest.png"
                    if (Test-Path $latestPath) { Remove-Item $latestPath -Force }
                    Copy-Item $filepath $latestPath -Force
                    
                    $relativePath = "~/.screenshots/$filename"
                    Start-Sleep -Milliseconds 1000
                    
                    if (Set-BothClipboards $relativePath) {
                        Write-Host "✅ AUTO-SAVED: $filename"
                        Write-Host "📋 Path ready for Ctrl+V: $relativePath"
                        Write-Host ""
                    }
                    
                    $previousHash = $currentHash
                }
                $image.Dispose()
            }
        }
        
        # Also check for new files in the directory (for drag-drop screenshots)
        $currentTime = Get-Date
        $newFiles = Get-ChildItem $SaveDirectory -Filter "*.png" | Where-Object { 
            $_.LastWriteTime -gt $lastFileTime -and $_.Name -ne "latest.png" -and !$_.Name.StartsWith("screenshot_")
        }
        
        if ($newFiles) {
            foreach ($file in $newFiles) {
                $relativePath = "~/.screenshots/$($file.Name)"
                Copy-Item $file.FullName (Join-Path $SaveDirectory "latest.png") -Force
                
                if (Set-BothClipboards $relativePath) {
                    Write-Host "📁 NEW FILE DETECTED: $($file.Name)"
                    Write-Host "📋 Path ready for Ctrl+V: $relativePath"
                    Write-Host ""
                }
            }
            $lastFileTime = $currentTime
        }
        
    } catch {
        Write-Warning "⚠️ Error in main loop: $_"
        Start-Sleep -Milliseconds 1000
    }
}
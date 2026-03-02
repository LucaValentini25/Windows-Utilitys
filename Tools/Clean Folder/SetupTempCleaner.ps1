Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =====================================================
# 1️ Folder selector
# =====================================================

Write-Host "[1/6] Selecting base folder..."

$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description = "Seleccioná dónde crear la carpeta _AutoCleaner"
$folderDialog.ShowNewFolderButton = $true

if ($folderDialog.ShowDialog() -ne "OK") {
    Write-Host "[CANCELLED] No folder selected."
    Read-Host "Press Enter to exit"
    exit
}

$BasePath = $folderDialog.SelectedPath
Write-Host "[OK] Base path: $BasePath"

$ParentFolder = Join-Path $BasePath "_AutoCleaner"
$TempFolder   = Join-Path $ParentFolder "Carpeta Temporal"

New-Item -ItemType Directory -Force -Path $ParentFolder | Out-Null
New-Item -ItemType Directory -Force -Path $TempFolder   | Out-Null
Write-Host "[OK] Folders created: $ParentFolder"

# =====================================================
# 2️ Cleaner script
# =====================================================

Write-Host "[2/6] Creating cleaner script..."

$CleanerScriptPath = Join-Path $ParentFolder "ClearTemp.ps1"

$CleanerScript = @"
`$Folder = "$TempFolder"
if (Test-Path `$Folder) {
    Get-ChildItem `$Folder -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
"@

Set-Content -Path $CleanerScriptPath -Value $CleanerScript -Encoding UTF8 -Force
Write-Host "[OK] Script saved: $CleanerScriptPath"

# =====================================================
# 3️ Startup shortcut
# =====================================================

Write-Host "[3/6] Creating startup shortcut..."

$StartupPath  = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupPath "TempCleaner.lnk"

$WScript  = New-Object -ComObject WScript.Shell
$Shortcut = $WScript.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath       = "powershell.exe"
$Shortcut.Arguments        = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$CleanerScriptPath`""
$Shortcut.WorkingDirectory = $ParentFolder
$Shortcut.Save()
Write-Host "[OK] Shortcut created: $ShortcutPath"

# =====================================================
# 4️ Load WinAPI types
# =====================================================

Write-Host "[4/6] Loading WinAPI types..."

try {
    Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class IconPicker {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern int PickIconDlg(
        IntPtr hwndOwner,
        StringBuilder pszIconPath,
        int cchIconPath,
        ref int piIconIndex
    );
}

public class WinAPI {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(
        int wEventId,
        uint uFlags,
        IntPtr dwItem1,
        IntPtr dwItem2
    );
}
"@ -ErrorAction Stop
    Write-Host "[OK] Types loaded."
} catch {
    Write-Host "[ERROR] Failed to load types: $_"
    Read-Host "Press Enter to exit"
    exit
}

# =====================================================
# 5️ Icon picker
# =====================================================

Write-Host "[5/6] Opening icon picker..."

$iconPath  = New-Object System.Text.StringBuilder 260
$iconPath.Append("$env:SystemRoot\System32\SHELL32.dll") | Out-Null
$iconIndex = 0

Write-Host "[DEBUG] Initial icon path: $($iconPath.ToString())"

try {
    $result = [IconPicker]::PickIconDlg([IntPtr]::Zero, $iconPath, 260, [ref]$iconIndex)
    Write-Host "[DEBUG] PickIconDlg returned: $result"
    Write-Host "[DEBUG] Icon path after dialog: $($iconPath.ToString())"
    Write-Host "[DEBUG] Icon index: $iconIndex"
} catch {
    Write-Host "[ERROR] PickIconDlg failed: $_"
    Read-Host "Press Enter to exit"
    exit
}

if ($result -eq 0) {
    Write-Host "[CANCELLED] Icon selection cancelled by user."
    Read-Host "Press Enter to exit"
    exit
}

$expandedIconPath = [Environment]::ExpandEnvironmentVariables($iconPath.ToString())
Write-Host "[OK] Icon selected: $expandedIconPath, index $iconIndex"

# =====================================================
# 6️ Apply icon to folder
# =====================================================

Write-Host "[6/6] Applying icon to folder..."

$desktopIni = Join-Path $TempFolder "desktop.ini"

if (Test-Path $desktopIni) {
    Write-Host "[DEBUG] Removing existing desktop.ini..."
    attrib -h -s "$desktopIni"
    Remove-Item $desktopIni -Force
}

$iniContent = @"
[.ShellClassInfo]
IconResource=$expandedIconPath,$iconIndex
ConfirmFileOp=0
"@

try {
    Set-Content -Path $desktopIni -Value $iniContent -Encoding Unicode -Force
    Write-Host "[OK] desktop.ini written."
} catch {
    Write-Host "[ERROR] Failed to write desktop.ini: $_"
    Read-Host "Press Enter to exit"
    exit
}

attrib +h +s "$desktopIni"
attrib +s "$TempFolder"
Write-Host "[OK] Attributes applied."

$ptr = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($TempFolder)
[WinAPI]::SHChangeNotify(0x00002000, 0x1005, $ptr, [IntPtr]::Zero)
[System.Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
Write-Host "[OK] Shell notified."

# =====================================================
# Quick Access dialog
# =====================================================

$pinAnswer = [System.Windows.Forms.MessageBox]::Show(
    "¿Querés agregar 'Carpeta Temporal' a Acceso Rápido?",
    "Acceso Rápido",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($pinAnswer -eq [System.Windows.Forms.DialogResult]::Yes) {
    $shell  = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace($TempFolder)
    $folder.Self.InvokeVerb("pintohome")
    Write-Host "[OK] Pinned to Quick Access."
} else {
    Write-Host "[SKIP] Quick Access pin skipped by user."
}

Write-Host ""
Write-Host "=============================="
Write-Host " Setup complete!"
Write-Host " Location : $ParentFolder"
Write-Host " Icon     : $expandedIconPath,$iconIndex"
Write-Host "=============================="

Read-Host "Press Enter to exit"
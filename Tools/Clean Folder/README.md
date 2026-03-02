# SetupTempCleaner 🧹

Automatically sets up a self-cleaning temporary folder on your Windows system. On every startup, the folder empties itself silently in the background — no manual cleanup needed.

---

## ✨ Features

- 📁 Choose where to install the folder via a native folder picker
- 🎨 Pick a custom icon using the native Windows icon dialog
- 📌 Optionally pin the folder to Quick Access
- 🔁 Registers a startup shortcut that silently clears the folder on every login

---

## 📁 What gets created

```
<YourChosenPath>/
└── _AutoCleaner/
    ├── Carpeta Temporal/   ← your temp folder (auto-cleared on startup)
    └── ClearTemp.ps1       ← the cleanup script (runs on login)
```

A shortcut to `ClearTemp.ps1` is also placed in your Windows Startup folder so it runs automatically on every login.

---

## ▶️ Usage

### Option A — Run directly from PowerShell (no download needed)

```powershell
irm "https://raw.githubusercontent.com/LucaValentini25/Windows-Tools/main/Tools/SetupTempCleaner/SetupTempCleaner.ps1" | iex
```

### Option B — Download and run the `.exe`

> 📥 [Download SetupTempCleaner.exe](SetupTempCleaner.exe)

Double click it. No PowerShell required.

### Option C — Run the `.ps1` locally

```powershell
.\SetupTempCleaner.ps1
```

---

## 🔨 Build the `.exe` yourself

Requires [ps2exe](https://github.com/MScholtes/PS2EXE):

```powershell
Install-Module ps2exe -Scope CurrentUser -Force
Import-Module ps2exe
Invoke-ps2exe .\SetupTempCleaner.ps1 .\SetupTempCleaner.exe -title "AutoCleaner Setup"
```

---

## ⚙️ Requirements

- Windows 10 or later
- PowerShell 5.1+
- No admin rights required

---

## 📚 License

Licensed under the [MIT License](../../LICENSE).

---

Made with ❤️ by **Claster Tools**

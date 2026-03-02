# Windows Tools 🔧

This repository contains a collection of Windows automation tools developed by **Claster Tools** to improve workflow and productivity on Windows systems.

Each tool lives in its own folder inside `Tools/` and includes a dedicated README, a `.ps1` script you can run directly from PowerShell, and a compiled `.exe` for double-click execution.

---

## 🧩 How to Run a Tool

**Option A — Run directly from PowerShell (no download needed):**

```powershell
irm "https://raw.githubusercontent.com/LucaValentini25/Windows-Tools/main/Tools/<ToolName>/<ToolName>.ps1" | iex
```

**Option B — Download and run the `.exe`:**

Go to the tool's folder, download the `.exe` and double click it. No PowerShell required.

**Option C — Clone the repo:**

```powershell
git clone https://github.com/LucaValentini25/Windows-Tools.git
```

---

## 📦 Available Tools

### 🔹 SetupTempCleaner

Automatically sets up a self-cleaning temporary folder on your system. On every Windows startup, the folder empties itself silently in the background.

- 📁 Path: `Tools/SetupTempCleaner`
- 📖 [Read the Documentation](Tools/SetupTempCleaner/README.md)
- ▶️ Run via PowerShell:

```powershell
irm "https://raw.githubusercontent.com/LucaValentini25/Windows-Tools/main/Tools/SetupTempCleaner/SetupTempCleaner.ps1" | iex
```

---

## 📚 License

This repository is licensed under the [MIT License](LICENSE).  
You are free to use, modify, and distribute these tools.

---

## 🛠️ Disclaimer

You are free to download and use the tools provided by **Claster Tools**.

---

Made with ❤️ by **Claster Tools**

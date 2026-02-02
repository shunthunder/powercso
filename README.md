# PowerCSO

A PowerShell-based text user interface (TUI) wrapper for compressing PSP and PS2 ISO files using the powerful `maxcso.exe` tool.
It provides an interactive, menu-driven workflow, automatically handles dependencies where possible, and displays a detailed compression summary when processing is complete.

---

## Requirements
### PowerShell
- **Minimum:** PowerShell 5.1  
- **Recommended:** PowerShell 7.0 or newer  
- **Primary Tool:** `maxcso.exe`
PowerShell 7+ is strongly recommended for improved performance, stability, and modern features.  
It can be installed side-by-side with PowerShell 5.1 and does not replace it.
PowerCSO is a wrapper and does **not** include compression executables.


**Download:**  
Official GitHub releases (Windows binaries included):  
https://github.com/unknownbrackets/maxcso/releases
Download the file named similar to:  
`maxcso_vX.X.X_windows.7z`

---

### Optional / Advanced
**ziso.exe**
- A legacy ZSO compression tool
- **Not required** for normal operation

PowerCSO uses `maxcso.exe` for **CSO, ZSO, and DAX** compression by default.  
`ziso.exe` is only needed if you modify the script to explicitly target it or prefer legacy workflows.

**Source code (no official precompiled Windows binary is provided):**  
https://github.com/Danixu/ziso_compressor

> You must obtain `maxcso.exe` or `ziso.exe` yourself if you choose to use it.

---

## Setup & Usage Instructions
### Download and extract maxcso
Extract the `maxcso` archive and place `maxcso.exe` in the same directory as the PowerCSO script.

### Run PowerCSO

- Run PowerShell as **Administrator** and execute the script  
**OR**
- Right-click the script file and select **Run with PowerShell**

The script will verify the PowerShell version and automatically install required dependencies if needed.

**Note:**  
The PowerCSO script and `maxcso.exe` can be placed in **any folder of your choice** with valid permissions  
(for example: `D:\PSP_Tools\`).

---

### First-run prompts

You may be prompted to trust **PSGallery** or install the **NuGet provider**.
Type **Y** (Yes) or **A** (Yes to All) and press **Enter**.
This allows PowerCSO to automatically install required modules such as `Out-ConsoleGridView`.

---

## Features
- **Interactive TUI (Text User Interface)**
  - Menu-driven selection of:
    - ISO files
    - Compression formats (**CSO, ZSO, DAX**) via `maxcso.exe`
    - Optional compression flags and block sizes
- **Self-Healing Dependencies**
  - Automatically installs required PowerShell modules when missing
- **PowerShell Version Awareness**
  - Detects PowerShell 7 and can optionally check for updates using `winget`
  - (Administrator rights required)
- **Compression Summary**
  - Displays:
    - Total files processed
    - Original vs final size
    - Overall space savings

---

## Disclaimer
PowerCSO is provided **“as is”**, without warranty of any kind.  
Use this tool at your own risk.
This project is **not affiliated with or endorsed by** the `maxcso` project or its authors.  
`maxcso.exe` and `ziso.exe` are third-party tools and are **not distributed** with PowerCSO.

---

## License

This project is licensed under the **MIT License**.  
See the `LICENSE` file for details.

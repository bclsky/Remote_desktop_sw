# Remote Desktop SW

A lightweight Windows system tray utility designed for Remote Desktop (RDP) environments, enabling easy virtual desktop switching during remote sessions.

[中文文档](README_CN.md)

## Download

⬇️ [Download v1.0.0](https://github.com/bclsky/Remote_desktop_sw/releases/tag/v1.0.0)

## Features

- **Hotkey Desktop Switching** — Switch desktops with `Ctrl+Alt+←` / `Ctrl+Alt+→` by default, fully customizable
- **Toast Notifications** — Shows current desktop number (e.g., "Desktop 2 / 3") at the bottom of the screen on switch
- **RDP Auto-Reload** — Detects RDP window activation/deactivation and auto-reloads the script to keep hotkeys working
- **Auto-Start on Boot** — Toggle via registry, no extra setup needed
- **Screenshot to Path** — When pasting screenshots in terminals (Windows Terminal / PowerShell / CMD), automatically saves as PNG and inserts the file path
- **System Tray Menu** — All features accessible via right-click on the tray icon

## System Requirements

- Windows 10
- No AutoHotkey installation required — just run `Remote_desktop_sw.exe`

## Usage

1. Run `Remote_desktop_sw.exe`
2. The program runs silently in the system tray
3. Use `Ctrl+Alt+←` / `Ctrl+Alt+→` to switch virtual desktops
4. Right-click the tray icon to open settings, toggle features, or exit

## Tray Menu

| Menu Item | Description |
|-----------|-------------|
| Set Hotkeys | Open hotkey settings to customize switch shortcuts |
| Auto-Start | Toggle auto-start on boot via registry |
| Website | Open the official website in your browser |
| Screenshot to Path | Toggle screenshot-to-filepath paste feature |
| Exit | Exit the application |

## Configuration

A `settings.ini` file is generated in the same directory on first run:

```ini
[Hotkeys]
Left=^!Left      ; Switch desktop left (Ctrl+Alt+Left)
Right=^!Right    ; Switch desktop right (Ctrl+Alt+Right)

[Screenshot]
Enabled=1         ; Screenshot feature toggle (1=on, 0=off)
```

## Hotkey Format Reference

AutoHotkey v2 notation:

| Symbol | Key |
|--------|-----|
| `^` | Ctrl |
| `!` | Alt |
| `+` | Shift |
| `#` | Win |

## Project Structure

```
Remote_desktop_sw_Win10/
├── Remote_desktop_sw.exe   # Compiled executable
├── Remote_desktop_sw.ahk   # AutoHotkey v2 source code
├── VirtualDesktop.exe      # Virtual desktop switching helper (can be replaced, see below)
├── favicon.ico             # Tray icon
└── settings.ini            # User config (auto-generated on first run)
```

## Replacing VirtualDesktop.exe

The bundled `VirtualDesktop.exe` is version-specific. For compatibility with other Windows versions (e.g., Windows 11, Windows Server), you can download the latest release from the [VirtualDesktop](https://github.com/MScholtes/VirtualDesktop) project and replace the file in this directory.

## License

[MIT License](LICENSE)

## Links

- **Official Website:** [https://www.jiandankuai.com/software/6.html](https://www.jiandankuai.com/software/6.html)

## References

- [VirtualDesktop](https://github.com/MScholtes/VirtualDesktop) — Command-line virtual desktop manager, used for desktop switching
- [AutoHotkey](https://www.autohotkey.com/) — Windows automation scripting language, the foundation of this project

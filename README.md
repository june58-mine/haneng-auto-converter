<div align="center">

**🇺🇸 English** · [🇰🇷 한국어](./README.ko.md)

# HanEng Auto Converter

A lightweight Windows utility that fixes mistyped Korean/English text with a single <kbd>한/영</kbd> key press, automatically starts newly launched apps in Korean mode, and offers tray settings with GitHub release update checks.

<p>
  <img src="https://img.shields.io/badge/version-1.0.0-19191b?style=flat-square&labelColor=0f0f10" alt="Version 1.0.0" />
  <img src="https://img.shields.io/badge/license-MIT-19191b?style=flat-square&labelColor=0f0f10" alt="MIT License" />
  <img src="https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-19191b?style=flat-square&labelColor=0f0f10" alt="Windows 10 and 11" />
  <img src="https://img.shields.io/badge/AutoHotkey-v2.0-19191b?style=flat-square&labelColor=0f0f10" alt="AutoHotkey v2.0" />
</p>

</div>

## Features

### Bidirectional Typo Conversion

- **English → Korean on a single key press** (`Default: ON`): Forgot to switch from English to Korean (`dkssudgktpdy`)? Press <kbd>한/영</kbd> once to replace the mistyped text with `안녕하세요` and switch the IME to Korean mode at the same time.
- **Korean → English on a single key press** (`Default: ON`): Typed English while still in Korean mode (`ㅗ디ㅣㅐ`, `햣 ㅔㅕ노`)? Press <kbd>한/영</kbd> once to revert the screen syllables back to `hello`, `git push` and switch the IME to English mode.
- **False-positive guards & exact IME tracking**: Leaves real English words (`hello`, `test`, `API`, `git`, `for`, `the`, etc.) and real Korean sentences untouched, supports Korean chat jamo (`ㅋㅋㅋ`, `ㅎㅎ`, `ㅠㅠ`, `ㅜㅜ`, `ㅇㅇ`), and simulates Windows Dubeolsik IME composition and `Backspace` splitting so multi-syllable deletion counts match the screen exactly.

### Auto Korean Start on New Apps

- **Korean-first window initialization** (`Default: ON`): Uses Windows `SetWinEventHook` (`EVENT_SYSTEM_FOREGROUND`) with zero background polling to switch newly opened windows from English (`A`) to Korean (`가`) once per window.
- **Terminal & code editor exclusions**: Leaves terminals and editors (`WindowsTerminal.exe`, `cmd.exe`, `powershell.exe`, `pwsh.exe`, `Code.exe`, `Cursor.exe`, `devenv.exe`, `idea64.exe`, `pycharm64.exe`, `webstorm64.exe`, `Antigravity.exe`, `wezterm-gui.exe`, `alacritty.exe`, `mintty.exe`) in their own mode by default.
- **Non-intrusive switching**: Only checks each window handle once, so manual English/Korean switches inside an already opened window are preserved.

### Tray Settings & Update Check

- **Native Settings GUI**: Right-click (or double-click) the system tray icon and choose **설정... (Settings)** to toggle conversion directions, Auto Korean Start, or Windows Startup without editing files.
- **Custom exclusion list**: Add or remove excluded `.exe` names manually, pick directly from currently running windows, browse for an `.exe`, or restore the default list.
- **Update check**: Click **업데이트 확인 (Check for Updates)** in the tray menu or Settings window to check the latest GitHub Release (`june58-mine/haneng-auto-converter`) and jump directly to the download page when a newer version is available.

## Installation

1. Download the standalone executable from the latest release:

   <p>
     <a href="https://github.com/june58-mine/haneng-auto-converter/releases/latest/download/HanEngConverter.exe">
       <img src="https://img.shields.io/badge/Download_HanEngConverter.exe-v1.0.0-e5484d?style=for-the-badge&logo=windows&logoColor=white" alt="Download HanEngConverter.exe v1.0.0" />
     </a>
   </p>

2. Run `HanEngConverter.exe`.
3. To start automatically when signing in to Windows, open **Settings** from the tray icon and enable **Windows 시작 시 자동 실행 (Run at Windows startup)**.

> **Note (Windows SmartScreen):** Because `HanEngConverter.exe` is an unsigned community build, Windows Defender SmartScreen may display a warning on first launch. Click **More info → Run anyway** (**추가 정보 → 실행**) to proceed.

<details>
<summary>Running from source (.ahk) or building .exe manually</summary>

1. Install [AutoHotkey v2.0+](https://www.autohotkey.com/).
2. Run [`haneng_converter.ahk`](./haneng_converter.ahk) directly, or run the unit tests in [`tests/test_converter.ahk`](./tests/test_converter.ahk).
3. To compile a standalone executable with `Ahk2Exe`:
   ```powershell
   Ahk2Exe.exe /in haneng_converter.ahk /out dist\HanEngConverter.exe /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
   ```

</details>

## Conversion Examples & Controls

### Conversion Examples

| Direction | Typed Input | Press <kbd>한/영</kbd> (1x) | Behavior |
| --- | --- | --- | --- |
| English → Korean | `dkssudgktpdy` | `안녕하세요` | Converts & switches to Korean |
| English → Korean | `dkssud gktpdy` | `안녕 하세요` | Multi-word conversion |
| English → Korean | `zzz` | `ㅋㅋㅋ` | Converts repeating chat jamo |
| Korean → English | `ㅗ디ㅣㅐ` | `hello` | Converts & switches to English |
| Korean → English | `햣 ㅔㅕ노` | `git push` | Multi-word reverse conversion |
| Korean → English | `ㅗㅅ센://해ㅐ힏.ㅊㅐㅡ` | `https://google.com` | Converts URLs/identifiers |
| Untouched | `hello` (in EN) / `안녕하세요` / `ㅋㅋㅋ` | *(unchanged)* | Switches IME mode only |

### Tray Menu Controls

| Tray Action | Description |
| --- | --- |
| **설정...** *(Double-click)* | Opens the Settings window (features, Startup toggle, excluded apps) |
| **업데이트 확인...** | Queries GitHub Releases for a newer version |
| **자동 변환 활성화** | Pauses or resumes all conversion and auto-switch hooks |
| **새 앱 한글 자동 시작** | Quickly toggles Auto Korean Start for new windows |
| **버퍼 초기화** | Clears the current typing buffer manually |
| **종료** | Exits the utility |

## Technical & Compatibility Notes

- **Low background footprint**: Built on native AutoHotkey v2 event hooks (`InputHook` + `SetWinEventHook`) with no background polling loops or heavy dictionaries (`~4.17 MB` private memory / `~16.28 MB` working set on Windows 11 x64, `~0%` idle CPU).
- **Clipboard-safe replacement**: Uses Windows Unicode input (`SendText`) rather than overwriting the system clipboard, keeping Windows Clipboard History (`Win + V`) untouched.
- **Settings storage**: Saves user preferences and excluded executable names in `%APPDATA%\HanEngAutoConverter\settings.ini`.
- **Keyboard driver & UAC limits**: Targets standard Korean Dubeolsik (`vk15` / `kbd101a.dll`). Windows UIPI blocks non-elevated utilities from sending keys or reading IME state inside windows running as Administrator, and some custom WinUI3/UWP controls may ignore legacy `WM_IME_CONTROL` messages.

## License

Released under the [MIT License](./LICENSE).

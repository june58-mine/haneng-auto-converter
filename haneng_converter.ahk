#Requires AutoHotkey v2.0
#SingleInstance Force

;@Ahk2Exe-SetProductName HanEng Auto Converter
;@Ahk2Exe-SetDescription Bidirectional Korean/English typo fixer and auto-Korean starter
;@Ahk2Exe-SetVersion 1.0.0
;@Ahk2Exe-SetCopyright Copyright (c) 2026 june58-mine

#Include "%A_ScriptDir%\hangul_core.ahk"

; 한/영 키 1회 양방향 오타 자동 변환 + 새 프로그램 한글 자동 시작 + 트레이 설정 UI

try TraySetIcon("shell32.dll", 44)
A_IconTip := "한영 오타 자동 변환기 (v1.0.0)"

class Settings {
    static APP_NAME := "HanEng Auto Converter"
    static APP_VERSION := "1.0.0"
    static GITHUB_REPO := "june58-mine/haneng-auto-converter"
    static STARTUP_LNK := A_Startup "\HanEngConverter.lnk"
    static CONFIG_DIR := A_AppData "\HanEngAutoConverter"
    static CONFIG_PATH := Settings.CONFIG_DIR "\settings.ini"

    static DEFAULT_EXCLUDED_APPS := [
        "WindowsTerminal.exe", "cmd.exe", "powershell.exe", "pwsh.exe",
        "Code.exe", "Cursor.exe", "devenv.exe", "idea64.exe",
        "pycharm64.exe", "webstorm64.exe", "Antigravity.exe",
        "wezterm-gui.exe", "alacritty.exe", "mintty.exe"
    ]

    static SHELL_EXCLUDED_APPS := Map(
        "searchhost.exe", 1, "startmenuexperiencehost.exe", 1,
        "shellexperiencehost.exe", 1, "lockapp.exe", 1
    )

    static EnableEngToKor := 1
    static EnableKorToEng := 1
    static EnableAutoKoreanStart := 1
    static ExcludedApps := []
    static ExcludedMap := Map()

    static Load() {
        firstRun := !FileExist(Settings.CONFIG_PATH)
        Settings.EnableEngToKor := Integer(IniRead(Settings.CONFIG_PATH, "General", "EnableEngToKor", "1")) ? 1 : 0
        Settings.EnableKorToEng := Integer(IniRead(Settings.CONFIG_PATH, "General", "EnableKorToEng", "1")) ? 1 : 0
        Settings.EnableAutoKoreanStart := Integer(IniRead(Settings.CONFIG_PATH, "General", "EnableAutoKoreanStart", "1")) ? 1 : 0

        rawList := IniRead(Settings.CONFIG_PATH, "AutoKoreanStart", "ExcludedApps", "__MISSING__")
        if (rawList == "__MISSING__") {
            Settings.SetExcludedList(Settings.DEFAULT_EXCLUDED_APPS)
            if firstRun
                Settings.Save()
        } else {
            items := []
            for _, item in StrSplit(rawList, ",") {
                clean := Trim(item)
                if (clean != "")
                    items.Push(clean)
            }
            Settings.SetExcludedList(items)
        }
    }

    static SetExcludedList(arr) {
        dedup := Map()
        list := []
        for _, item in arr {
            clean := Trim(item)
            if (clean == "")
                continue
            lower := StrLower(clean)
            if !dedup.Has(lower) {
                dedup[lower] := clean
                list.Push(clean)
            }
        }
        Settings.ExcludedApps := list
        Settings.ExcludedMap := dedup
    }

    static IsExcludedExe(exeName) {
        lower := StrLower(Trim(exeName))
        return Settings.SHELL_EXCLUDED_APPS.Has(lower) || Settings.ExcludedMap.Has(lower)
    }

    static Save() {
        try {
            if !DirExist(Settings.CONFIG_DIR)
                DirCreate(Settings.CONFIG_DIR)
            IniWrite(Settings.EnableEngToKor, Settings.CONFIG_PATH, "General", "EnableEngToKor")
            IniWrite(Settings.EnableKorToEng, Settings.CONFIG_PATH, "General", "EnableKorToEng")
            IniWrite(Settings.EnableAutoKoreanStart, Settings.CONFIG_PATH, "General", "EnableAutoKoreanStart")

            joined := ""
            for i, app in Settings.ExcludedApps
                joined .= (i > 1 ? "," : "") . app
            IniWrite(joined, Settings.CONFIG_PATH, "AutoKoreanStart", "ExcludedApps")
        } catch as e {
            MsgBox("설정을 저장하는 중 오류가 발생했습니다:`n" e.Message, Settings.APP_NAME, "Iconx")
        }
    }

    static IsStartupEnabled() {
        return FileExist(Settings.STARTUP_LNK) ? true : false
    }

    static SetStartupEnabled(enable) {
        try {
            if enable {
                if A_IsCompiled
                    FileCreateShortcut(A_ScriptFullPath, Settings.STARTUP_LNK, A_ScriptDir, "", Settings.APP_NAME)
                else
                    FileCreateShortcut(A_AhkPath, Settings.STARTUP_LNK, A_ScriptDir, '"' A_ScriptFullPath '"', Settings.APP_NAME)
            } else {
                if FileExist(Settings.STARTUP_LNK)
                    FileDelete(Settings.STARTUP_LNK)
            }
            return true
        } catch as e {
            MsgBox("시작프로그램 설정 중 오류가 발생했습니다:`n" e.Message, Settings.APP_NAME, "Iconx")
            return false
        }
    }
}

class AppState {
    static engBuf := ""
    static korTracker := KorImeTracker()
    static bufMode := -1
    static lastHwnd := 0
    static lastTick := 0
    static isConverting := false
    static isPaused := false
    static ih := ""
    static seenHwnds := Map()
    static pendingAutoKorTimer := 0
    static winEventHook := 0
    static winEventCb := 0
    static settingsGui := ""
}

ClearAllBuffers() {
    AppState.engBuf := ""
    AppState.korTracker.Reset()
    AppState.bufMode := -1
}

; --- 트레이 메뉴 설정 ---
SetupTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("설정...", (*) => ShowSettingsGui())
    A_TrayMenu.Default := "설정..."
    A_TrayMenu.Add("업데이트 확인...", (*) => CheckForUpdates())
    A_TrayMenu.Add()
    A_TrayMenu.Add("자동 변환 활성화", TogglePause)
    A_TrayMenu.Add("새 앱 한글 자동 시작", ToggleAutoKoreanTray)
    A_TrayMenu.Add()
    A_TrayMenu.Add("버퍼 초기화", (*) => ClearAllBuffers())
    A_TrayMenu.Add("종료", (*) => ExitApp())
    SyncTrayMenu()
}

SyncTrayMenu() {
    if AppState.isPaused {
        A_TrayMenu.Uncheck("자동 변환 활성화")
        A_IconTip := Settings.APP_NAME " v" Settings.APP_VERSION " (일시정지)"
    } else {
        A_TrayMenu.Check("자동 변환 활성화")
        A_IconTip := Settings.APP_NAME " v" Settings.APP_VERSION " (한/영 키 1회)"
    }

    if Settings.EnableAutoKoreanStart
        A_TrayMenu.Check("새 앱 한글 자동 시작")
    else
        A_TrayMenu.Uncheck("새 앱 한글 자동 시작")
}

TogglePause(*) {
    AppState.isPaused := !AppState.isPaused
    ClearAllBuffers()
    SyncTrayMenu()
}

ToggleAutoKoreanTray(*) {
    Settings.EnableAutoKoreanStart := Settings.EnableAutoKoreanStart ? 0 : 1
    Settings.Save()
    SyncTrayMenu()
}

; --- Windows 10/11 IME 상태 조회 ---
; 반환값: 1 = 한글(가), 0 = 영문(A), -1 = 확인 불가
GetImeContextInfo(&hkl := 0, &imeWnd := 0, &convMode := 0) {
    hkl := 0
    imeWnd := 0
    convMode := 0
    prevDHW := DetectHiddenWindows(true)
    try {
        hWnd := WinExist("A")
        if !hWnd
            return -1

        guiInfo := Buffer(A_PtrSize = 8 ? 72 : 48, 0)
        NumPut("UInt", guiInfo.Size, guiInfo, 0)
        hwndFocus := 0
        hwndActive := 0
        if DllCall("user32\GetGUIThreadInfo", "UInt", 0, "Ptr", guiInfo) {
            hwndActive := NumGet(guiInfo, 8, "Ptr")
            hwndFocus := NumGet(guiInfo, A_PtrSize = 8 ? 16 : 12, "Ptr")
        }

        target := hwndFocus ? hwndFocus : (hwndActive ? hwndActive : hWnd)
        tid := DllCall("user32\GetWindowThreadProcessId", "Ptr", target, "Ptr", 0, "UInt")
        hkl := DllCall("user32\GetKeyboardLayout", "UInt", tid, "Ptr")
        if ((hkl & 0xFFFF) != 0x0412)
            return 0

        imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", target, "Ptr")
        if !imeWnd
            imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "Ptr")
        if !imeWnd
            return -1

        try {
            convMode := SendMessage(0x283, 0x001, 0, , imeWnd, , , , 30)
            return (convMode & 1) ? 1 : 0
        } catch {
            imeWnd := 0
            return -1
        }
    } finally {
        DetectHiddenWindows(prevDHW)
    }
}

GetImeHangulState() {
    return GetImeContextInfo()
}

; --- 새 프로그램 실행 시 한글(가) 자동 전환 (이벤트 기반) ---
SetupWinEventHook() {
    AppState.winEventCb := CallbackCreate(OnForegroundChanged, "", 7)
    AppState.winEventHook := DllCall("user32\SetWinEventHook",
        "UInt", 0x0003, ; EVENT_SYSTEM_FOREGROUND
        "UInt", 0x0003,
        "Ptr", 0,
        "Ptr", AppState.winEventCb,
        "UInt", 0,
        "UInt", 0,
        "UInt", 0x0002, ; WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
        "Ptr")
    OnExit(CleanupHooks)
}

CleanupHooks(*) {
    try {
        if AppState.winEventHook {
            DllCall("user32\UnhookWinEvent", "Ptr", AppState.winEventHook)
            AppState.winEventHook := 0
        }
        if AppState.winEventCb {
            CallbackFree(AppState.winEventCb)
            AppState.winEventCb := 0
        }
    }
}

OnForegroundChanged(hHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    ClearAllBuffers()
    if AppState.pendingAutoKorTimer {
        SetTimer(AppState.pendingAutoKorTimer, 0)
        AppState.pendingAutoKorTimer := 0
    }
    if (!Settings.EnableAutoKoreanStart || AppState.isPaused || AppState.isConverting || !hwnd)
        return
    if AppState.seenHwnds.Has(hwnd)
        return

    timerFn := CheckNewWindowKorean.Bind(hwnd)
    AppState.pendingAutoKorTimer := timerFn
    SetTimer(timerFn, -80)
}

PruneSeenHwnds() {
    if (AppState.seenHwnds.Count <= 200)
        return
    dead := []
    for hwnd, _ in AppState.seenHwnds {
        if !WinExist("ahk_id " hwnd)
            dead.Push(hwnd)
    }
    for _, hwnd in dead
        AppState.seenHwnds.Delete(hwnd)
}

CheckNewWindowKorean(hwnd) {
    AppState.pendingAutoKorTimer := 0
    if (!Settings.EnableAutoKoreanStart || AppState.isPaused || AppState.isConverting)
        return
    if (WinExist("A") != hwnd)
        return
    if AppState.seenHwnds.Has(hwnd)
        return

    try {
        if (WinGetPID(hwnd) == DllCall("kernel32\GetCurrentProcessId", "UInt")) {
            AppState.seenHwnds[hwnd] := true
            return
        }
        cls := WinGetClass(hwnd)
        switch cls {
            case "Shell_TrayWnd", "Progman", "WorkerW", "NotifyIconOverflowWindow",
                 "TopLevelWindowForOverflowXamlIsland", "MultitaskingViewFrame", "TaskListThumbnailWnd":
                return
        }
        exeName := WinGetProcessName(hwnd)
    } catch {
        return
    }

    PruneSeenHwnds()
    AppState.seenHwnds[hwnd] := true

    if Settings.IsExcludedExe(exeName)
        return

    hkl := 0, imeWnd := 0, convMode := 0
    state := GetImeContextInfo(&hkl, &imeWnd, &convMode)
    if (state != 0 || (hkl & 0xFFFF) != 0x0412 || !imeWnd)
        return

    try SendMessage(0x283, 0x002, convMode | 1, , imeWnd, , , , 30)
    Sleep(20)
    if (WinExist("A") != hwnd)
        return

    if (GetImeHangulState() == 0) {
        AppState.isConverting := true
        try {
            if IsObject(AppState.ih)
                AppState.ih.Stop()
            Send("{vk15sc138}")
            Sleep(10)
        } finally {
            AppState.isConverting := false
            if IsObject(AppState.ih)
                AppState.ih.Start()
        }
    }
}

; --- 입력 훅 설정 ---
StartHook() {
    ih := InputHook("V")
    ih.NotifyNonText := true
    ih.OnChar := HandleChar
    ih.OnKeyDown := HandleKeyDown
    ih.Start()
    AppState.ih := ih
}

HandleChar(ih, char) {
    if (AppState.isPaused || AppState.isConverting)
        return

    if (GetKeyState("Ctrl") || GetKeyState("LAlt") || GetKeyState("LWin") || GetKeyState("RWin")) {
        ClearAllBuffers()
        return
    }

    hWnd := WinExist("A")
    if (hWnd != AppState.lastHwnd) {
        ClearAllBuffers()
        AppState.lastHwnd := hWnd
    }

    if (AppState.bufMode != -1 && (A_TickCount - AppState.lastTick > 60000))
        ClearAllBuffers()

    AppState.lastTick := A_TickCount

    mode := GetImeHangulState()
    if (mode == -1) {
        ClearAllBuffers()
        return
    }
    if (AppState.bufMode != mode) {
        ClearAllBuffers()
        AppState.bufMode := mode
    }

    if (mode == 0) {
        if !Settings.EnableEngToKor
            return
        if RegExMatch(char, "^[A-Za-z]$") {
            AppState.engBuf .= char
            if (StrLen(AppState.engBuf) > 100)
                AppState.engBuf := SubStr(AppState.engBuf, -100)
        } else if (char == " ") {
            if (AppState.engBuf == "" || SubStr(AppState.engBuf, -1) == " ") {
                AppState.engBuf := ""
                return
            }
            parts := StrSplit(AppState.engBuf, " ")
            lastTok := parts[parts.Length]
            if IsValidKoreanToken(lastTok)
                AppState.engBuf .= " "
            else
                AppState.engBuf := ""
        } else if InStr(",.?!", char) {
            if (AppState.engBuf != "" && IsValidKoreanSequence(AppState.engBuf))
                AppState.engBuf .= char
            else
                AppState.engBuf := ""
        } else {
            AppState.engBuf := ""
        }
    } else {
        if !Settings.EnableKorToEng
            return
        if (char == " ") {
            rawNow := AppState.korTracker.GetRawText()
            if (rawNow == "" || SubStr(rawNow, -1) == " ") {
                AppState.korTracker.Reset()
                return
            }
            parts := StrSplit(rawNow, " ")
            lastTok := parts[parts.Length]
            if IsMistypedEnglishToken(lastTok)
                AppState.korTracker.FeedChar(" ")
            else
                AppState.korTracker.Reset()
        } else if RegExMatch(char, "^[A-Za-z0-9,\.\?\!\-_/:@']$") {
            AppState.korTracker.FeedChar(char)
            AppState.korTracker.LimitLength(100)
        } else {
            AppState.korTracker.Reset()
        }
    }
}

HandleKeyDown(ih, vk, sc) {
    if (AppState.isPaused || AppState.isConverting)
        return

    ; Shift, CapsLock, 한/영 키 자체는 버퍼를 지우지 않음
    if (vk == 0x10 || vk == 0xA0 || vk == 0xA1 || vk == 0x14 || vk == 0x15)
        return

    if (vk == 0x08) { ; Backspace
        if (AppState.bufMode == 0 && StrLen(AppState.engBuf) > 0)
            AppState.engBuf := SubStr(AppState.engBuf, 1, -1)
        else if (AppState.bufMode == 1)
            AppState.korTracker.Backspace()
        return
    }

    if (GetKeyState("Ctrl") || GetKeyState("LAlt") || GetKeyState("LWin") || GetKeyState("RWin")) {
        ClearAllBuffers()
        return
    }

    ; 이동/확정/삭제 키 입력 시 커서 위치가 달라지므로 버퍼 초기화
    switch vk {
        case 0x09, 0x0D, 0x1B, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x2D, 0x2E:
            ClearAllBuffers()
    }
}

~*LButton::
~*RButton::
~*MButton:: {
    ClearAllBuffers()
}

; --- 한/영 키 1회 입력 시 양방향 자동 변환 ---
~*vk15:: {
    if (AppState.isPaused || AppState.isConverting)
        return

    if (GetKeyState("Ctrl") || GetKeyState("LAlt") || GetKeyState("LWin") || GetKeyState("RWin")) {
        ClearAllBuffers()
        return
    }

    mode := AppState.bufMode
    engRaw := LTrim(AppState.engBuf)
    korRaw := ""
    korScreenLen := 0
    doKor2Eng := false
    if (mode == 1 && Settings.EnableKorToEng)
        doKor2Eng := ShouldConvertKorToEng(AppState.korTracker, &korRaw, &korScreenLen)

    lastHwnd := AppState.lastHwnd
    lastTick := AppState.lastTick
    ClearAllBuffers()

    if (A_TickCount - lastTick > 60000)
        return
    if (WinExist("A") != lastHwnd)
        return

    if (mode == 0 && Settings.EnableEngToKor && engRaw != "") {
        converted := ""
        if !ShouldConvertEngToKor(engRaw, &converted)
            return

        AppState.isConverting := true
        try {
            if IsObject(AppState.ih)
                AppState.ih.Stop()
            Sleep(20)
            Send("{Backspace " StrLen(engRaw) "}")
            Sleep(15)
            SendText(converted)
        } finally {
            AppState.isConverting := false
            if IsObject(AppState.ih)
                AppState.ih.Start()
        }
    } else if (mode == 1 && doKor2Eng) {
        AppState.isConverting := true
        try {
            if IsObject(AppState.ih)
                AppState.ih.Stop()
            Sleep(25)
            Send("{Backspace " korScreenLen "}")
            Sleep(15)
            SendText(korRaw)
        } finally {
            AppState.isConverting := false
            if IsObject(AppState.ih)
                AppState.ih.Start()
        }
    }
}

; --- 설정 GUI ---
GetRunningAppExes() {
    seen := Map()
    list := []
    myPid := DllCall("kernel32\GetCurrentProcessId", "UInt")
    for _, hwnd in WinGetList() {
        try {
            if (WinGetPID(hwnd) == myPid)
                continue
            title := WinGetTitle(hwnd)
            if (title == "")
                continue
            exe := WinGetProcessName(hwnd)
            if (exe == "")
                continue
            lower := StrLower(exe)
            if !seen.Has(lower) {
                seen[lower] := true
                list.Push(exe)
            }
        }
    }
    if (list.Length > 1) {
        joined := ""
        for i, v in list
            joined .= (i > 1 ? "`n" : "") . v
        sorted := Sort(joined)
        list := StrSplit(sorted, "`n")
    }
    return list
}

ShowSettingsGui() {
    if IsObject(AppState.settingsGui) {
        try {
            AppState.settingsGui.Show()
            return
        } catch {
            AppState.settingsGui := ""
        }
    }

    curExcl := []
    for _, item in Settings.ExcludedApps
        curExcl.Push(item)

    g := Gui("-MinimizeBox", Settings.APP_NAME " 설정")
    g.SetFont("s9", "Malgun Gothic")
    AppState.settingsGui := g

    cbEng2Kor := g.AddCheckbox("x16 y14 Checked" Settings.EnableEngToKor, "영문 오타 → 한글 변환 (한/영 키 1회)")
    cbKor2Eng := g.AddCheckbox("x16 y+8 Checked" Settings.EnableKorToEng, "한글 오타 → 영문 변환 (한/영 키 1회)")
    cbAutoKor := g.AddCheckbox("x16 y+8 Checked" Settings.EnableAutoKoreanStart, "새 프로그램 실행 시 한글(가)로 자동 시작")
    cbStartup := g.AddCheckbox("x16 y+8 Checked" (Settings.IsStartupEnabled() ? 1 : 0), "Windows 시작 시 자동 실행")

    g.AddGroupBox("x14 y+14 w426 h266 Section", "한글 자동 시작 예외 앱 (터미널 · 코드 에디터 등)")
    lbExcl := g.AddListBox("xs+12 ys+24 w280 h148 Sort")
    btnRemove := g.AddButton("x+10 ys+24 w110 h28", "선택 삭제")
    btnReset := g.AddButton("xp y+8 w110 h28", "기본값 복원")

    edtApp := g.AddEdit("xs+12 ys+182 w192 h24")
    try SendMessage(0x1501, 1, StrPtr("예: Code.exe"), edtApp.Hwnd)
    btnAddApp := g.AddButton("x+8 yp-1 w80 h26", "추가")
    btnBrowse := g.AddButton("x+10 yp w110 h26", "찾아보기...")

    ddlRunning := g.AddDropDownList("xs+12 ys+218 w192")
    btnAddRunning := g.AddButton("x+8 yp-1 w80 h26", "선택 추가")
    btnRefresh := g.AddButton("x+10 yp w110 h26", "목록 새로고침")

    btnUpdate := g.AddButton("x14 ys+280 w115 h28", "업데이트 확인")
    g.AddText("x+10 yp+6 w90", "v" Settings.APP_VERSION)
    btnSave := g.AddButton("x268 yp-6 w82 h28 Default", "저장")
    btnCancel := g.AddButton("x+8 yp w82 h28", "닫기")

    RefreshExclList() {
        lbExcl.Delete()
        if (curExcl.Length > 0)
            lbExcl.Add(curExcl)
    }

    AddExeItem(exeRaw) {
        clean := Trim(exeRaw)
        if (clean == "")
            return
        if !RegExMatch(clean, "i)\.exe$")
            clean .= ".exe"
        lower := StrLower(clean)
        for _, existing in curExcl {
            if (StrLower(existing) == lower) {
                edtApp.Value := ""
                return
            }
        }
        curExcl.Push(clean)
        RefreshExclList()
        edtApp.Value := ""
    }

    RefreshRunningApps(*) {
        running := GetRunningAppExes()
        ddlRunning.Delete()
        if (running.Length > 0) {
            ddlRunning.Add(running)
            ddlRunning.Choose(1)
        }
    }

    OnBrowseClick(*) {
        selected := FileSelect(3, , "예외 앱 선택", "실행 파일 (*.exe)")
        if (selected != "") {
            SplitPath(selected, &fileName)
            AddExeItem(fileName)
        }
    }

    OnAddRunningClick(*) {
        if (ddlRunning.Text != "")
            AddExeItem(ddlRunning.Text)
    }

    OnRemoveClick(*) {
        idx := lbExcl.Value
        if (idx > 0) {
            selText := lbExcl.Text
            for i, item in curExcl {
                if (item == selText) {
                    curExcl.RemoveAt(i)
                    break
                }
            }
            RefreshExclList()
        }
    }

    OnResetClick(*) {
        curExcl := []
        for _, item in Settings.DEFAULT_EXCLUDED_APPS
            curExcl.Push(item)
        RefreshExclList()
    }

    OnSaveClick(*) {
        Settings.EnableEngToKor := cbEng2Kor.Value ? 1 : 0
        Settings.EnableKorToEng := cbKor2Eng.Value ? 1 : 0
        Settings.EnableAutoKoreanStart := cbAutoKor.Value ? 1 : 0
        Settings.SetExcludedList(curExcl)
        Settings.Save()
        Settings.SetStartupEnabled(cbStartup.Value ? true : false)
        SyncTrayMenu()
        AppState.settingsGui := ""
        g.Destroy()
    }

    CloseGui(*) {
        AppState.settingsGui := ""
        g.Destroy()
    }

    btnAddApp.OnEvent("Click", (*) => AddExeItem(edtApp.Value))
    btnBrowse.OnEvent("Click", OnBrowseClick)
    btnAddRunning.OnEvent("Click", OnAddRunningClick)
    btnRefresh.OnEvent("Click", RefreshRunningApps)
    btnRemove.OnEvent("Click", OnRemoveClick)
    btnReset.OnEvent("Click", OnResetClick)
    btnUpdate.OnEvent("Click", (*) => CheckForUpdates())
    btnSave.OnEvent("Click", OnSaveClick)
    btnCancel.OnEvent("Click", CloseGui)
    g.OnEvent("Close", CloseGui)
    g.OnEvent("Escape", CloseGui)

    RefreshExclList()
    RefreshRunningApps()
    g.Show("w454")
}

; --- GitHub 릴리스 업데이트 확인 ---
CheckForUpdates() {
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.SetTimeouts(5000, 5000, 5000, 5000)
        url := "https://api.github.com/repos/" Settings.GITHUB_REPO "/releases/latest"
        req.Open("GET", url, false)
        req.SetRequestHeader("User-Agent", "HanEngAutoConverter/" Settings.APP_VERSION)
        req.SetRequestHeader("Accept", "application/vnd.github+json")
        req.Send()

        if (req.Status == 404) {
            MsgBox("아직 GitHub에 게시된 릴리스가 없습니다.", Settings.APP_NAME, "Iconi")
            return
        }
        if (req.Status != 200) {
            MsgBox("업데이트 확인에 실패했습니다. (HTTP " req.Status ")", Settings.APP_NAME, "Icon!")
            return
        }

        body := req.ResponseText
        if !RegExMatch(body, '\x22tag_name\x22\s*:\s*\x22([^\x22]+)\x22', &mTag) {
            MsgBox("릴리스 버전 정보를 파싱할 수 없습니다.", Settings.APP_NAME, "Icon!")
            return
        }

        latestTag := mTag[1]
        releaseUrl := "https://github.com/" Settings.GITHUB_REPO "/releases/tag/" latestTag

        if (CompareSemVer(latestTag, Settings.APP_VERSION) > 0) {
            res := MsgBox(
                "새 버전이 있습니다!`n`n현재 버전: v" Settings.APP_VERSION "`n최신 버전: " latestTag "`n`n다운로드 페이지를 열까요?",
                Settings.APP_NAME " 업데이트",
                "YesNo Iconi"
            )
            if (res == "Yes")
                Run(releaseUrl)
        } else {
            MsgBox("현재 최신 버전(v" Settings.APP_VERSION ")을 사용 중입니다.", Settings.APP_NAME " 업데이트", "Iconi")
        }
    } catch as e {
        MsgBox("업데이트를 확인하는 중 오류가 발생했습니다:`n" e.Message, Settings.APP_NAME, "Icon!")
    }
}

; --- 초기화 ---
Settings.Load()
SetupTrayMenu()
SetupWinEventHook()
StartHook()

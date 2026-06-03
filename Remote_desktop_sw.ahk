#Requires AutoHotkey v2.0

; 编译时嵌入 VirtualDesktop.exe，运行时释放到临时目录
VD_EXE := A_Temp "\RemoteDesktopSW_VirtualDesktop.exe"
FileInstall("VirtualDesktop.exe", VD_EXE, true)
INI_PATH := A_ScriptDir "\settings.ini"

; 读取热键配置（默认 Ctrl+Alt+Left/Right）
global hkLeft := IniRead(INI_PATH, "Hotkeys", "Left", "^!Left")
global hkRight := IniRead(INI_PATH, "Hotkeys", "Right", "^!Right")
global settingsGui := "", hkLeftEdit := "", hkRightEdit := ""

; 读取截图功能开关（默认开启）
global screenshotEnabled := IniRead(INI_PATH, "Screenshot", "Enabled", "1") = "1"

; 清理默认托盘菜单，只保留自定义项和"退出"
for item in ["&Open", "&Help", "Window Spy", "&Reload", "&Edit", "&Suspend Hotkeys", "&Pause Script"]
    try A_TrayMenu.Delete(item)
try A_TrayMenu.Rename("E&xit", "退出")

; 托盘菜单：设置快捷键
A_TrayMenu.Insert("1&", "设置快捷键", OpenSettingsGui)
A_TrayMenu.Insert("2&")

; 托盘菜单：开机自启动开关
A_TrayMenu.Insert("3&", "开机自启动", ToggleAutoStart)
try {
    RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "RemoteDesktopSW")
    A_TrayMenu.Check("开机自启动")
} catch {
    A_TrayMenu.Uncheck("开机自启动")
}

; 托盘菜单：官方网站
A_TrayMenu.Insert("4&", "官方网站", (*) => Run("https://www.jiandankuai.com/software/6.html"))

; 托盘菜单：截图转地址开关
A_TrayMenu.Insert("5&", "截图转地址", ToggleScreenshot)
if screenshotEnabled
    A_TrayMenu.Check("截图转地址")
else
    A_TrayMenu.Uncheck("截图转地址")

; 注册热键
RegisterHotkeys()
SetTimer(waitforrdp, -250)

; ========== 核心逻辑 ==========

RegisterHotkeys() {
    Hotkey(hkLeft, (*) => SwitchDesktop("Left"))
    Hotkey(hkRight, (*) => SwitchDesktop("Right"))
}

SwitchDesktop(direction) {
    info := GetDesktopInfo()
    if direction = "Left" {
        if info.current = 1 {
            ShowDesktopToast("已经是第一个桌面了！")
            return
        }
        Run(VD_EXE ' /Left',, "Hide")
    } else {
        if info.current = info.total {
            ShowDesktopToast("已经是最后一个桌面了！")
            return
        }
        Run(VD_EXE ' /Right',, "Hide")
    }
    Sleep(300)
    ShowDesktopToast()
}

; ========== Toast 提示 ==========

ShowDesktopToast(displayText := "") {
    static toastGui := ""
    static toastText := ""

    if !displayText {
        info := GetDesktopInfo()
        displayText := info.current ? ("桌面 " info.current " / " info.total) : "切换成功"
    }

    if !IsObject(toastGui) {
        toastGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        toastGui.BackColor := 0x1A1A1A
        toastGui.MarginX := 24
        toastGui.MarginY := 12
        toastGui.SetFont("cFFFFFF s16", "Microsoft YaHei UI")
        toastText := toastGui.Add("Text", "w200 Center", "")
    }

    toastText.Value := displayText
    toastGui.Show("NA AutoSize")
    toastGui.GetPos(,, &w, &h)
    toastGui.Show("NA x" (A_ScreenWidth - w) // 2 " y" A_ScreenHeight - h - 100)
    WinSetTransparent(210, toastGui.Hwnd)
    SetTimer(() => toastGui.Hide(), -3000)
}

; ========== 桌面信息 ==========

GetDesktopInfo() {
    try {
        allIds := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops", "VirtualDesktopIDs")
        currentId := ""
        loop Reg "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo", "K" {
            try {
                currentId := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\" A_LoopRegName "\VirtualDesktops", "CurrentVirtualDesktop")
                break
            } catch {
                continue
            }
        }
        if !currentId
            return {current: 0, total: 0}
    } catch {
        return {current: 0, total: 0}
    }
    total := StrLen(allIds) // 32
    current := 0
    Loop total {
        if (SubStr(allIds, (A_Index - 1) * 32 + 1, 32) = currentId) {
            current := A_Index
            break
        }
    }
    return {current: current, total: total}
}

; ========== 设置 GUI ==========

OpenSettingsGui(*) {
    global settingsGui, hkLeftEdit, hkRightEdit

    if IsObject(settingsGui) {
        settingsGui.Show()
        return
    }

    settingsGui := Gui("+Owner", "快捷键设置")
    settingsGui.SetFont("s10", "Microsoft YaHei UI")
    settingsGui.MarginX := 20
    settingsGui.MarginY := 16

    settingsGui.Add("Text",, "向左切换桌面：")
    hkLeftEdit := settingsGui.Add("Hotkey", "w200 hp", hkLeft)

    settingsGui.Add("Text", "xs", "向右切换桌面：")
    hkRightEdit := settingsGui.Add("Hotkey", "w200 hp", hkRight)

    settingsGui.Add("Button", "xs w90", "恢复默认").OnEvent("Click", RestoreDefaults)
    settingsGui.Add("Button", "x+10 w90 Default", "保存").OnEvent("Click", SaveHotkeys)

    settingsGui.Show("AutoSize")
}

RestoreDefaults(*) {
    hkLeftEdit.Value := "^!Left"
    hkRightEdit.Value := "^!Right"
}

SaveHotkeys(*) {
    global hkLeft, hkRight
    newLeft := hkLeftEdit.Value
    newRight := hkRightEdit.Value

    if !newLeft || !newRight {
        MsgBox("快捷键不能为空！", "错误", "Icon!")
        return
    }
    if newLeft = newRight {
        MsgBox("左右快捷键不能相同！", "错误", "Icon!")
        return
    }

    ; 反注册旧热键
    try Hotkey(hkLeft, "Off")
    try Hotkey(hkRight, "Off")

    ; 更新并保存
    hkLeft := newLeft
    hkRight := newRight
    IniWrite(hkLeft, INI_PATH, "Hotkeys", "Left")
    IniWrite(hkRight, INI_PATH, "Hotkeys", "Right")

    ; 注册新热键
    RegisterHotkeys()

    ShowDesktopToast("快捷键已保存，立即生效")
    settingsGui := ""  ; 关闭窗口后允许重新创建
}

; ========== 开机自启动 ==========

ToggleAutoStart(*) {
    try {
        RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "RemoteDesktopSW")
        RegDelete("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "RemoteDesktopSW")
        A_TrayMenu.Uncheck("开机自启动")
    } catch {
        RegWrite(A_ScriptFullPath, "REG_SZ", "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "RemoteDesktopSW")
        A_TrayMenu.Check("开机自启动")
    }
}

; ========== RDP 窗口监控 ==========

waitforrdp() {
    if WinActive("ahk_class TscShellContainerClass") {
        WinWaitNotActive("ahk_class TscShellContainerClass",, 3600)
    }
    WinWaitActive("ahk_class TscShellContainerClass",, 3600)
    Reload
}

; ========== 截图转地址开关 ==========

ToggleScreenshot(*) {
    global screenshotEnabled
    screenshotEnabled := !screenshotEnabled
    IniWrite(screenshotEnabled ? "1" : "0", INI_PATH, "Screenshot", "Enabled")
    if screenshotEnabled
        A_TrayMenu.Check("截图转地址")
    else
        A_TrayMenu.Uncheck("截图转地址")
}

; ========== 截图粘贴（仅终端环境） ==========

; 图片会存在 "图片/Claude_Screenshots" 文件夹下
global ScreenshotDir := StrReplace(A_MyDocuments, "Documents", "Pictures") "\Claude_Screenshots"

#HotIf screenshotEnabled and (WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_exe powershell.exe") or WinActive("ahk_exe cmd.exe"))
$^v:: {
    if DllCall("IsClipboardFormatAvailable", "uint", 2) {
        if !DirExist(ScreenshotDir)
            DirCreate(ScreenshotDir)

        FileName := ScreenshotDir "\" FormatTime(A_Now, "yyyyMMdd-HHmmss") ".png"

        psScript := "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::GetImage().Save('" FileName "', [System.Drawing.Imaging.ImageFormat]::Png)"
        try {
            RunWait("powershell -NoProfile -Command `"" psScript "`"",, "Hide")
            A_Clipboard := "@" FileName
            Sleep(50)
            Send("^v")
        }
    } else {
        SendInput("^v")
    }
}
#HotIf

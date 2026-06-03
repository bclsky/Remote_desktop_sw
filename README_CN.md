# Remote Desktop SW - Windows 虚拟桌面切换工具

一款专为 AI 编程工作流打造的轻量级 Windows 系统托盘工具。支持多台 Windows 电脑同时开工，通过快捷键一键切换远程桌面；内置截图转文件地址功能，可快速向 CLI 类 IDE（如 Claude Code、Cursor Terminal）粘贴截图反馈问题。

[English](README.md)

## 下载

⬇️ [下载 v1.0.0](https://github.com/bclsky/Remote_desktop_sw/releases/tag/v1.0.0)

## 功能特性

- **快捷键切换虚拟桌面** — 默认 `Ctrl+Alt+←` / `Ctrl+Alt+→` 切换左右桌面，可自定义
- **Toast 提示** — 切换桌面时在屏幕底部显示当前桌面编号（如"桌面 2 / 3"）
- **RDP 自动重载** — 检测远程桌面窗口的激活/失活状态，自动重载脚本以保持热键生效
- **开机自启动** — 通过注册表控制，无需额外配置
- **截图转地址** — 在终端（Windows Terminal / PowerShell / CMD）中粘贴截图时，自动保存为 PNG 文件并转为文件路径
- **系统托盘菜单** — 所有功能均可通过右键托盘图标操作

## 系统要求

- Windows 10 / Windows 11
- 无需安装 AutoHotkey，直接运行 `Remote_desktop_sw.exe` 即可

## 使用方法

1. 运行 `Remote_desktop_sw.exe`
2. 程序启动后静默驻留在系统托盘
3. 使用 `Ctrl+Alt+←` / `Ctrl+Alt+→` 切换虚拟桌面
4. 右键托盘图标可打开设置、开关功能或退出

## 托盘菜单

| 菜单项 | 说明 |
|--------|------|
| 设置快捷键 | 打开快捷键设置窗口，自定义左右切换的热键 |
| 开机自启动 | 开关开机自动启动（通过注册表实现） |
| 官方网站 | 在浏览器中打开官方网站 |
| 截图转地址 | 开关截图粘贴转文件路径功能 |
| 退出 | 退出程序 |

## 配置文件

运行后会在同目录下生成 `settings.ini`：

```ini
[Hotkeys]
Left=^!Left      ; 向左切换桌面（Ctrl+Alt+Left）
Right=^!Right    ; 向右切换桌面（Ctrl+Alt+Right）

[Screenshot]
Enabled=1         ; 截图转地址功能开关（1=开启，0=关闭）
```

## 热键格式参考

AutoHotkey v2 热键表示法：

| 符号 | 按键 |
|------|------|
| `^` | Ctrl |
| `!` | Alt |
| `+` | Shift |
| `#` | Win |

## 项目结构

```
Remote_desktop_sw_Win10/
├── Remote_desktop_sw.exe   # 编译后的可执行文件
├── Remote_desktop_sw.ahk   # AutoHotkey v2 源代码
├── VirtualDesktop.exe      # 虚拟桌面切换辅助程序（可替换，见下方说明）
├── favicon.ico             # 托盘图标
└── settings.ini            # 用户配置（运行后自动生成）
```

## 替换 VirtualDesktop.exe

自带的 `VirtualDesktop.exe` 与系统版本相关。如需兼容其他 Windows 版本（如 Windows 11、Windows Server），可从 [VirtualDesktop](https://github.com/MScholtes/VirtualDesktop) 项目下载最新版本，替换本目录中的文件即可。

## 许可证

[MIT 许可证](LICENSE)

## 链接

- **官方网站：** [https://www.jiandankuai.com/software/6.html](https://www.jiandankuai.com/software/6.html)

## 参考链接

- [VirtualDesktop](https://github.com/MScholtes/VirtualDesktop) — 虚拟桌面管理命令行工具，本项目使用其实现桌面切换
- [AutoHotkey](https://www.autohotkey.com/) — Windows 自动化脚本语言，本项目的开发基础

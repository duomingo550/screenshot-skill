---
name: screenshot
description: 在 Windows 上截取屏幕画面并保存为图片文件。当用户要求"截屏/截图/截个图/捕获屏幕/拍屏/保存当前屏幕/截一张图/录屏前先截图"，或需要把当前桌面、窗口、某个区域画面存成 PNG/JPG 时使用。支持主屏幕、多显示器整屏、指定区域三种模式。不依赖系统安装的第三方 Python 包（Pillow 已内置在 vendor/ 中）。
---

# Screenshot

## Overview

用一条命令把 Windows 屏幕截图存成 PNG/JPEG，输出机器可读的 JSON 结果（路径、宽高、字节数）。基于内置的 Pillow `ImageGrab`，无需额外安装依赖。

## 快速开始

脚本路径（下文记为 `<script>`）：

```
<script_dir> = <本技能目录>/scripts/screenshot.py
```

直接用 `python` 调用即可。

### 1. 截主屏幕（最常用）

```bash
python "<script>"
```

不带参数时自动保存到 `<本技能目录>/screenshots/screenshot_YYYYMMDD_HHMMSS.png`，并在 stdout 打印 JSON：

```json
{"path":"C:\\...\\screenshot_20260914_150416.png","width":1920,"height":1080,"bytes":304199}
```

### 2. 截到指定路径

```bash
python "<script>" --out "C:\shots\home.png"
python "<script>" --out "C:\shots\home.jpg" --quality 85
```

后缀为 `.jpg/.jpeg` 时按 JPEG 保存（`--quality` 默认 90），其他后缀按 PNG 保存。

### 3. 截指定区域

以屏幕左上角为原点（0,0），单位像素：

```bash
python "<script>" --x 100 --y 100 --width 800 --height 600 --out "C:\region.png"
```

四个参数必须同时给齐；缺一则回退为整屏模式。

### 4. 截所有显示器（拼接虚拟屏）

```bash
python "<script>" --all-screens --out "C:\all_monitors.png"
```

## 参数一览

| 参数 | 说明 | 默认 |
|---|---|---|
| `--out` | 输出文件路径（.png/.jpg/.jpeg） | `screenshots/screenshot_<时间戳>.png` |
| `--x --y --width --height` | 区域左上角与宽高（像素） | 不设置=整屏 |
| `--all-screens` | 截取所有显示器组成的虚拟屏 | 关 |
| `--quality` | JPEG 质量 1–100 | 90 |

## 工作流提示

- 拿到 stdout 的 JSON 后，用其中的 `path` 作为图片产物路径，再通过 `present_files` 交付给用户；或用 `Read` 工具打开该路径查看截图内容。
- 截图是即时操作，捕获的是**调用那一刻**的屏幕；若要截某个应用窗口，先让该窗口处于前台/可见状态再调用。
- 区域坐标基于物理屏幕像素（主屏幕左上角为 0,0）。多显示器时若需截副屏区域，先用 `--all-screens` 看整体，或用 `--x/--y` 给出副屏在虚拟屏中的偏移。
- 本技能只负责"截屏存盘"。后续若要标注、OCR、裁剪，再用图片处理类技能或 `Read` 读图。

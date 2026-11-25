# screenshot · 把屏幕变成一张图

一个跑在 Windows 上的 Agent Skill：一条命令把当前屏幕存成 PNG 或 JPEG，同时在 stdout 返回机器可读的 JSON（路径、宽高、字节数）。

给智能体用，不是给人用——让它在你电脑上干活时，随时能把屏幕当成一张可以读、可以传的图。

```
python scripts/screenshot.py --out "C:\shots\home.png"
# {"path": "C:\\shots\\home.png", "width": 1920, "height": 1080, "bytes": 404609}
```

## 安装

**方式一：克隆进技能目录**（推荐）

```bash
git clone https://github.com/duomingo550/screenshot-skill.git "<技能目录>/screenshot"
```

**方式二：下载 Release**

从 [Releases](https://github.com/duomingo550/screenshot-skill/releases) 下载 `screenshot-v1.0.0.zip`，解压后把里面的 `screenshot/` 整个放进技能目录。

> 技能目录：豆包是 `.user_skills`；Claude Code、Codex、Cursor 等换成各自的 skills 目录。**必须整个文件夹一起放**，`scripts/` 与 `vendor/` 缺一不可。

## 环境要求

- Windows（依赖 `PIL.ImageGrab`）
- Python 3.x
- **不需要 pip install**：Pillow 已内置在 `vendor/`

## 用法

```bash
# 1. 整屏（默认存到 ./screenshots/ 带时间戳）
python scripts/screenshot.py

# 2. 指定路径与格式
python scripts/screenshot.py --out "C:\shots\home.png"
python scripts/screenshot.py --out "C:\shots\home.jpg" --quality 85

# 3. 区域（物理像素，左上角为 0,0）
python scripts/screenshot.py --x 440 --y 430 --width 1040 --height 400 --out "C:\shots\region.png"

# 4. 多显示器拼接
python scripts/screenshot.py --all-screens --out "C:\shots\all.png"
```

| 参数 | 说明 | 默认 |
|---|---|---|
| `--out` | 输出路径，按后缀决定 PNG/JPEG | `screenshots/screenshot_<时间戳>.png` |
| `--x --y --width --height` | 区域左上角与宽高 | 不给 = 整屏 |
| `--all-screens` | 拼接所有显示器 | 关 |
| `--quality` | JPEG 质量 1–100 | 90 |

## 自检

双击 `自检.ps1`（或 `powershell -File 自检.ps1`）：跑 4 个用例，给出 PASS/FAIL，只在临时目录写文件。

## 能解决什么

报错留证、页面验收、录屏前定格、把「我屏幕上这个」变成能发给别人的文件。

不适合：录制视频、OCR 与标注后处理、macOS/Linux、锁屏或断开的远程会话。

## 迁移到别的智能体

它只依赖 Python 与 Pillow，不调用任何宿主专有接口。Claude Code / Codex 换脚本路径即可；Cursor 与自研 Agent 让工具层执行命令并读 stdout；Dify / Coze 这类编排平台包成「代码执行」节点。

## 完整说明书

- [`docs/使用说明.html`](docs/使用说明.html)（浏览器打开，含排版版）
- [`docs/使用说明.pdf`](docs/使用说明.pdf)
- [`TESTING.md`](TESTING.md)：测试用例与结果

## 关于

作者：明叔 · [lark123.com](https://lark123.com)
自制技能，MIT 许可，可自用、可修改、可再分发，保留版权声明即可。

Pillow 遵循其自身 BSD 许可，授权文件在 `vendor/PIL`。
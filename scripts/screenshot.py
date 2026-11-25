#!/usr/bin/env python3
"""Take a screenshot on Windows and save it as PNG/JPEG.

Usage:
    python screenshot.py
    python screenshot.py --out "C:\\shot.png"
    python screenshot.py --x 100 --y 100 --width 800 --height 600
    python screenshot.py --all-screens --out "C:\\all.jpg" --quality 85
"""
import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

# Make the bundled Pillow (vendored) importable
_VENDOR = Path(__file__).resolve().parent.parent / "vendor"
if _VENDOR.is_dir() and str(_VENDOR) not in sys.path:
    sys.path.insert(0, str(_VENDOR))

from PIL import ImageGrab  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description="Windows screenshot tool")
    p.add_argument("--out", default="", help="Output file path (.png or .jpg/.jpeg)")
    p.add_argument("--x", type=int, default=-1, help="Region left")
    p.add_argument("--y", type=int, default=-1, help="Region top")
    p.add_argument("--width", type=int, default=-1, help="Region width")
    p.add_argument("--height", type=int, default=-1, help="Region height")
    p.add_argument("--all-screens", action="store_true",
                   help="Capture all monitors (virtual screen)")
    p.add_argument("--quality", type=int, default=90, help="JPEG quality 1-100")
    args = p.parse_args()

    region = (args.x >= 0 and args.y >= 0 and args.width > 0 and args.height > 0)
    if region:
        bbox = (args.x, args.y, args.x + args.width, args.y + args.height)
        img = ImageGrab.grab(bbox=bbox, all_screens=True)
    else:
        img = ImageGrab.grab(all_screens=args.all_screens)

    # Resolve output path
    if not args.out:
        out_dir = Path(__file__).resolve().parent.parent / "screenshots"
        out_dir.mkdir(parents=True, exist_ok=True)
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        out_path = out_dir / f"screenshot_{stamp}.png"
    else:
        out_path = Path(args.out).expanduser().resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)

    ext = out_path.suffix.lower()
    if ext in (".jpg", ".jpeg"):
        img.save(out_path, format="JPEG", quality=args.quality)
    elif ext == ".png":
        img.save(out_path, format="PNG")
    else:
        out_path = out_path.with_suffix(".png")
        img.save(out_path, format="PNG")

    result = {
        "path": str(out_path),
        "width": img.width,
        "height": img.height,
        "bytes": out_path.stat().st_size,
    }
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

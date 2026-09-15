#!/usr/bin/env python3
"""Renders the launcher icon, the adaptive icon and the splash from one grid.

  python3 tools/build_launcher_icons.py

The manifest referenced @mipmap/ic_launcher while android/app/src/main/res held
nothing but values/styles.xml, so the resource did not exist at all.

Lúa is drawn once, in assets/brand/lua_head.txt, as the character grid ported
from the earlier project in the house. Every output here is rendered from it, so
the icon, the adaptive icon and the splash cannot drift apart, and a change to
the mascot shows up as a readable diff instead of an opaque PNG.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:  # pragma: no cover - the message is the whole point
    print("ERROR: Pillow is required: pip install Pillow", file=sys.stderr)
    raise SystemExit(1)

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / "assets" / "brand"
RES = ROOT / "android" / "app" / "src" / "main" / "res"

# The sober maritime blue the app already uses for its primary colour.
# Turquesa de marca, el mismo `primary` del tema (lib/core/theme/app_theme.dart).
# Era el azul Vigo #1B4965: sobre él la gata quedaba apagada, y ese fondo ya no
# existe en ninguna pantalla de la app.
BACKGROUND = "#00C4BE"

# Android launcher densities, in pixels.
LAUNCHER_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# An adaptive icon is 108dp and only the middle 72dp is guaranteed visible, so
# the mascot is drawn inside that safe zone.
ADAPTIVE_SIZES = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}
ADAPTIVE_SAFE_FRACTION = 72 / 108


def load_grid(name: str) -> list[str]:
    lines = [
        line.rstrip("\n")
        for line in (BRAND / name).read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]
    if not lines:
        raise SystemExit(f"ERROR: {name} has no grid rows")
    width = len(lines[0])
    if any(len(line) != width for line in lines):
        raise SystemExit(f"ERROR: {name} is not rectangular")
    return lines


def render(grid: list[str], palette: dict[str, str], cell: int) -> Image.Image:
    height, width = len(grid), len(grid[0])
    image = Image.new("RGBA", (width * cell, height * cell), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    for y, row in enumerate(grid):
        for x, char in enumerate(row):
            colour = palette.get(char)
            if colour is None:
                continue  # '.' and anything unmapped stays transparent
            draw.rectangle(
                [x * cell, y * cell, (x + 1) * cell - 1, (y + 1) * cell - 1],
                fill=colour,
            )
    return image


def fit(sprite: Image.Image, box: int) -> Image.Image:
    """Scales the sprite to fit inside `box` without softening the hard edges.

    Nearest-neighbour with an integer factor keeps every pixel square. The
    factor is computed from the unscaled grid, so the sprite never ends up
    larger than the canvas and the ear tips are not cropped off the top.
    """
    scale = max(1, min(box // sprite.width, box // sprite.height))
    return sprite.resize(
        (sprite.width * scale, sprite.height * scale),
        Image.NEAREST,
    )


def centred(sprite: Image.Image, size: int, background: str | None) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), background or (0, 0, 0, 0))
    canvas.alpha_composite(
        sprite,
        ((size - sprite.width) // 2, (size - sprite.height) // 2),
    )
    return canvas


def main() -> int:
    palette = json.loads((BRAND / "palette.json").read_text(encoding="utf-8"))
    head = load_grid("lua_head.txt")

    written: list[str] = []

    for folder, size in LAUNCHER_SIZES.items():
        target_dir = RES / folder
        target_dir.mkdir(parents=True, exist_ok=True)

        sprite = fit(render(head, palette, cell=1), int(size * 0.82))
        icon = centred(sprite, size, BACKGROUND)
        icon.save(target_dir / "ic_launcher.png")
        written.append(f"{folder}/ic_launcher.png")

        adaptive = ADAPTIVE_SIZES[folder]
        foreground = centred(
            fit(render(head, palette, cell=1), int(adaptive * ADAPTIVE_SAFE_FRACTION * 0.86)),
            adaptive,
            None,
        )
        foreground.save(target_dir / "ic_launcher_foreground.png")
        written.append(f"{folder}/ic_launcher_foreground.png")

    # Adaptive icon descriptor plus the flat background colour it sits on.
    (RES / "mipmap-anydpi-v26").mkdir(parents=True, exist_ok=True)
    (RES / "mipmap-anydpi-v26" / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n',
        encoding="utf-8",
    )
    written.append("mipmap-anydpi-v26/ic_launcher.xml")

    (RES / "values").mkdir(parents=True, exist_ok=True)
    (RES / "values" / "colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">{BACKGROUND}</color>\n'
        f'    <color name="splash_background">{BACKGROUND}</color>\n'
        "</resources>\n",
        encoding="utf-8",
    )
    written.append("values/colors.xml")

    # Splash: the same grid, on the same ground, so the launch screen and the
    # icon are recognisably one mascot.
    for folder, size in LAUNCHER_SIZES.items():
        target_dir = RES / ("drawable" if folder == "mipmap-mdpi" else f"drawable-{folder.split('-')[1]}")
        target_dir.mkdir(parents=True, exist_ok=True)
        sprite = fit(render(head, palette, cell=1), size * 2)
        centred(sprite, size * 3, None).save(target_dir / "splash_lua.png")
        written.append(f"{target_dir.name}/splash_lua.png")

    (RES / "drawable").mkdir(parents=True, exist_ok=True)
    (RES / "drawable" / "launch_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <item android:drawable="@color/splash_background" />\n'
        "    <item>\n"
        '        <bitmap android:gravity="center" android:src="@drawable/splash_lua" />\n'
        "    </item>\n"
        "</layer-list>\n",
        encoding="utf-8",
    )
    written.append("drawable/launch_background.xml")

    print(f"OK: {len(written)} resources rendered from assets/brand/lua_head.txt")
    for name in written:
        print(f"  {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

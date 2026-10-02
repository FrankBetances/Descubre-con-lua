#!/usr/bin/env python3
"""Generates the official Google Play Feature Graphic (Gráfico de funciones)

  python3 tools/build_feature_graphic.py

Requirements by Google Play Console:
- Dimensions: exactly 1024 x 500 px
- Format: PNG 24-bit (no alpha) and high-quality JPEG
- Max size: 15 MB
- Brand: 'Descubre con Lúa · Edición Vigo'
- Generates both language variants (Galego and Castellano) and the default.
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / "assets" / "brand"
FONTS = ROOT / "assets" / "fonts"
DOCS = ROOT / "docs"

WIDTH = 1024
HEIGHT = 500

# Color Tokens
COLOR_DARK_TEAL = (10, 42, 46)        # Profundidad atlántica (#0A2A2E)
COLOR_MID_TEAL = (0, 115, 112)        # Transición rica (#007370)
COLOR_PRIMARY = (0, 196, 190)         # Turquesa de marca (#00C4BE)
COLOR_PRIMARY_INK = (18, 122, 117)    # Turquesa oscuro (#127A75)
COLOR_WHITE = (255, 255, 255)
COLOR_GOLD = (250, 204, 21)           # #FACC15 estrella / premios
COLOR_TEXT_TITLE = (255, 255, 255)
COLOR_TEXT_SUB = (235, 252, 251)      # #EBFBFB
COLOR_TEXT_MUTED = (195, 238, 236)


def load_grid(file_path: Path) -> list[str]:
    lines = [
        line.rstrip("\n")
        for line in file_path.read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]
    return lines


def render_sprite(grid: list[str], palette: dict[str, str], cell: int) -> Image.Image:
    height, width = len(grid), len(grid[0])
    image = Image.new("RGBA", (width * cell, height * cell), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    for y, row in enumerate(grid):
        for x, char in enumerate(row):
            colour = palette.get(char)
            if colour is None:
                continue
            draw.rectangle(
                [x * cell, y * cell, (x + 1) * cell - 1, (y + 1) * cell - 1],
                fill=colour,
            )
    return image


def draw_linear_gradient(
    width: int,
    height: int,
    c1: tuple[int, int, int],
    c2: tuple[int, int, int],
    c3: tuple[int, int, int],
) -> Image.Image:
    """Creates a smooth linear horizontal gradient with full alpha."""
    img = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    for x in range(width):
        factor = x / (width - 1)
        if factor < 0.45:
            sub_f = factor / 0.45
            r = int(c1[0] + (c2[0] - c1[0]) * sub_f)
            g = int(c1[1] + (c2[1] - c1[1]) * sub_f)
            b = int(c1[2] + (c2[2] - c1[2]) * sub_f)
        else:
            sub_f = (factor - 0.45) / 0.55
            r = int(c2[0] + (c3[0] - c2[0]) * sub_f)
            g = int(c2[1] + (c3[1] - c2[1]) * sub_f)
            b = int(c2[2] + (c3[2] - c2[2]) * sub_f)
        draw.line([(x, 0), (x, height)], fill=(r, g, b, 255))

    return img


def draw_star(
    draw: ImageDraw.ImageDraw,
    cx: float,
    cy: float,
    r_outer: float,
    r_inner: float,
    fill_color: tuple[int, int, int, int],
    points: int = 5,
) -> None:
    coords = []
    angle_offset = -math.pi / 2
    for i in range(points * 2):
        r = r_outer if i % 2 == 0 else r_inner
        angle = angle_offset + i * math.pi / points
        coords.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(coords, fill=fill_color)


def draw_shield_icon(
    draw: ImageDraw.ImageDraw,
    x: float,
    y: float,
    size: float,
    fill_color: tuple[int, int, int, int],
) -> None:
    w = size
    h = size * 1.15
    pts = [
        (x, y),
        (x + w, y),
        (x + w, y + h * 0.55),
        (x + w * 0.5, y + h),
        (x, y + h * 0.55),
    ]
    draw.polygon(pts, fill=fill_color)


def draw_leaf_icon(
    draw: ImageDraw.ImageDraw,
    x: float,
    y: float,
    size: float,
    fill_color: tuple[int, int, int, int],
) -> None:
    box = [x, y, x + size, y + size]
    draw.pieslice(box, start=0, end=90, fill=fill_color)
    draw.pieslice(box, start=180, end=270, fill=fill_color)


def draw_rounded_card_with_shadow(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    radius: int,
    fill_color: tuple[int, int, int, int],
    border_color: tuple[int, int, int, int] | None = None,
    border_width: int = 2,
    shadow_offset: tuple[int, int] = (0, 12),
    shadow_blur: int = 24,
    shadow_color: tuple[int, int, int, int] = (0, 20, 25, 95),
) -> None:
    x0, y0, x1, y1 = box
    w = x1 - x0
    h = y1 - y0

    shadow_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_layer)
    sx0 = x0 + shadow_offset[0]
    sy0 = y0 + shadow_offset[1]
    s_draw.rounded_rectangle(
        [sx0, sy0, sx0 + w, sy0 + h],
        radius=radius,
        fill=shadow_color,
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(shadow_blur))
    canvas.alpha_composite(shadow_layer)

    card_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    card_draw = ImageDraw.Draw(card_layer)
    card_draw.rounded_rectangle(
        [x0, y0, x1, y1],
        radius=radius,
        fill=fill_color,
        outline=border_color,
        width=border_width,
    )
    canvas.alpha_composite(card_layer)


def build_feature_graphic(lang: str = "gl") -> Image.Image:
    palette = json.loads((BRAND / "palette.json").read_text(encoding="utf-8"))
    sit_grid = load_grid(BRAND / "lua_sit.txt")

    is_gl = lang == "gl"

    # Copy texts according to language
    top_badge_text = "0-6 ANOS · EDUCACIÓN INFANTIL" if is_gl else "0-6 AÑOS · EDUCACIÓN INFANTIL"
    title_text = "Descubre con Lúa"
    sub_text = "Edición Vigo"
    tagline_text = "Asemblea na escola · Rutinas no fogar" if is_gl else "La asamblea en la escuela · Rutinas en el hogar"
    desc_text = (
        "Guía pedagóxica e auditiva para as aulas e as familias"
        if is_gl
        else "Guía pedagógica y auditiva para las aulas y las familias"
    )
    chip_offline = "100% Sen conexión · Cero datos" if is_gl else "100% Sin conexión · Cero datos"
    chip_screens = "Sen pantallas infantís" if is_gl else "Sin pantallas infantiles"
    chip_langs = "Galego e Castelán" if is_gl else "Gallego y Castellano"
    chip_english = "Inmersión auditiva en inglés"

    # 1. Base Gradient Canvas
    canvas = draw_linear_gradient(
        WIDTH,
        HEIGHT,
        c1=COLOR_DARK_TEAL,
        c2=COLOR_MID_TEAL,
        c3=COLOR_PRIMARY,
    )

    # 2. Waves and Ambient Aura Layer
    overlay_layer = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay_layer)

    center_lua = (800, 250)

    # Soft glowing radial burst behind Lúa
    glow_layer = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    gx, gy = center_lua
    glow_radius = 210
    glow_draw.ellipse(
        [gx - glow_radius, gy - glow_radius, gx + glow_radius, gy + glow_radius],
        fill=(220, 252, 250, 75),
    )
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(45))
    canvas.alpha_composite(glow_layer)

    # Concentric wave ripples (audio pulse 72 BPM & Atlantic waves)
    for r, alpha in [(190, 38), (245, 30), (305, 22), (370, 14), (440, 8)]:
        overlay_draw.ellipse(
            [gx - r, gy - r, gx + r, gy + r],
            outline=(255, 255, 255, alpha),
            width=2,
        )

    # Subtle decorative stars in background
    star_positions = [
        (600, 75, 7, 3, 110),
        (560, 420, 6, 2.5, 90),
        (970, 90, 8, 3.5, 130),
        (975, 410, 6, 2.5, 100),
    ]
    for sx, sy, r_out, r_in, alpha in star_positions:
        draw_star(overlay_draw, sx, sy, r_out, r_in, fill_color=(250, 204, 21, alpha))

    canvas.alpha_composite(overlay_layer)

    # 3. Lúa Card Stage
    card_w = 336
    card_h = 396
    card_x0 = center_lua[0] - card_w // 2
    card_y0 = center_lua[1] - card_h // 2
    card_x1 = card_x0 + card_w
    card_y1 = card_y0 + card_h

    draw_rounded_card_with_shadow(
        canvas,
        box=(card_x0, card_y0, card_x1, card_y1),
        radius=36,
        fill_color=(255, 255, 255, 252),
        border_color=(190, 240, 238, 255),
        border_width=3,
        shadow_offset=(0, 14),
        shadow_blur=28,
        shadow_color=(3, 25, 28, 120),
    )

    # Render Lúa sitting sprite at integer cell size 8 (256 x 304 px)
    lua_sprite = render_sprite(sit_grid, palette, cell=8)
    sprite_x = card_x0 + (card_w - lua_sprite.width) // 2
    sprite_y = card_y0 + (card_h - lua_sprite.height) // 2 + 8
    canvas.alpha_composite(lua_sprite, (sprite_x, sprite_y))

    # Floating Star Badge on top-right of Lúa Card
    badge_layer = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(badge_layer)
    badge_x = card_x1 - 92
    badge_y = card_y0 + 16
    b_draw.rounded_rectangle(
        [badge_x, badge_y, badge_x + 76, badge_y + 28],
        radius=14,
        fill=(250, 204, 21, 255),
        outline=(255, 255, 255, 240),
        width=2,
    )
    draw_star(b_draw, badge_x + 16, badge_y + 14, r_outer=7, r_inner=3, fill_color=(20, 25, 35, 255))
    font_lua_badge = ImageFont.truetype(str(FONTS / "Nunito-ExtraBold.ttf"), 14)
    b_draw.text((badge_x + 28, badge_y + 4), "LÚA", font=font_lua_badge, fill=(20, 25, 35, 255))
    canvas.alpha_composite(badge_layer)

    # 4. Typography and Badges on Left Side
    text_layer = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    t_draw = ImageDraw.Draw(text_layer)

    font_badge = ImageFont.truetype(str(FONTS / "Nunito-Bold.ttf"), 14)
    font_title = ImageFont.truetype(str(FONTS / "Nunito-ExtraBold.ttf"), 54)
    font_sub = ImageFont.truetype(str(FONTS / "Nunito-Bold.ttf"), 28)
    font_tagline = ImageFont.truetype(str(FONTS / "Nunito-Bold.ttf"), 22)
    font_desc = ImageFont.truetype(str(FONTS / "Nunito-SemiBold.ttf"), 17)
    font_chip = ImageFont.truetype(str(FONTS / "Nunito-Bold.ttf"), 14)

    left_x = 64

    # Top Pill
    t_bbox = font_badge.getbbox(top_badge_text)
    tb_w = (t_bbox[2] - t_bbox[0]) + 28
    tb_h = 32
    t_draw.rounded_rectangle(
        [left_x, 48, left_x + tb_w, 48 + tb_h],
        radius=16,
        fill=(255, 255, 255, 36),
        outline=(255, 255, 255, 95),
        width=1,
    )
    t_draw.text((left_x + 14, 48 + 6), top_badge_text, font=font_badge, fill=COLOR_WHITE)

    # Main Title: "Descubre con Lúa" with clean drop shadow
    t_draw.text((left_x + 2, 98 + 2), title_text, font=font_title, fill=(3, 25, 28, 140))
    t_draw.text((left_x, 98), title_text, font=font_title, fill=COLOR_WHITE)

    # Subtitle: "Edición Vigo" in Golden star color
    t_draw.text((left_x, 168), sub_text, font=font_sub, fill=COLOR_GOLD)

    # Slogan / Value Proposition
    t_draw.text((left_x, 216), tagline_text, font=font_tagline, fill=COLOR_TEXT_SUB)

    # Microcopy / Description
    t_draw.text((left_x, 256), desc_text, font=font_desc, fill=COLOR_TEXT_MUTED)

    # Feature Badges / Chips
    def render_chip(x: int, y: int, label: str, icon_type: str | None = None) -> int:
        bbox = font_chip.getbbox(label)
        tw = bbox[2] - bbox[0]
        icon_space = 22 if icon_type else 0
        pw = tw + 28 + icon_space
        ph = 36
        t_draw.rounded_rectangle(
            [x, y, x + pw, y + ph],
            radius=12,
            fill=(255, 255, 255, 32),
            outline=(255, 255, 255, 75),
            width=1,
        )
        if icon_type == "shield":
            draw_shield_icon(t_draw, x + 12, y + 11, size=12, fill_color=(250, 204, 21, 240))
        elif icon_type == "leaf":
            draw_leaf_icon(t_draw, x + 12, y + 11, size=13, fill_color=(167, 243, 208, 240))
        elif icon_type == "star":
            draw_star(t_draw, x + 18, y + 18, r_outer=6, r_inner=2.5, fill_color=(250, 204, 21, 240))

        text_x = x + 14 + icon_space
        t_draw.text((text_x, y + 8), label, font=font_chip, fill=COLOR_WHITE)
        return pw

    # Row 1 of Chips
    y1 = 330
    w_c1 = render_chip(left_x, y1, chip_offline, icon_type="shield")
    render_chip(left_x + w_c1 + 12, y1, chip_screens, icon_type="leaf")

    # Row 2 of Chips
    y2 = 378
    w_c3 = render_chip(left_x, y2, chip_langs, icon_type="star")
    render_chip(left_x + w_c3 + 12, y2, chip_english, icon_type="star")

    canvas.alpha_composite(text_layer)

    # 5. Flatten to 24-bit RGB (Zero Alpha Channel, strictly compliant with Play Console)
    final_rgb = Image.new("RGB", (WIDTH, HEIGHT), (255, 255, 255))
    final_rgb.paste(canvas, mask=canvas.split()[3])
    return final_rgb


def save_variants(img: Image.Image, base_stem: str) -> None:
    # Validate constraints
    assert img.size == (1024, 500), f"Invalid dimensions: {img.size}"
    assert img.mode == "RGB", f"Must be RGB without alpha: {img.mode}"

    target_files = [
        DOCS / f"{base_stem}.png",
        DOCS / f"{base_stem}.jpg",
        BRAND / f"{base_stem}.png",
        BRAND / f"{base_stem}.jpg",
    ]

    for p in target_files:
        if p.suffix == ".png":
            img.save(p, format="PNG", optimize=True)
        elif p.suffix == ".jpg":
            img.save(p, format="JPEG", quality=95, optimize=True)
        size = p.stat().st_size
        size_mb = size / (1024 * 1024)
        print(f"  Saved: {p} ({size} bytes, {size_mb:.2f} MB)")
        assert size <= 15 * 1024 * 1024, f"File exceeds 15MB: {p}"


def main() -> int:
    DOCS.mkdir(parents=True, exist_ok=True)
    BRAND.mkdir(parents=True, exist_ok=True)

    print("Generating Google Play Feature Graphic (Galego / Default)...")
    img_gl = build_feature_graphic(lang="gl")
    save_variants(img_gl, "feature_graphic")
    save_variants(img_gl, "feature_graphic-gl")

    print("Generating Google Play Feature Graphic (Castellano)...")
    img_es = build_feature_graphic(lang="es")
    save_variants(img_es, "feature_graphic-es")

    print("SUCCESS: All Google Play Feature Graphics (1024x500 RGB) generated and verified!")
    return 0


if __name__ == "__main__":
    sys.exit(main())

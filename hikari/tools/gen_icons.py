#!/usr/bin/env python3
"""Генерирует иконки приложения Hikari (Android, Windows, Web)."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT = Path.home() / ".cache" / "fonts" / "YujiSyuku-Regular.ttf"
VERMILION = (201, 54, 43)
VERMILION_LIGHT = (240, 90, 74)
PAPER = (255, 252, 248)


def squircle_mask(size: int, radius_ratio: float = 0.24) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    r = int(size * radius_ratio)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=255)
    return mask


def gradient_square(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x / size) * 0.55 + (y / size) * 0.45
            px[x, y] = tuple(int(VERMILION[i] + (VERMILION_LIGHT[i] - VERMILION[i]) * t) for i in range(3))
    return img


def glyph_layer(size: int, glyph_ratio: float = 0.62, color=PAPER) -> Image.Image:
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    font_size = int(size * glyph_ratio)
    font = ImageFont.truetype(str(FONT), font_size)
    bbox = font.getbbox("光")
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d = ImageDraw.Draw(layer)
    d.text(((size - tw) / 2 - bbox[0], (size - th) / 2 - bbox[1]), "光", font=font, fill=color + (255,))
    return layer


def icon(size: int) -> Image.Image:
    bg = gradient_square(size).convert("RGBA")
    bg.putalpha(squircle_mask(size))
    glyph = glyph_layer(size)
    bg.alpha_composite(glyph)
    return bg


def save_png(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG", optimize=True)
    print(f"  {path.relative_to(ROOT)}  {img.size[0]}×{img.size[1]}")


def main() -> None:
    # Windows .ico
    ico = icon(256)
    ico_path = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
    ico_path.parent.mkdir(parents=True, exist_ok=True)
    ico.save(ico_path, sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    print(f"  {ico_path.relative_to(ROOT)}")

    # Android legacy + adaptive foreground
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in densities.items():
        save_png(icon(size), ROOT / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher.png")
        fg_size = int(size * 2.25)  # 108dp при соответствующей плотности
        fg = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
        fg.alpha_composite(glyph_layer(fg_size, glyph_ratio=0.44))
        save_png(fg, ROOT / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher_foreground.png")

    # Web
    save_png(icon(512), ROOT / "web" / "icons" / "Icon-512.png")
    save_png(icon(192), ROOT / "web" / "icons" / "Icon-192.png")
    save_png(icon(512), ROOT / "web" / "icons" / "Icon-maskable-512.png")
    save_png(icon(192), ROOT / "web" / "icons" / "Icon-maskable-192.png")
    save_png(icon(64), ROOT / "web" / "favicon.png")


if __name__ == "__main__":
    main()

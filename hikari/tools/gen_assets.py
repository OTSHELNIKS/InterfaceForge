#!/usr/bin/env python3
"""Генератор ассетов Hikari: обои в духе суми-э и текстуры бумаги.

Все изображения рисуются процедурно: бумага васи, тушь, киноварь,
сакура и золото. Никаких внешних изображений.
"""
from __future__ import annotations

import json
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
WALLPAPERS = ROOT / "assets" / "wallpapers"
TEXTURES = ROOT / "assets" / "textures"
FONTS = Path.home() / ".cache" / "fonts"

W_P, H_P = 1080, 1920
W_L, H_L = 1920, 1080

PALETTE = {
    "paper": "#F7F1E8",
    "card": "#FFFCF8",
    "sumi": "#1E1917",
    "vermilion": "#C9362B",
    "vermilion_light": "#F05A4A",
    "sakura": "#EBA6B7",
    "gold": "#C9A227",
    "ink_muted": "#8C7F75",
}


# ---------------------------------------------------------------------------
# Базовые утилиты
# ---------------------------------------------------------------------------

def hexc(value: str) -> tuple[float, float, float]:
    value = value.lstrip("#")
    return tuple(int(value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def rgb8(rgb: tuple[float, float, float]) -> tuple[int, int, int]:
    return tuple(int(max(0, min(1, c)) * 255) for c in rgb)


def mix(a, b, t: float):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def gradient_v(w: int, h: int, stops: list[tuple[float, tuple]]) -> np.ndarray:
    """Вертикальный градиент по стопам (позиция 0..1, цвет)."""
    ys = np.linspace(0, 1, h, dtype=np.float32)
    out = np.zeros((h, w, 3), dtype=np.float32)
    for c in range(3):
        vals = np.interp(ys, [s[0] for s in stops], [s[1][c] for s in stops])
        out[:, :, c] = vals[:, None]
    return out


def gradient_diag(w: int, h: int, stops: list[tuple[float, tuple]], angle: float = 45) -> np.ndarray:
    """Градиент по диагонали (угол в градусах)."""
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    rad = math.radians(angle)
    proj = xx * math.cos(rad) / w + yy * math.sin(rad) / h
    proj = (proj - proj.min()) / (proj.max() - proj.min() + 1e-6)
    out = np.zeros((h, w, 3), dtype=np.float32)
    for c in range(3):
        out[:, :, c] = np.interp(proj, [s[0] for s in stops], [s[1][c] for s in stops])
    return out


def radial_field(w: int, h: int, cx: float, cy: float, radius: float, soft: float = 0.08) -> np.ndarray:
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.sqrt((xx - cx * w) ** 2 + (yy - cy * h) ** 2) / max(1.0, radius)
    return np.clip((1.0 + soft - d) / soft, 0.0, 1.0)


def blend(base: np.ndarray, color, alpha: np.ndarray) -> np.ndarray:
    if isinstance(color, tuple):
        layer = np.array(color, dtype=np.float32)
    else:
        layer = color
    a = alpha[..., None]
    return base * (1.0 - a) + layer * a


def fbm(w: int, h: int, rng: np.random.Generator, octaves: int = 4, base: int = 3) -> np.ndarray:
    total = np.zeros((h, w), dtype=np.float32)
    norm = 0.0
    amp = 1.0
    for o in range(octaves):
        scale = max(2, base * (2 ** o))
        gh, gw = max(2, h // scale), max(2, w // scale)
        grid = rng.random((gh, gw)).astype(np.float32)
        img = Image.fromarray((grid * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
        total += np.asarray(img, dtype=np.float32) / 255.0 * amp
        norm += amp
        amp *= 0.5
    return total / norm


def paper_grain(w: int, h: int, rng: np.random.Generator, strength: float = 0.05) -> np.ndarray:
    n = fbm(w, h, rng, octaves=5, base=2)
    n = (n - n.mean()) / (n.std() + 1e-6)
    return (n * strength)[..., None]


def fiber_mask(w: int, h: int, rng: random.Random, scale: int = 2) -> np.ndarray:
    W, H = w * scale, h * scale
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    for _ in range(int(260 * (w / 1080) * (h / 1920))):
        x = rng.uniform(-50, W + 50)
        y = rng.uniform(-50, H + 50)
        length = rng.uniform(30, 260) * scale
        angle = rng.uniform(-0.35, 0.35)
        x2 = x + math.cos(angle) * length
        y2 = y + math.sin(angle) * length
        d.line([(x, y), (x2, y2)], fill=rng.randint(40, 130), width=max(1, int(scale * rng.uniform(0.5, 1.4))))
    img = img.resize((w, h), Image.LANCZOS)
    img = img.filter(ImageFilter.GaussianBlur(0.6))
    return np.asarray(img, dtype=np.float32) / 255.0


def apply_paper(rgb: np.ndarray, rng: np.random.Generator, strength: float = 0.055, fibers: float = 0.35) -> np.ndarray:
    h, w = rgb.shape[:2]
    n = paper_grain(w, h, rng, 1.0)
    # Мультипликативное зерно: на тёмном не превращается в «асфальт».
    rgb = rgb * (1.0 + n * strength)
    f = fiber_mask(w, h, random.Random(int(rng.integers(0, 1_000_000))), scale=2)
    rgb = rgb * (1.0 - f[..., None] * 0.05 * fibers) + f[..., None] * 0.015
    return np.clip(rgb, 0, 1)


def vignette(rgb: np.ndarray, strength: float = 0.35, power: float = 2.2) -> np.ndarray:
    h, w = rgb.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    nx = (xx / w - 0.5) * 2
    ny = (yy / h - 0.5) * 2
    d = np.sqrt(nx ** 2 + ny ** 2) / math.sqrt(2)
    v = np.clip((d - 0.45) / 0.55, 0, 1) ** power * strength
    return rgb * (1.0 - v[..., None])


def film_grain(rgb: np.ndarray, rng: np.random.Generator, amount: float = 0.012) -> np.ndarray:
    noise = rng.normal(0, amount, rgb.shape[:2]).astype(np.float32)
    luma = (rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114)
    noise = noise * (0.25 + 0.75 * luma)
    return np.clip(rgb + noise[..., None], 0, 1)


def grade(rgb: np.ndarray, lift: float = 0.0, contrast: float = 1.0, gamma: float = 1.0) -> np.ndarray:
    x = np.clip(rgb, 0, 1)
    x = x ** gamma
    x = (x - 0.5) * contrast + 0.5 + lift
    return np.clip(x, 0, 1)


def save(rgb: np.ndarray, path: Path, quality: int = 92) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    arr = (np.clip(rgb, 0, 1) * 255).astype(np.uint8)
    Image.fromarray(arr, "RGB").save(path, "JPEG", quality=quality, optimize=True, progressive=True)


def mask_draw(w: int, h: int, painter, scale: float = 2.0, blur: float = 0.0) -> np.ndarray:
    """Рисует в высоком разрешении и возвращает мягкую маску 0..1."""
    W, H = max(2, int(w * scale)), max(2, int(h * scale))
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    painter(d, scale)
    img = img.resize((w, h), Image.LANCZOS)
    if blur > 0:
        img = img.filter(ImageFilter.GaussianBlur(blur))
    return np.asarray(img, dtype=np.float32) / 255.0


def brush_mask(w: int, h: int, points: list[tuple[float, float]], width: float, rng: random.Random,
               scale: float = 2.0, dry: float = 0.35, taper: tuple[float, float] = (1.0, 0.25)) -> np.ndarray:
    """Кистевой мазок: цепочка кругов + «сухая» фактура."""
    W, H = int(w * scale), int(h * scale)
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    pts = [(x * scale, y * scale) for x, y in points]
    # Сэмплируем ломаную с плавным шагом.
    dense: list[tuple[float, float]] = []
    for i in range(len(pts) - 1):
        x1, y1 = pts[i]
        x2, y2 = pts[i + 1]
        seg = math.hypot(x2 - x1, y2 - y1)
        steps = max(1, int(seg / (2.5 * scale)))
        for s in range(steps):
            t = s / steps
            dense.append((x1 + (x2 - x1) * t, y1 + (y2 - y1) * t))
    dense.append(pts[-1])
    total = max(1, len(dense) - 1)
    base_w = width * scale
    for i, (x, y) in enumerate(dense):
        t = i / total
        rad = base_w * (taper[0] + (taper[1] - taper[0]) * t) / 2
        rad *= 1.0 + 0.12 * math.sin(i * 0.7) + 0.06 * math.sin(i * 0.23 + 1.7)
        rad = max(0.6, rad)
        jitter = rad * 0.18
        d.ellipse([x - rad + rng.uniform(-jitter, jitter), y - rad + rng.uniform(-jitter, jitter),
                   x + rad + rng.uniform(-jitter, jitter), y + rad + rng.uniform(-jitter, jitter)],
                  fill=255)
    img = img.resize((w, h), Image.LANCZOS)
    arr = np.asarray(img, dtype=np.float32) / 255.0
    if dry > 0:
        n = fbm(w, h, np.random.default_rng(rng.randint(0, 1_000_000)), octaves=3, base=9)
        # Мягкая «сухая кисть»: не рвём штрих, а модулируем плотность.
        arr = arr * (1.0 - dry * 0.55 * np.clip((0.52 - n) / 0.52, 0, 1))
        arr = arr * (0.82 + 0.28 * n)
        arr = np.asarray(Image.fromarray((np.clip(arr, 0, 1) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.6)),
                         dtype=np.float32) / 255.0
    return arr


def bezier(p0, p1, p2, p3, n=40):
    pts = []
    for i in range(n):
        t = i / (n - 1)
        mt = 1 - t
        x = mt ** 3 * p0[0] + 3 * mt ** 2 * t * p1[0] + 3 * mt * t ** 2 * p2[0] + t ** 3 * p3[0]
        y = mt ** 3 * p0[1] + 3 * mt ** 2 * t * p1[1] + 3 * mt * t ** 2 * p2[1] + t ** 3 * p3[1]
        pts.append((x, y))
    return pts


def draw_blossom(img: Image.Image, cx: float, cy: float, r: float, color: tuple,
                 rng: random.Random, alpha: int = 230, petals: int = 5):
    """Цветок сакуры: пять мягких лепестков-эллипсов на RGBA-слое."""
    size = int(r * 3.2) + 6
    for i in range(petals):
        a = i * 2 * math.pi / petals + rng.uniform(-0.07, 0.07)
        petal = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        pd = ImageDraw.Draw(petal)
        shade = rng.uniform(0.88, 1.06)
        c = tuple(int(max(0, min(255, ch * shade))) for ch in color)
        pd.ellipse(
            [size / 2 - r * 0.46, size / 2 - r * 1.30, size / 2 + r * 0.46, size / 2 + r * 0.10],
            fill=c + (alpha,),
        )
        petal = petal.rotate(-math.degrees(a), resample=Image.BICUBIC, center=(size / 2, size / 2))
        img.alpha_composite(petal, (int(cx - size / 2), int(cy - size / 2)))
    # Сердцевина и тычинки
    cr = r * 0.17
    d = ImageDraw.Draw(img)
    d.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=(250, 220, 175, 240))
    for i in range(7):
        a = i * 2 * math.pi / 7 + rng.uniform(-0.2, 0.2)
        d.line([(cx, cy), (cx + math.cos(a) * r * 0.42, cy + math.sin(a) * r * 0.42)],
               fill=(201, 162, 39, 150), width=max(1, int(r * 0.05)))


def blossom_layer(w: int, h: int, blossoms: list[tuple[float, float, float, int]],
                  color: tuple, rng: random.Random, scale: float = 2.0) -> np.ndarray:
    W, H = int(w * scale), int(h * scale)
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for (x, y, r, alpha) in blossoms:
        draw_blossom(img, x * w * scale, y * h * scale, r * scale, color, rng, alpha)
    img = img.resize((w, h), Image.LANCZOS)
    return np.asarray(img, dtype=np.float32) / 255.0


def add_layer(rgb: np.ndarray, rgba: np.ndarray) -> np.ndarray:
    a = rgba[..., 3:4]
    return rgb * (1 - a) + rgba[..., :3] * a


def sun_disc(w: int, h: int, cx: float, cy: float, radius: float,
             core: tuple, mid: tuple, edge: tuple, soft: float = 0.05) -> np.ndarray:
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.sqrt((xx - cx * w) ** 2 + (yy - cy * h) ** 2) / max(1.0, radius)
    inside = np.clip((1.0 + soft - d) / soft, 0, 1)
    t = np.clip(d, 0, 1)
    col = np.zeros((h, w, 3), dtype=np.float32)
    for c in range(3):
        col[..., c] = np.where(t < 0.55, core[c] + (mid[c] - core[c]) * (t / 0.55),
                               mid[c] + (edge[c] - mid[c]) * ((t - 0.55) / 0.45))
    return col, inside


def add_sun(rgb: np.ndarray, cx: float, cy: float, radius: float, core: tuple, mid: tuple, edge: tuple,
            soft: float = 0.05) -> np.ndarray:
    h, w = rgb.shape[:2]
    col, a = sun_disc(w, h, cx, cy, radius, core, mid, edge, soft)
    return blend(rgb, col, a)


def add_glow(rgb: np.ndarray, cx: float, cy: float, radius: float, color: tuple, strength: float = 0.35) -> np.ndarray:
    h, w = rgb.shape[:2]
    a = radial_field(w, h, cx, cy, radius, 1.4) * strength
    return blend(rgb, color, a)


def gold_leaf(w: int, h: int, rng: random.Random, count: int, scale: float = 2.0) -> np.ndarray:
    W, H = int(w * scale), int(h * scale)
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for _ in range(count):
        cx = rng.uniform(0, W)
        cy = rng.uniform(0, H)
        r = rng.uniform(8, 60) * scale
        pts = []
        n = rng.randint(3, 6)
        for i in range(n):
            a = i * 2 * math.pi / n + rng.uniform(-0.3, 0.3)
            rr = r * rng.uniform(0.5, 1.0)
            pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
        c = rng.choice([(201, 162, 39), (226, 192, 92), (160, 122, 24), (240, 214, 140)])
        d.polygon(pts, fill=c + (rng.randint(120, 220),))
    img = img.resize((w, h), Image.LANCZOS)
    return np.asarray(img, dtype=np.float32) / 255.0


def ink_branch(points: list, width: float, color: tuple, rng: random.Random,
               dry: float = 0.3) -> np.ndarray:
    return brush_mask(1080, 1920, points, width, rng, dry=dry)


def watermark_kanji(rgb: np.ndarray, char: str, size: int, cx: float, cy: float,
                    color: tuple, opacity: float) -> np.ndarray:
    font = ImageFont.truetype(str(FONTS / "YujiSyuku-Regular.ttf"), size)
    bbox = font.getbbox(char)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    layer = Image.new("L", (tw + 40, th + 40), 0)
    d = ImageDraw.Draw(layer)
    d.text((20 - bbox[0], 20 - bbox[1]), char, font=font, fill=255)
    layer = layer.filter(ImageFilter.GaussianBlur(0.4))
    h, w = rgb.shape[:2]
    x = int(cx * w - layer.width / 2)
    y = int(cy * h - layer.height / 2)
    canvas = Image.new("L", (w, h), 0)
    canvas.paste(layer, (max(0, x), max(0, y)))
    a = np.asarray(canvas, dtype=np.float32) / 255.0 * opacity
    return blend(rgb, color, a)


def finish(rgb: np.ndarray, rng: np.random.Generator, paper: float = 0.028,
           grain: float = 0.009, vig: float = 0.28, contrast: float = 1.04) -> np.ndarray:
    rgb = apply_paper(rgb, rng, paper)
    rgb = grade(rgb, contrast=contrast)
    rgb = vignette(rgb, vig)
    rgb = film_grain(rgb, rng, grain)
    return rgb


# ---------------------------------------------------------------------------
# Стили
# ---------------------------------------------------------------------------

def style_sunset_sky(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.00, hexc("#171827")),
        (0.28, hexc("#3B2230")),
        (0.50, hexc("#7E2B2F")),
        (0.66, hexc("#C9362B")),
        (0.78, hexc("#E88A4E")),
        (0.88, hexc("#F3C98A")),
        (1.00, hexc("#2A1A18")),
    ])
    # Полосы облаков
    for i in range(7):
        cy = 0.30 + i * 0.055 + rng.uniform(-0.012, 0.012)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
        band = np.exp(-((yy / h - cy) ** 2) / (2 * (0.012 + 0.006 * rng.random()) ** 2))
        band *= 0.10 + 0.12 * rng.random()
        col = hexc("#F7C9A0") if i % 2 == 0 else hexc("#6E2430")
        rgb = blend(rgb, col, band)
    rgb = add_glow(rgb, 0.62, 0.55, w * 0.55, hexc("#F05A4A"), 0.45)
    rgb = add_sun(rgb, 0.62, 0.55, w * 0.175, hexc("#FFE6B8"), hexc("#F05A4A"), hexc("#C9362B"), 0.035)
    # Дальний берег
    def hills(d, s):
        pts = [(0, h * 0.80 * s)]
        for i in range(0, w + 1, 24):
            y = h * (0.79 + 0.012 * math.sin(i / w * 5.0) + 0.008 * math.sin(i / w * 13.0))
            pts.append((i * s, y * s))
        pts += [(w * s, h * s), (0, h * s)]
        d.polygon(pts, fill=255)
    m = mask_draw(w, h, hills, 2.0, blur=1.6)
    rgb = blend(rgb, hexc("#231619"), m * 0.92)
    # Блики на воде
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    for i in range(26):
        cy = rng.uniform(0.82, 0.98)
        band = np.exp(-((yy / h - cy) ** 2) / (2 * 0.0018 ** 2))
        band *= np.clip(1 - abs(xx / w - 0.62) * 2.4, 0, 1) * rng.uniform(0.05, 0.16)
        rgb = blend(rgb, hexc("#FFD9A0"), band)
    # Птицы
    def birds(d, s):
        for i in range(5):
            bx = (0.30 + i * 0.055) * w * s
            by = (0.30 + (i % 3) * 0.035) * h * s
            r = (8 + i * 2) * s
            d.arc([bx - r, by - r * 0.7, bx, by + r * 0.3], 200, 340, fill=255, width=int(2 * s))
            d.arc([bx, by - r * 0.7, bx + r, by + r * 0.3], 200, 340, fill=255, width=int(2 * s))
    bm = mask_draw(w, h, birds, 2.0, blur=0.5)
    rgb = blend(rgb, hexc("#1A1214"), bm * 0.7)
    return finish(rgb, rng, vig=0.4)


def style_akane_abstract(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_diag(w, h, [
        (0.0, hexc("#1A100E")),
        (0.45, hexc("#3A1714")),
        (0.75, hexc("#8E2420")),
        (1.0, hexc("#C9362B")),
    ], angle=35)
    rgb = add_glow(rgb, 0.70, 0.30, w * 0.55, hexc("#F05A4A"), 0.35)
    # Большая дуга
    def arc(d, s):
        d.arc([-w * 0.25 * s, h * 0.18 * s, w * 1.25 * s, h * 1.45 * s], 195, 350, fill=255, width=int(w * 0.035 * s))
    m = mask_draw(w, h, arc, 2.0, blur=1.2)
    rgb = blend(rgb, hexc("#F05A4A"), m * 0.55)
    # Горизонтальная кисть
    pts = bezier((0, h * 0.70), (w * 0.35, h * 0.68), (w * 0.7, h * 0.73), (w, h * 0.70), 60)
    bm = brush_mask(w, h, pts, w * 0.028, random.Random(7), dry=0.55, taper=(0.2, 1.0))
    rgb = blend(rgb, hexc("#1A1214"), bm * 0.9)
    # Золотая линия
    def gold_line(d, s):
        d.line([(w * 0.08 * s, h * 0.745 * s), (w * 0.92 * s, h * 0.742 * s)], fill=255, width=int(2.2 * s))
    gm = mask_draw(w, h, gold_line, 2.0, blur=0.4)
    rgb = blend(rgb, hexc("#C9A227"), gm * 0.8)
    rgb = add_sun(rgb, 0.74, 0.28, w * 0.105, hexc("#FFD9A0"), hexc("#F05A4A"), hexc("#C9362B"), 0.05)
    rgb = watermark_kanji(rgb, "光", int(w * 0.42), 0.82, 0.88, hexc("#F7F1E8"), 0.05)
    return finish(rgb, rng, vig=0.42, contrast=1.06)


def style_gold_leaf(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#2B1A12")),
        (0.45, hexc("#5A2418")),
        (0.75, hexc("#A0311F")),
        (1.0, hexc("#2A1712")),
    ])
    rgb = add_glow(rgb, 0.5, 0.42, w * 0.5, hexc("#C9A227"), 0.18)
    # Золотое кольцо
    def ring(d, s):
        cx, cy, r = 0.5 * w * s, 0.40 * h * s, 0.20 * w * s
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=255, width=int(w * 0.008 * s))
    rm = mask_draw(w, h, ring, 2.0, blur=1.2)
    rgb = blend(rgb, hexc("#C9A227"), rm * 0.9)
    rgb = add_sun(rgb, 0.5, 0.40, w * 0.165, hexc("#FFE6A8"), hexc("#F05A4A"), hexc("#C9362B"), 0.05)
    gold = gold_leaf(w, h, random.Random(11), 90)
    rgb = add_layer(rgb, gold)
    # Вертикальные штрихи
    for i in range(9):
        x = rng.uniform(0.05, 0.95) * w
        def stroke(d, s, x=x):
            d.line([(x * s, h * 0.55 * s), (x * s, h * 0.98 * s)], fill=255, width=int(rng.uniform(1, 4) * s))
        m = mask_draw(w, h, stroke, 2.0, blur=1.0)
        rgb = blend(rgb, hexc("#F7F1E8"), m * rng.uniform(0.02, 0.07))
    return finish(rgb, rng, vig=0.4)


def style_hinomaru(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = np.ones((h, w, 3), dtype=np.float32) * np.array(hexc("#F3EADB"), dtype=np.float32)
    rgb = apply_paper(rgb, np.random.default_rng(21), 0.05, 1.0)
    # Мягкий тёплый свет
    rgb = add_glow(rgb, 0.5, 0.45, w * 0.6, hexc("#FFF3DC"), 0.5)
    # Красный диск с «кровоточащим» краем
    cx, cy, r = 0.5, 0.42, 0.235
    soft = 0.012
    col, a = sun_disc(w, h, cx, cy, r * w, hexc("#E04A36"), hexc("#C9362B"), hexc("#A82A22"), soft)
    rgb = blend(rgb, col, a * 0.98)
    # Тонкая тень под диском
    sh = np.asarray(Image.fromarray(((a * 255)).astype(np.uint8)).filter(ImageFilter.GaussianBlur(14)), dtype=np.float32) / 255.0
    rgb = blend(rgb, hexc("#C9B79E"), np.clip(sh - a, 0, 1) * 0.18)
    # Золотая линия
    def line(d, s):
        d.line([(w * 0.18 * s, h * 0.80 * s), (w * 0.82 * s, h * 0.80 * s)], fill=255, width=int(1.6 * s))
    lm = mask_draw(w, h, line, 2.0, blur=0.3)
    rgb = blend(rgb, hexc("#C9A227"), lm * 0.65)
    rgb = watermark_kanji(rgb, "光", int(w * 0.18), 0.82, 0.90, hexc("#1E1917"), 0.10)
    return finish(rgb, rng, paper=0.05, grain=0.012, vig=0.16, contrast=1.02)


def style_sakura_night(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#0B1020")),
        (0.35, hexc("#141B2B")),
        (0.70, hexc("#1D2740")),
        (1.0, hexc("#121828")),
    ])
    rgb = add_glow(rgb, 0.72, 0.20, w * 0.5, hexc("#EBA6B7"), 0.20)
    # Луна
    rgb = add_sun(rgb, 0.72, 0.20, w * 0.105, hexc("#FFF6E2"), hexc("#F3E7D2"), hexc("#D8C7AE"), 0.02)
    # Ветка
    rng2 = random.Random(31)
    main = bezier((-0.05 * w, 0.62 * h), (0.22 * w, 0.58 * h), (0.45 * w, 0.42 * h), (0.78 * w, 0.30 * h), 50)
    bm = brush_mask(w, h, main, w * 0.026, rng2, dry=0.45, taper=(1.0, 0.3))
    rgb = blend(rgb, hexc("#0A0C12"), bm * 0.95)
    for i in range(5):
        t = 0.18 + i * 0.14
        idx = min(len(main) - 2, int(t * (len(main) - 1)))
        x0, y0 = main[idx]
        pts = bezier((x0, y0), (x0 + w * 0.04, y0 - h * 0.08), (x0 + w * 0.06, y0 - h * 0.12),
                     (x0 + w * rng2.uniform(0.02, 0.12), y0 - h * rng2.uniform(0.14, 0.24)), 30)
        sm = brush_mask(w, h, pts, w * 0.009, rng2, dry=0.5, taper=(1.0, 0.2))
        rgb = blend(rgb, hexc("#0A0C12"), sm * 0.9)
        # Цветы на концах
        ex, ey = pts[-1]
        blossoms = []
        for j in range(7):
            blossoms.append((ex / w + rng2.uniform(-0.045, 0.045), ey / h + rng2.uniform(-0.035, 0.035),
                             w * rng2.uniform(0.022, 0.038), rng2.randint(215, 255)))
        layer = blossom_layer(w, h, blossoms, (235, 166, 183), rng2)
        rgb = add_layer(rgb, layer)
    # Падающие лепестки
    petals = []
    for i in range(26):
        petals.append((rng2.uniform(0, 1), rng2.uniform(0.2, 1.0), w * rng2.uniform(0.006, 0.012), rng2.randint(90, 200)))
    layer = blossom_layer(w, h, petals, (235, 166, 183), rng2, scale=1.5)
    rgb = add_layer(rgb, layer)
    # Звёзды
    def stars(d, s):
        for i in range(120):
            x, y = rng2.uniform(0, 1) * w * s, rng2.uniform(0, 0.5) * h * s
            r = rng2.uniform(0.4, 1.4) * s
            d.ellipse([x - r, y - r, x + r, y + r], fill=rng2.randint(60, 200))
    sm = mask_draw(w, h, stars, 1.0, blur=0.4)
    rgb = blend(rgb, hexc("#FFF6E2"), sm * 0.5)
    return finish(rgb, rng, vig=0.42)


def style_sakura_light(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#FBF4EC")),
        (0.45, hexc("#F7EDE6")),
        (0.8, hexc("#F6E4E2")),
        (1.0, hexc("#EFD9D6")),
    ])
    rgb = add_glow(rgb, 0.25, 0.2, w * 0.55, hexc("#EBA6B7"), 0.22)
    rgb = add_glow(rgb, 0.8, 0.75, w * 0.6, hexc("#F05A4A"), 0.08)
    rng2 = random.Random(41)
    main = bezier((-0.05 * w, 0.28 * h), (0.25 * w, 0.30 * h), (0.45 * w, 0.22 * h), (0.82 * w, 0.18 * h), 50)
    bm = brush_mask(w, h, main, w * 0.022, rng2, dry=0.5, taper=(1.0, 0.25))
    rgb = blend(rgb, hexc("#4A3A34"), bm * 0.85)
    clusters = []
    for i in range(7):
        t = 0.15 + i * 0.12
        idx = min(len(main) - 2, int(t * (len(main) - 1)))
        x0, y0 = main[idx]
        pts = bezier((x0, y0), (x0 + w * 0.03, y0 - h * 0.05), (x0 + w * 0.05, y0 - h * 0.1),
                     (x0 + w * rng2.uniform(0.0, 0.1), y0 - h * rng2.uniform(0.08, 0.16)), 26)
        sm = brush_mask(w, h, pts, w * 0.007, rng2, dry=0.55, taper=(1.0, 0.2))
        rgb = blend(rgb, hexc("#4A3A34"), sm * 0.75)
        ex, ey = pts[-1]
        clusters.append((ex / w, ey / h, rng2.uniform(0.02, 0.035)))
    blossoms = []
    for (cx, cy, r) in clusters:
        for j in range(7):
            blossoms.append((cx + rng2.uniform(-0.045, 0.045), cy + rng2.uniform(-0.04, 0.04), w * r * rng2.uniform(1.5, 2.2), rng2.randint(205, 245)))
    layer = blossom_layer(w, h, blossoms, (235, 166, 183), rng2)
    rgb = add_layer(rgb, layer)
    # Пыльца золота
    gold = gold_leaf(w, h, rng2, 26)
    rgb = add_layer(rgb, gold * np.array([1, 1, 1, 0.55], dtype=np.float32))
    return finish(rgb, rng, paper=0.05, grain=0.012, vig=0.14, contrast=1.02)


def style_petal_storm(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#1A1116")),
        (0.5, hexc("#2A1B22")),
        (1.0, hexc("#160F13")),
    ])
    rgb = add_glow(rgb, 0.7, 0.35, w * 0.6, hexc("#EBA6B7"), 0.22)
    rgb = add_glow(rgb, 0.2, 0.8, w * 0.5, hexc("#F05A4A"), 0.12)
    rng2 = random.Random(51)
    # Ветер-дуги
    for i in range(7):
        def arc(d, s, i=i):
            r = w * (0.25 + i * 0.12)
            d.arc([w * 0.5 * s - r * s, h * 0.5 * s - r * s, w * 0.5 * s + r * s, h * 0.5 * s + r * s],
                  200, 340, fill=255, width=int(1.2 * s))
        m = mask_draw(w, h, arc, 1.0, blur=2.0)
        rgb = blend(rgb, hexc("#EBA6B7"), m * 0.06)
    # Лепестки
    petals = []
    for i in range(220):
        t = rng2.random()
        x = 0.5 + math.sin(t * math.pi * 2 + rng2.uniform(0, 6)) * (0.15 + 0.35 * t)
        y = 0.5 + math.cos(t * math.pi * 2 + rng2.uniform(0, 6)) * (0.1 + 0.4 * t)
        petals.append((x, y, w * rng2.uniform(0.014, 0.034), rng2.randint(120, 240)))
    layer = blossom_layer(w, h, petals, (235, 166, 183), rng2)
    rgb = add_layer(rgb, layer)
    # Крупный цветок на переднем плане
    big = [(0.18, 0.22, w * 0.10, 235), (0.80, 0.12, w * 0.075, 200), (0.86, 0.82, w * 0.09, 210)]
    layer = blossom_layer(w, h, big, (240, 180, 195), rng2)
    rgb = add_layer(rgb, layer)
    return finish(rgb, rng, vig=0.45)


def style_sakura_uta(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_diag(w, h, [
        (0.0, hexc("#FBF5EC")),
        (0.5, hexc("#F9EDE8")),
        (1.0, hexc("#F2DEDC")),
    ], angle=30)
    rgb = add_glow(rgb, 0.3, 0.3, w * 0.5, hexc("#EBA6B7"), 0.18)
    rgb = add_glow(rgb, 0.85, 0.15, w * 0.35, hexc("#C9A227"), 0.08)
    rng2 = random.Random(61)
    blossoms = []
    for cluster in [(0.18, 0.72), (0.55, 0.62), (0.82, 0.78), (0.68, 0.30), (0.30, 0.22)]:
        for j in range(9):
            blossoms.append((cluster[0] + rng2.uniform(-0.06, 0.06), cluster[1] + rng2.uniform(-0.055, 0.055),
                             w * rng2.uniform(0.030, 0.052), rng2.randint(165, 235)))
    layer = blossom_layer(w, h, blossoms, (235, 166, 183), rng2)
    rgb = add_layer(rgb, layer)
    # Тонкая ветка
    pts = bezier((0.05 * w, 0.85 * h), (0.3 * w, 0.78 * h), (0.55 * w, 0.72 * h), (0.9 * w, 0.66 * h), 40)
    bm = brush_mask(w, h, pts, w * 0.012, rng2, dry=0.6, taper=(1.0, 0.3))
    rgb = blend(rgb, hexc("#5B463C"), bm * 0.7)
    gold = gold_leaf(w, h, rng2, 34)
    rgb = add_layer(rgb, gold * np.array([1, 1, 1, 0.4], dtype=np.float32))
    return finish(rgb, rng, paper=0.05, grain=0.012, vig=0.12, contrast=1.02)


def style_enso(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = np.ones((h, w, 3), dtype=np.float32) * np.array(hexc("#F1E8DA"), dtype=np.float32)
    rgb = apply_paper(rgb, np.random.default_rng(71), 0.06, 1.0)
    rgb = add_glow(rgb, 0.5, 0.45, w * 0.5, hexc("#FFF6E0"), 0.35)
    rng2 = random.Random(72)
    # Энсо — незамкнутый круг
    cx, cy = 0.5, 0.44
    radius = 0.31 * min(w, h)
    pts = []
    start, end = math.radians(-160), math.radians(150)
    for i in range(140):
        t = start + (end - start) * i / 139
        rr = radius * (1 + 0.012 * math.sin(i * 0.3))
        pts.append((cx * w + math.cos(t) * rr, cy * h + math.sin(t) * rr))
    bm = brush_mask(w, h, pts, w * 0.052, rng2, dry=0.18, taper=(0.35, 0.95))
    rgb = blend(rgb, hexc("#1B1715"), bm * 0.94)
    # Брызги
    def splashes(d, s):
        for i in range(90):
            a = rng2.uniform(0, 2 * math.pi)
            rr = radius * rng2.uniform(1.02, 1.25) * s
            x = cx * w * s + math.cos(a) * rr
            y = cy * h * s + math.sin(a) * rr
            r = rng2.uniform(0.6, 3.2) * s
            d.ellipse([x - r, y - r, x + r, y + r], fill=rng2.randint(60, 220))
    sm = mask_draw(w, h, splashes, 1.0, blur=0.8)
    rgb = blend(rgb, hexc("#1B1715"), sm * 0.55)
    # Красная печать
    def seal(d, s):
        x, y = w * 0.78 * s, h * 0.78 * s
        r = w * 0.045 * s
        d.rounded_rectangle([x - r, y - r, x + r, y + r], radius=6 * s, fill=255)
    seal_m = mask_draw(w, h, seal, 2.0, blur=0.6)
    rgb = blend(rgb, hexc("#C9362B"), seal_m * 0.95)
    rgb = watermark_kanji(rgb, "光", int(w * 0.075), 0.78, 0.78, hexc("#F7F1E8"), 0.85)
    return finish(rgb, rng, paper=0.05, grain=0.014, vig=0.2, contrast=1.03)


def style_kintsugi(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = np.ones((h, w, 3), dtype=np.float32) * np.array(hexc("#141110"), dtype=np.float32)
    rgb = apply_paper(rgb, np.random.default_rng(81), 0.10, 0.6)
    # Железная текстура
    n = fbm(w, h, np.random.default_rng(82), octaves=4, base=5)
    rgb = rgb + (n[..., None] - 0.5) * 0.06
    rgb = add_glow(rgb, 0.3, 0.2, w * 0.5, hexc("#C9A227"), 0.07)
    rng2 = random.Random(83)
    def crack(d, s):
        x, y = rng2.uniform(0, 0.15) * w * s, rng2.uniform(0, 0.3) * h * s
        path = [(x, y)]
        for i in range(18):
            x += rng2.uniform(0.03, 0.09) * w * s
            y += rng2.uniform(-0.07, 0.09) * h * s
            path.append((x, y))
        d.line(path, fill=255, width=int(rng2.uniform(2, 5) * s), joint="curve")
        # Ветви
        for i in range(3):
            bx, by = path[rng2.randint(3, len(path) - 2)]
            d.line([(bx, by), (bx + rng2.uniform(-0.08, 0.08) * w * s, by + rng2.uniform(0.05, 0.15) * h * s)],
                   fill=rng2.randint(120, 220), width=int(rng2.uniform(1, 2.5) * s))
    for _ in range(4):
        m = mask_draw(w, h, crack, 2.0, blur=0.5)
        rgb = blend(rgb, hexc("#C9A227"), m * 0.95)
    gold = gold_leaf(w, h, rng2, 45)
    rgb = add_layer(rgb, gold * np.array([1, 1, 1, 0.5], dtype=np.float32))
    return finish(rgb, rng, paper=0.05, grain=0.018, vig=0.45)


def style_ink_gold(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#0F0C0B")),
        (0.5, hexc("#1B1614")),
        (1.0, hexc("#12100E")),
    ])
    rgb = apply_paper(rgb, np.random.default_rng(91), 0.09, 0.8)
    rng2 = random.Random(92)
    for i in range(4):
        x = (0.18 + i * 0.22) * w
        pts = bezier((x, -0.05 * h), (x + 0.02 * w, 0.3 * h), (x - 0.03 * w, 0.6 * h), (x + 0.01 * w, 1.05 * h), 40)
        bm = brush_mask(w, h, pts, w * 0.075, rng2, dry=0.5, taper=(0.6, 1.0))
        rgb = blend(rgb, hexc("#3B322A"), bm * 0.85)
    # Золотая полоса
    def band(d, s):
        d.rectangle([0, 0.52 * h * s, w * s, 0.60 * h * s], fill=255)
    m = mask_draw(w, h, band, 2.0, blur=3.0)
    rgb = blend(rgb, hexc("#C9A227"), m * 0.85)
    rgb = add_sun(rgb, 0.78, 0.30, w * 0.075, hexc("#FFD9A0"), hexc("#F05A4A"), hexc("#C9362B"), 0.04)
    gold = gold_leaf(w, h, rng2, 30)
    rgb = add_layer(rgb, gold * np.array([1, 1, 1, 0.45], dtype=np.float32))
    return finish(rgb, rng, paper=0.06, grain=0.016, vig=0.45)


def style_ink_mountains(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#E9E0D2")),
        (0.55, hexc("#F2EADB")),
        (1.0, hexc("#DCD0BE")),
    ])
    rgb = add_glow(rgb, 0.7, 0.2, w * 0.5, hexc("#FFF8E8"), 0.45)
    rng2 = random.Random(101)
    layers = [
        (0.52, "#C9BCA9", 0.0),
        (0.62, "#A99B88", 0.1),
        (0.73, "#84776A", 0.15),
        (0.84, "#5A4F45", 0.18),
        (0.94, "#2E2823", 0.22),
    ]
    for idx, (base_y, color, wobble) in enumerate(layers):
        def mountain(d, s, base_y=base_y, wobble=wobble, idx=idx):
            pts = [(-0.05 * w * s, h * s)]
            for i in range(0, int(w * 1.1), 16):
                x = i
                y = base_y + wobble * math.sin(i / w * (3.0 + idx) + idx * 2.1) \
                    + 0.035 * math.sin(i / w * (11.0 + idx * 2) + idx)
                pts.append((x * s, y * h * s))
            pts += [(1.1 * w * s, h * s)]
            d.polygon(pts, fill=255)
        m = mask_draw(w, h, mountain, 2.0, blur=1.2 + idx * 0.6)
        rgb = blend(rgb, hexc(color), m * (0.75 + idx * 0.05))
        # Полоса тумана
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
        mist = np.exp(-((yy / h - (base_y - 0.03)) ** 2) / (2 * 0.018 ** 2)) * 0.35
        rgb = blend(rgb, hexc("#F7F1E8"), mist)
    # Красная нить
    def thread(d, s):
        pts = bezier((0.1 * w, 0.62 * h), (0.35 * w, 0.50 * h), (0.65 * w, 0.72 * h), (0.9 * w, 0.55 * h), 60)
        d.line([(x * s, y * s) for x, y in pts], fill=255, width=int(2.0 * s))
    tm = mask_draw(w, h, thread, 2.0, blur=0.3)
    rgb = blend(rgb, hexc("#C9362B"), tm * 0.85)
    # Птицы
    def birds(d, s):
        for i in range(4):
            bx, by = (0.25 + i * 0.06) * w * s, (0.32 + (i % 2) * 0.03) * h * s
            r = 9 * s
            d.arc([bx - r, by - r * 0.6, bx, by + r * 0.3], 200, 340, fill=255, width=int(1.8 * s))
            d.arc([bx, by - r * 0.6, bx + r, by + r * 0.3], 200, 340, fill=255, width=int(1.8 * s))
    bm = mask_draw(w, h, birds, 2.0, blur=0.4)
    rgb = blend(rgb, hexc("#3B332C"), bm * 0.6)
    return finish(rgb, rng, paper=0.055, grain=0.014, vig=0.22, contrast=1.02)


def style_indigo_river(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#0B1424")),
        (0.4, hexc("#16305A")),
        (0.75, hexc("#2E4A73")),
        (1.0, hexc("#0E1A2E")),
    ])
    rgb = add_glow(rgb, 0.2, 0.25, w * 0.55, hexc("#4F7BA8"), 0.25)
    rgb = add_sun(rgb, 0.24, 0.24, w * 0.075, hexc("#FFF4D8"), hexc("#E8D8B8"), hexc("#C9B48E"), 0.03)
    rng2 = random.Random(111)
    # Волны
    for i in range(9):
        y0 = 0.45 + i * 0.055
        def wave(d, s, y0=y0, i=i):
            pts = []
            for k in range(0, int(w * 1.05), 10):
                x = k
                y = y0 * h + math.sin(k / w * (6.0 + i * 0.8) + i) * h * 0.012
                pts.append((x * s, y * s))
            d.line(pts, fill=255, width=int((1.2 + (i % 3) * 0.7) * s))
        m = mask_draw(w, h, wave, 1.0, blur=1.4)
        rgb = blend(rgb, hexc("#8FB6D8"), m * (0.10 + 0.03 * (i % 3)))
    # Блики
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    for i in range(30):
        cy = rng2.uniform(0.5, 0.95)
        band = np.exp(-((yy / h - cy) ** 2) / (2 * 0.003 ** 2))
        band *= np.clip(1 - abs(xx / w - 0.24) * 2.2, 0, 1) * rng2.uniform(0.05, 0.2)
        rgb = blend(rgb, hexc("#DCEAF5"), band)
    # Золотые блики
    gold = gold_leaf(w, h, rng2, 22)
    rgb = add_layer(rgb, gold * np.array([1, 1, 1, 0.35], dtype=np.float32))
    return finish(rgb, rng, paper=0.04, grain=0.015, vig=0.4)


def style_lapis_night(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#070D1A")),
        (0.4, hexc("#0F2242")),
        (0.75, hexc("#1E3A5F")),
        (1.0, hexc("#0A1526")),
    ])
    rgb = add_glow(rgb, 0.5, 0.4, w * 0.6, hexc("#2E4A73"), 0.4)
    rgb = add_glow(rgb, 0.6, 0.55, w * 0.3, hexc("#C9A227"), 0.08)
    rng2 = random.Random(121)
    # Звёзды
    def stars(d, s):
        for i in range(220):
            x, y = rng2.uniform(0, 1) * w * s, rng2.uniform(0, 1) * h * s
            r = rng2.uniform(0.3, 1.3) * s
            d.ellipse([x - r, y - r, x + r, y + r], fill=rng2.randint(60, 230))
    sm = mask_draw(w, h, stars, 1.0, blur=0.3)
    rgb = blend(rgb, hexc("#EAF2FF"), sm * 0.75)
    # Туманность
    neb = fbm(w, h, np.random.default_rng(555), octaves=4, base=6)
    neb = np.clip((neb - 0.48) / 0.52, 0, 1)
    rgb = blend(rgb, hexc("#4F7BA8"), neb * 0.22)
    rgb = blend(rgb, hexc("#C9A227"), np.clip(neb - 0.7, 0, 1) * 0.35)
    # Золотая звезда
    def star(d, s):
        cx, cy, r = 0.62 * w * s, 0.42 * h * s, 0.075 * w * s
        for i in range(4):
            a = i * math.pi / 2
            d.line([(cx, cy), (cx + math.cos(a) * r, cy + math.sin(a) * r)], fill=255, width=int(3 * s))
        d.ellipse([cx - r * 0.18, cy - r * 0.18, cx + r * 0.18, cy + r * 0.18], fill=255)
    stm = mask_draw(w, h, star, 2.0, blur=0.8)
    rgb = blend(rgb, hexc("#F2D48A"), stm * 0.95)
    # Красная звезда
    def redstar(d, s):
        cx, cy, r = 0.28 * w * s, 0.2 * h * s, 0.03 * w * s
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    rm = mask_draw(w, h, redstar, 2.0, blur=1.0)
    rgb = blend(rgb, hexc("#F05A4A"), rm * 0.9)
    return finish(rgb, rng, paper=0.03, grain=0.016, vig=0.45)


def style_seigaiha(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#F7F1E8")),
        (0.4, hexc("#EAF0F5")),
        (1.0, hexc("#DCE7F0")),
    ])
    rgb = add_glow(rgb, 0.7, 0.25, w * 0.5, hexc("#FFFFFF"), 0.35)
    rng2 = random.Random(131)
    # Сэйгайха
    def waves(d, s):
        step = w * 0.16 * s
        row_h = step * 0.5
        for row in range(-2, int(h / (row_h / s)) + 3):
            offset = (row % 2) * step / 2
            y = row * row_h
            for col in range(-2, int(w / step) + 3):
                cx = col * step + offset
                for ring in range(4):
                    r = step * 0.5 - ring * step * 0.105
                    d.arc([cx - r, y - r, cx + r, y + r], 180, 360, fill=255, width=max(1, int(2.0 * s)))
    m = mask_draw(w, h, waves, 2.0, blur=0.6)
    # Градиентная заливка узора
    rgb = blend(rgb, hexc("#1E3A5F"), m * 0.85)
    # Золотые акценты
    def golds(d, s):
        step = w * 0.16 * s
        row_h = step * 0.5
        for row in range(0, int(h / (row_h / s)), 2):
            offset = (row % 2) * step / 2
            y = row * row_h
            for col in range(0, int(w / step), 3):
                cx = col * step + offset
                r = step * 0.5
                d.arc([cx - r, y - r, cx + r, y + r], 180, 360, fill=255, width=int(1.2 * s))
    gm = mask_draw(w, h, golds, 2.0, blur=0.4)
    rgb = blend(rgb, hexc("#C9A227"), gm * 0.65)
    return finish(rgb, rng, paper=0.028, grain=0.006, vig=0.2, contrast=1.03)


def style_asanoha(w: int, h: int, rng: np.random.Generator) -> np.ndarray:
    rgb = gradient_v(w, h, [
        (0.0, hexc("#0C1728")),
        (0.5, hexc("#12233C")),
        (1.0, hexc("#081120")),
    ])
    rgb = add_glow(rgb, 0.3, 0.25, w * 0.5, hexc("#2E4A73"), 0.3)
    rgb = add_glow(rgb, 0.75, 0.15, w * 0.35, hexc("#C9A227"), 0.10)
    rng2 = random.Random(141)
    # Асаноха: сетка из шестиугольников с «лучами»
    def pattern(d, s):
        step = w * 0.165 * s
        h_step = step * math.sqrt(3) / 2
        for row in range(-2, int(h / h_step) + 3):
            for col in range(-2, int(w / step) + 3):
                cx = col * step + (row % 2) * step / 2
                cy = row * h_step
                pts = [(cx + math.cos(a) * step * 0.5, cy + math.sin(a) * step * 0.5)
                       for a in [math.radians(60 * i) for i in range(6)]]
                d.line(pts + [pts[0]], fill=rng2.randint(110, 190), width=int(2.4 * s))
                for a in [math.radians(30 + 60 * i) for i in range(6)]:
                    d.line([(cx, cy), (cx + math.cos(a) * step * 0.5, cy + math.sin(a) * step * 0.5)],
                           fill=rng2.randint(70, 150), width=int(1.8 * s))
    m = mask_draw(w, h, pattern, 1.5, blur=0.5)
    rgb = blend(rgb, hexc("#A8CBE8"), m * 0.78)
    # Золотые точки в центрах
    def dots(d, s):
        step = w * 0.13 * s
        h_step = step * math.sqrt(3) / 2
        for row in range(0, int(h / h_step), 2):
            for col in range(0, int(w / step), 2):
                cx = col * step + (row % 2) * step / 2
                cy = row * h_step
                r = 3.4 * s
                d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    dm = mask_draw(w, h, dots, 2.0, blur=0.4)
    rgb = blend(rgb, hexc("#C9A227"), dm * 0.7)
    rgb = add_sun(rgb, 0.78, 0.22, w * 0.07, hexc("#FFE0B0"), hexc("#F05A4A"), hexc("#C9362B"), 0.03)
    return finish(rgb, rng, paper=0.03, grain=0.014, vig=0.4)


STYLES = {
    "akane_no_sora": style_sunset_sky,
    "vermilion_dusk": style_akane_abstract,
    "kintoki": style_gold_leaf,
    "hinomaru": style_hinomaru,
    "yozakura": style_sakura_night,
    "somei_yoshino": style_sakura_light,
    "hanafubuki": style_petal_storm,
    "sakura_no_uta": style_sakura_uta,
    "sumi_no_mai": style_enso,
    "kurogane": style_kintsugi,
    "ink_and_gold": style_ink_gold,
    "kannon": style_ink_mountains,
    "ai_no_kawa": style_indigo_river,
    "ruri": style_lapis_night,
    "seigaiha": style_seigaiha,
    "asanoha": style_asanoha,
}


def main() -> None:
    WALLPAPERS.mkdir(parents=True, exist_ok=True)
    TEXTURES.mkdir(parents=True, exist_ok=True)
    catalog = json.loads((ROOT / "assets" / "catalog" / "catalog.json").read_text())
    items = catalog["items"]

    for index, item in enumerate(items):
        style = STYLES[item["id"].replace("-", "_")]
        for suffix, (w, h) in (("p", (W_P, H_P)), ("l", (W_L, H_L))):
            seed = 1000 + index * 17 + (0 if suffix == "p" else 5)
            rng = np.random.default_rng(seed)
            rgb = style(w, h, rng)
            path = WALLPAPERS / f"{item['id']}_{suffix}.jpg"
            save(rgb, path, quality=90)
            print(f"  {path.name:34s} {path.stat().st_size // 1024} KB")

    # Текстуры
    rng = np.random.default_rng(999)
    grain = rng.normal(0.5, 0.16, (256, 256)).clip(0, 1)
    grain = (grain * 255).astype(np.uint8)
    Image.fromarray(np.dstack([grain] * 3), "RGB").save(TEXTURES / "grain.png", optimize=True)

    paper = fbm(512, 512, np.random.default_rng(1000), octaves=5, base=4)
    paper = ((paper - paper.min()) / (paper.max() - paper.min()) * 255).astype(np.uint8)
    Image.fromarray(np.dstack([paper] * 3), "RGB").save(TEXTURES / "paper.png", optimize=True)
    print("Текстуры готовы.")


if __name__ == "__main__":
    main()

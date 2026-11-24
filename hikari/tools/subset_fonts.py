#!/usr/bin/env python3
"""Сабсетит шрифты до реально используемых глифов (OFL)."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parent.parent
FONTS = Path.home() / ".cache" / "fonts"
OUT = ROOT / "assets" / "fonts"
OUT.mkdir(parents=True, exist_ok=True)


def used_chars() -> str:
    chars = set(chr(i) for i in range(32, 127))
    chars |= set("«»—–…№•·°’“”")
    chars |= {chr(i) for i in range(0x400, 0x530)}  # ввод кириллицы в поиске
    for path in list((ROOT / "lib").rglob("*.dart")) + [ROOT / "assets" / "catalog" / "catalog.json"]:
        chars |= set(path.read_text(encoding="utf-8"))
    # Сортируем для воспроизводимости.
    return "".join(sorted(c for c in chars if c.isprintable() or c == "\n"))


def subset(src: Path, dst: Path, text: str) -> None:
    cmd = [
        sys.executable, "-m", "fontTools.subset", str(src),
        f"--text={text}",
        f"--output-file={dst}",
        "--layout-features=*",
        "--no-hinting",
        "--desubroutinize",
        "--drop-tables+=DSIG",
        "--name-IDs=*",
        "--recalc-bounds",
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    print(f"  {dst.name:48s} {dst.stat().st_size // 1024:4d} KB")


def main() -> None:
    text = used_chars()

    # Yuji Syuku — только 光 (кистевой знак).
    subset(FONTS / "YujiSyuku-Regular.ttf", OUT / "YujiSyuku-Regular-subset.ttf", "光")

    # Caveat Brush — подпись Hikari.
    subset(FONTS / "CaveatBrush-Regular.ttf", OUT / "CaveatBrush-Regular-subset.ttf",
           "Hikari")

    # Shippori Mincho — японские подписи.
    for weight, name in (("Regular", "Regular"), ("SemiBold", "SemiBold")):
        subset(FONTS / f"ShipporiMincho-{weight}.ttf",
               OUT / f"ShipporiMincho-{name}-subset.ttf", text)

    # Inter — основной интерфейсный шрифт.
    for wght, name in ((400, "Regular"), (500, "Medium"), (600, "SemiBold"), (700, "Bold")):
        font = TTFont(FONTS / "Inter%5Bopsz,wght%5D.ttf")
        instantiateVariableFont(font, {"wght": wght, "opsz": 14}, inplace=True)
        tmp = OUT / f"_inter_{name}.ttf"
        font.save(tmp)
        subset(tmp, OUT / f"Inter-{name}-subset.ttf", text)
        tmp.unlink()

    # Playfair Display — переменный, нужны статические начертания.
    for wght, name in ((400, "Regular"), (600, "SemiBold"), (700, "Bold")):
        font = TTFont(FONTS / "PlayfairDisplay%5Bwght%5D.ttf")
        instantiateVariableFont(font, {"wght": wght}, inplace=True)
        tmp = OUT / f"_playfair_{name}.ttf"
        font.save(tmp)
        subset(tmp, OUT / f"PlayfairDisplay-{name}-subset.ttf", text)
        tmp.unlink()


if __name__ == "__main__":
    main()

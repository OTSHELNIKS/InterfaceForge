#!/usr/bin/env python3
"""Проверяет, что все ассеты из catalog.json существуют на диске.

Запуск из корня проекта: python3 tools/check_assets.py
Возвращает код 1, если хотя бы один путь битый.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "assets" / "catalog" / "catalog.json"


def main() -> int:
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    problems: list[str] = []

    for item in data.get("items", []):
        item_id = item.get("id", "<без id>")
        for field in ("asset", "assetLandscape"):
            rel = item.get(field)
            if not rel:
                problems.append(f"{item_id}: отсутствует поле {field}")
                continue
            if not (ROOT / rel).is_file():
                problems.append(f"{item_id}: {field} -> {rel} (файл не найден)")

    if problems:
        print("Найдены проблемы с ассетами:", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        return 1

    print(
        f"OK: {len(data.get('items', []))} работ, "
        f"{len(data.get('collections', []))} коллекций — все ассеты на месте."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

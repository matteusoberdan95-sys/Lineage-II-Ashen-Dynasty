# Build redistributable Ashen client-patch manifest (names + clone sources).
from __future__ import annotations

import csv
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ITEMS_DIR = REPO / "infrastructure" / "customization" / "game" / "data" / "stats" / "items"
NPCS_DIR = REPO / "infrastructure" / "customization" / "game" / "data" / "stats" / "npcs"
OUT = REPO / "infrastructure" / "customization" / "ashen_client" / "ashen_client_manifest.csv"

WEAPON_CLONE = {
    "dual": 5706,
    "divider": 6372,
    "dagger": 6367,
    "bow": 6368,
    "hammer": 6365,
    "spear": 6370,
    "fist": 6371,
    "staff": 6366,
    "blade": 6364,
}

FRAGMENT_IDS = {9399, 9499, 9699, 9799}
CLONE_FRAGMENT = 1785
CLONE_RECIPE = 3953
CLONE_ENCHANT_WEAPON = 6577
CLONE_ENCHANT_ARMOR = 6578
NPC_CLONE_RAID = 25325
NPC_CLONE_QUEST = 30001


def armor_clone_for(bodypart: str, armor_type: str, name: str) -> int:
    lname = name.lower()
    if bodypart == "lhand" or "shield" in lname:
        return 6377
    if bodypart == "head":
        if "circlet" in lname:
            return 6386
        if "leather" in lname:
            return 6382
        return 6378
    if bodypart == "chest":
        return 6373
    if bodypart == "legs":
        return 6374
    if bodypart == "onepiece":
        if armor_type == "MAGIC" or "robe" in lname:
            return 6383
        return 6379
    if bodypart == "gloves":
        if "gauntlet" in lname:
            return 6375
        if "leather" in lname:
            return 6380
        # Robe-line gloves use "Gloves" without Gauntlets/Leather.
        if name.endswith("Gloves"):
            return 6384
        return 6375
    if bodypart == "feet":
        if "leather" in lname:
            return 6381
        if name.endswith("Shoes"):
            return 6385
        return 6376
    return 6373


def weapon_clone_for(name: str) -> int:
    lname = name.lower()
    for key in ("dual", "divider", "dagger", "bow", "hammer", "spear", "fist", "staff"):
        if key in lname:
            return WEAPON_CLONE[key]
    return WEAPON_CLONE["blade"]


def etc_clone_for(item_id: int, icon: str) -> int:
    if item_id in FRAGMENT_IDS:
        return CLONE_FRAGMENT
    if item_id == 9570:
        return CLONE_ENCHANT_WEAPON
    if item_id == 9571:
        return CLONE_ENCHANT_ARMOR
    if "recipe" in icon.lower() or 9500 <= item_id <= 9599:
        return CLONE_RECIPE
    return CLONE_FRAGMENT


def parse_items():
    rows = []
    item_re = re.compile(
        r'<item id="(\d+)" type="(Armor|Weapon|EtcItem)" name="([^"]+)".*?</item>',
        re.S,
    )
    set_re = re.compile(r'<set name="([^"]+)" val="([^"]+)"')
    for path in sorted(ITEMS_DIR.glob("*.xml")):
        text = path.read_text(encoding="utf-8")
        for match in item_re.finditer(text):
            item_id = int(match.group(1))
            typ = match.group(2)
            name = match.group(3)
            body = match.group(0)
            props = dict(set_re.findall(body))
            icon = props.get("icon", "")
            if typ == "Armor":
                clone = armor_clone_for(props.get("bodypart", ""), props.get("armor_type", ""), name)
                # Interlude client stores shields in weapongrp.dat, not armorgrp.dat.
                if props.get("bodypart") == "lhand" or "shield" in name.lower():
                    kind = "weapon"
                else:
                    kind = "armor"
            elif typ == "Weapon":
                kind = "weapon"
                clone = weapon_clone_for(name)
            else:
                kind = "etc"
                clone = etc_clone_for(item_id, icon)
            rows.append(
                {
                    "id": item_id,
                    "kind": kind,
                    "name": name,
                    "description": f"Ashen Dynasty {name}.",
                    "clone_from": clone,
                    "icon": icon,
                }
            )
    return rows


def parse_npcs():
    rows = []
    npc_re = re.compile(r'<npc id="(\d+)"[^>]* name="([^"]+)"(?: title="([^"]*)")?')
    for path in sorted(NPCS_DIR.glob("*.xml")):
        text = path.read_text(encoding="utf-8")
        for match in npc_re.finditer(text):
            npc_id = int(match.group(1))
            rows.append(
                {
                    "id": npc_id,
                    "kind": "npc",
                    "name": match.group(2),
                    "description": match.group(3) or "",
                    "clone_from": NPC_CLONE_QUEST if npc_id == 93002 else NPC_CLONE_RAID,
                    "icon": "",
                }
            )
    return rows


def main() -> None:
    rows = parse_items() + parse_npcs()
    rows.sort(key=lambda r: (r["kind"], r["id"]))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", encoding="utf-8", newline="\n") as fh:
        writer = csv.DictWriter(
            fh, fieldnames=["id", "kind", "name", "description", "clone_from", "icon"]
        )
        writer.writeheader()
        writer.writerows(rows)
    print(f"wrote {OUT.relative_to(REPO)} ({len(rows)} rows)")


if __name__ == "__main__":
    main()

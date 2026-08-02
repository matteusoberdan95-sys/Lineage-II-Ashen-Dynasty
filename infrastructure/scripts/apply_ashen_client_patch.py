"""Merge Ashen names/icons into decoded Interlude client DAT binaries."""
from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

from lib_l2_client_dat import (
    PARSERS,
    build_itemname_record,
    build_npcname_record,
    clone_record,
    write_records,
)

ID_OFFSET = {
    "itemname": 0,
    "npcname": 0,
    "npcgrp": 0,
    "armorgrp": 4,
    "weapongrp": 4,
    "etcitemgrp": 4,
}


def load_manifest(path: Path):
    with path.open(encoding="utf-8", newline="") as fh:
        return list(csv.DictReader(fh))


def upsert_itemname(records, rows):
    for row in rows:
        if row["kind"] == "npc":
            continue
        item_id = int(row["id"])
        records[item_id] = build_itemname_record(
            item_id, row["name"], row.get("description") or f"Ashen Dynasty {row['name']}."
        )


def upsert_npcname(records, rows):
    for row in rows:
        if row["kind"] != "npc":
            continue
        npc_id = int(row["id"])
        records[npc_id] = build_npcname_record(npc_id, row["name"], row.get("description") or "")


def upsert_clones(records, rows, kinds, id_offset: int):
    for row in rows:
        if row["kind"] not in kinds:
            continue
        new_id = int(row["id"])
        clone_from = int(row["clone_from"])
        records[new_id] = clone_record(records, clone_from, new_id, id_offset)


def process_file(kind: str, src: Path, dst: Path, rows) -> int:
    data = src.read_bytes()
    records, trailer = PARSERS[kind](data)
    before = len(records)
    if kind == "itemname":
        upsert_itemname(records, rows)
    elif kind == "npcname":
        upsert_npcname(records, rows)
    elif kind == "armorgrp":
        upsert_clones(records, rows, {"armor"}, ID_OFFSET[kind])
    elif kind == "weapongrp":
        upsert_clones(records, rows, {"weapon"}, ID_OFFSET[kind])
    elif kind == "etcitemgrp":
        upsert_clones(records, rows, {"etc"}, ID_OFFSET[kind])
    elif kind == "npcgrp":
        upsert_clones(records, rows, {"npc"}, ID_OFFSET[kind])
    else:
        raise ValueError(kind)
    dst.write_bytes(write_records(records, trailer))
    return len(records) - before


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--decoded-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    rows = load_manifest(Path(args.manifest))
    decoded = Path(args.decoded_dir)
    output = Path(args.output_dir)
    output.mkdir(parents=True, exist_ok=True)

    files = {
        "itemname": "itemname-e.bin",
        "npcname": "npcname-e.bin",
        "armorgrp": "armorgrp.bin",
        "weapongrp": "weapongrp.bin",
        "etcitemgrp": "etcitemgrp.bin",
        "npcgrp": "npcgrp.bin",
    }
    for kind, fname in files.items():
        src = decoded / fname
        if not src.is_file():
            print(f"missing decoded file: {src}", file=sys.stderr)
            return 1
        added = process_file(kind, src, output / fname, rows)
        print(f"{kind}: wrote {output / fname} (+{added} upserts, total logic applied)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

"""Interlude client DAT helpers (Ver413 decode already applied).

Formats follow L2ClientDat chronicle definitions (Interlude / ScionsOfDestiny).
Only redistributable Ashen metadata is versioned; proprietary .dat stay local.
"""
from __future__ import annotations

import struct
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Tuple

SAFE_PACKAGE = "SafePackage"


def read_compact_int(data: bytes, off: int) -> Tuple[int, int]:
    output = 0
    signed = False
    for i in range(5):
        x = data[off]
        off += 1
        if i == 0:
            signed = (x & 0x80) != 0
            output |= x & 0x3F
            if (x & 0x40) == 0:
                break
        elif i == 4:
            output |= (x & 0x1F) << 27
        else:
            output |= (x & 0x7F) << (6 + (i - 1) * 7)
            if (x & 0x80) == 0:
                break
    if signed:
        output *= -1
    return output, off


def write_compact_int(value: int) -> bytes:
    negative = value < 0
    value = abs(value)
    out = bytearray()
    if value <= 0x3F:
        out.append(value | (0x80 if negative else 0))
        return bytes(out)
    out.append((value & 0x3F) | 0x40 | (0x80 if negative else 0))
    value >>= 6
    while value > 0x7F:
        out.append((value & 0x7F) | 0x80)
        value >>= 7
    out.append(value & 0x7F)
    return bytes(out)


def read_unicode(data: bytes, off: int) -> Tuple[str, int]:
    (n,) = struct.unpack_from("<I", data, off)
    off += 4
    if n < 0 or off + n > len(data):
        raise ValueError(f"bad UNICODE length {n} at {off}")
    text = data[off : off + n].decode("utf-16-le")
    return text, off + n


def write_unicode(text: str) -> bytes:
    encoded = text.encode("utf-16-le")
    return struct.pack("<I", len(encoded)) + encoded


def read_ascf(data: bytes, off: int) -> Tuple[str, int]:
    length, off = read_compact_int(data, off)
    if length == 0:
        return "", off
    size = length if length > 0 else (-2 * length)
    if size < 0 or off + size > len(data):
        raise ValueError(f"bad ASCF length {length} at {off}")
    raw = data[off : off + size]
    off += size
    if length > 0:
        return raw[:-1].decode("cp1252", "replace"), off
    return raw[:-2].decode("utf-16-le", "replace"), off


def write_ascf(text: str) -> bytes:
    if text is None or text == "":
        return write_compact_int(0)
    try:
        payload = (text + "\0").encode("cp1252")
        return write_compact_int(len(payload)) + payload
    except UnicodeEncodeError:
        payload = (text + "\0").encode("utf-16-le")
        return write_compact_int(-(len(payload) // 2)) + payload


def read_uint(data: bytes, off: int) -> Tuple[int, int]:
    (value,) = struct.unpack_from("<I", data, off)
    return value, off + 4


def read_int(data: bytes, off: int) -> Tuple[int, int]:
    (value,) = struct.unpack_from("<i", data, off)
    return value, off + 4


def read_float(data: bytes, off: int) -> Tuple[float, int]:
    (value,) = struct.unpack_from("<f", data, off)
    return value, off + 4


def skip_mtx(data: bytes, off: int) -> int:
    count1, off = read_int(data, off)
    for _ in range(count1):
        _, off = read_unicode(data, off)
    count2, off = read_int(data, off)
    for _ in range(count2):
        _, off = read_unicode(data, off)
    return off


def strip_safe_package(data: bytes) -> bytes:
    marker = b"SafePackage\x00"
    idx = data.rfind(marker)
    if idx < 1:
        return data
    # ASCF length byte(s) immediately before marker; for short string it's one byte 0x0c.
    return data[: idx - 1]


@dataclass
class NamedRecord:
    item_id: int
    raw: bytes


def _replace_id_at(raw: bytes, id_offset: int, new_id: int) -> bytes:
    return raw[:id_offset] + struct.pack("<I", new_id) + raw[id_offset + 4 :]


def parse_itemname(data: bytes) -> Tuple[Dict[int, bytes], bytes]:
    body = strip_safe_package(data)
    count, off = read_uint(body, 0)
    records: Dict[int, bytes] = {}
    for _ in range(count):
        start = off
        item_id, off = read_uint(body, off)
        _, off = read_unicode(body, off)
        _, off = read_unicode(body, off)
        _, off = read_ascf(body, off)
        off += 4  # popup
        for _ in range(4):
            _, off = read_ascf(body, off)
        off += 2  # unknown bytes
        off += 4  # set_enchant_count
        _, off = read_ascf(body, off)
        records[item_id] = body[start:off]
    if off != len(body):
        raise ValueError(f"ItemName parse incomplete: off={off} len={len(body)}")
    return records, write_ascf(SAFE_PACKAGE)


def build_itemname_record(
    item_id: int,
    name: str,
    description: str = "",
    additional_name: str = "",
) -> bytes:
    out = bytearray()
    out += struct.pack("<I", item_id)
    out += write_unicode(name)
    out += write_unicode(additional_name)
    out += write_ascf(description)
    out += struct.pack("<i", -1)  # popup
    out += write_ascf("")  # set_ids
    out += write_ascf("")  # set_bonus_desc
    out += write_ascf("")  # set_extra_id
    out += write_ascf("")  # set_extra_desc
    out += bytes([0, 0])
    out += struct.pack("<I", 0)
    out += write_ascf("")
    return bytes(out)


def write_records(records: Dict[int, bytes], trailer: bytes, order: Optional[List[int]] = None) -> bytes:
    ids = order if order is not None else sorted(records)
    out = bytearray()
    out += struct.pack("<I", len(ids))
    for item_id in ids:
        out += records[item_id]
    out += trailer
    return bytes(out)


def parse_npcname(data: bytes) -> Tuple[Dict[int, bytes], bytes]:
    body = strip_safe_package(data)
    count, off = read_uint(body, 0)
    records: Dict[int, bytes] = {}
    for _ in range(count):
        start = off
        npc_id, off = read_uint(body, off)
        _, off = read_ascf(body, off)
        _, off = read_ascf(body, off)
        off += 4  # RGBA
        records[npc_id] = body[start:off]
    if off != len(body):
        raise ValueError(f"NpcName parse incomplete: off={off} len={len(body)}")
    return records, write_ascf(SAFE_PACKAGE)


def build_npcname_record(npc_id: int, name: str, nick: str = "", color: bytes = b"\x00\x00\x00\xff") -> bytes:
    if len(color) != 4:
        raise ValueError("RGBA color must be 4 bytes")
    return struct.pack("<I", npc_id) + write_ascf(name) + write_ascf(nick) + color


def parse_etcitemgrp(data: bytes) -> Tuple[Dict[int, bytes], bytes]:
    body = strip_safe_package(data)
    count, off = read_uint(body, 0)
    records: Dict[int, bytes] = {}
    for _ in range(count):
        start = off
        off += 4  # tag
        object_id, off = read_uint(body, off)
        off += 4 * 5  # drop fields + UNK_0
        for _ in range(3 + 3 + 5):
            _, off = read_unicode(body, off)
        off += 4 * 5  # durability..type1
        # MTX mesh_tex_pair
        off = skip_mtx(body, off)
        _, off = read_unicode(body, off)  # drop_sound
        _, off = read_unicode(body, off)  # equip_sound
        off += 4 * 3  # stackable, etcitem_type, crystal_type
        records[object_id] = body[start:off]
    if off != len(body):
        raise ValueError(f"EtcItemGrp parse incomplete: off={off} len={len(body)}")
    return records, write_ascf(SAFE_PACKAGE)


def parse_armorgrp(data: bytes) -> Tuple[Dict[int, bytes], bytes]:
    body = strip_safe_package(data)
    count, off = read_uint(body, 0)
    records: Dict[int, bytes] = {}
    for _ in range(count):
        start = off
        off += 4  # tag
        object_id, off = read_uint(body, off)
        off += 4 * 5
        for _ in range(3 + 3 + 5):
            _, off = read_unicode(body, off)
        off += 4 * 6  # durability..body_part
        for _ in range(31):  # MTX blocks in SOD armorgrp
            off = skip_mtx(body, off)
        _, off = read_unicode(body, off)  # attack_effect
        sound_count, off = read_uint(body, off)
        for _ in range(sound_count):
            _, off = read_unicode(body, off)
        _, off = read_unicode(body, off)  # drop_sound
        _, off = read_unicode(body, off)  # equip_sound
        off += 4 * 8  # trailing ints
        records[object_id] = body[start:off]
    if off != len(body):
        raise ValueError(f"ArmorGrp parse incomplete: off={off} len={len(body)}")
    return records, write_ascf(SAFE_PACKAGE)


def parse_weapongrp(data: bytes) -> Tuple[Dict[int, bytes], bytes]:
    body = strip_safe_package(data)
    count, off = read_uint(body, 0)
    records: Dict[int, bytes] = {}
    for _ in range(count):
        start = off
        off += 4
        object_id, off = read_uint(body, off)
        off += 4 * 5
        for _ in range(3 + 3 + 5):
            _, off = read_unicode(body, off)
        off += 4 * 7  # durability..handness
        wp_mesh, off = read_uint(body, off)
        for _ in range(wp_mesh):
            _, off = read_unicode(body, off)
        texture_count, off = read_uint(body, off)
        for _ in range(texture_count):
            _, off = read_unicode(body, off)
        sound_count, off = read_uint(body, off)
        for _ in range(sound_count):
            _, off = read_unicode(body, off)
        for _ in range(3):
            _, off = read_unicode(body, off)  # drop/equip/effect
        # random_damage..UNK_3 (18 x 4 bytes)
        off += 4 * 18
        _, off = read_unicode(body, off)  # effA
        if wp_mesh == 2:
            _, off = read_unicode(body, off)  # effB
        off += 4 * 5  # junk1A floats
        if wp_mesh == 2:
            off += 4 * 5
        _, off = read_unicode(body, off)  # rangeA
        if wp_mesh == 2:
            _, off = read_unicode(body, off)
        off += 4 * 6  # junk2A
        if wp_mesh == 2:
            off += 4 * 6
        off += 4 * 4  # junk ints
        for _ in range(4):
            _, off = read_unicode(body, off)  # variation icons
        records[object_id] = body[start:off]
    if off != len(body):
        raise ValueError(f"WeaponGrp parse incomplete: off={off} len={len(body)}")
    return records, write_ascf(SAFE_PACKAGE)


def parse_npcgrp(data: bytes) -> Tuple[Dict[int, bytes], bytes]:
    body = strip_safe_package(data)
    count, off = read_uint(body, 0)
    records: Dict[int, bytes] = {}
    for _ in range(count):
        start = off
        npc_id, off = read_uint(body, off)
        _, off = read_unicode(body, off)
        _, off = read_unicode(body, off)
        tex_count, off = read_uint(body, off)
        for _ in range(tex_count):
            _, off = read_unicode(body, off)
        tex2_count, off = read_uint(body, off)
        for _ in range(tex2_count):
            _, off = read_unicode(body, off)
        prop_count, off = read_compact_int(body, off)
        off += 4 * prop_count
        off += 4  # float speed
        unk_count, off = read_uint(body, off)
        for _ in range(unk_count):
            _, off = read_unicode(body, off)
        for _ in range(3):
            n, off = read_uint(body, off)
            for _ in range(n):
                _, off = read_unicode(body, off)
        deco_count, off = read_uint(body, off)
        for _ in range(deco_count):
            _, off = read_unicode(body, off)
            off += 4
        unk1_count, off = read_compact_int(body, off)
        off += 4 * unk1_count
        _, off = read_unicode(body, off)
        off += 4  # unknown_2
        off += 4 * 3  # floats
        off += 4 * 2  # quest_be, class_lim
        records[npc_id] = body[start:off]
    if off != len(body):
        raise ValueError(f"NpcGrp parse incomplete: off={off} len={len(body)}")
    return records, write_ascf(SAFE_PACKAGE)


PARSERS: Dict[str, Callable[[bytes], Tuple[Dict[int, bytes], bytes]]] = {
    "itemname": parse_itemname,
    "npcname": parse_npcname,
    "etcitemgrp": parse_etcitemgrp,
    "armorgrp": parse_armorgrp,
    "weapongrp": parse_weapongrp,
    "npcgrp": parse_npcgrp,
}


def clone_record(records: Dict[int, bytes], clone_from: int, new_id: int, id_offset: int) -> bytes:
    if clone_from not in records:
        raise KeyError(f"clone source id {clone_from} not found")
    return _replace_id_at(records[clone_from], id_offset, new_id)

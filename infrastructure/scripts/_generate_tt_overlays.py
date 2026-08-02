# One-shot generator for Ashen TT overlays (Sprint 13). Run from repo root.
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'customization'


def write(rel: str, text: str) -> None:
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.lstrip('\n'), encoding='utf-8', newline='\n')
    print('wrote', path.relative_to(ROOT))


def armor(id_, name, icon, armor_type, bodypart, weight, price, pdef, maxmp=None):
    armor_line = f'\t\t<set name="armor_type" val="{armor_type}" />\n' if armor_type else ''
    stats = [f'\t\t\t<stat type="pDef">{pdef}</stat>']
    if maxmp is not None:
        stats.append(f'\t\t\t<stat type="maxMp">{maxmp}</stat>')
    return f'''\t<item id="{id_}" type="Armor" name="{name}">
\t\t<!-- Ashen TT (ADR-007). Client may show generic name/icon until client-patch. -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
{armor_line}\t\t<set name="bodypart" val="{bodypart}" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="800" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ADAMANTAITE" />
\t\t<set name="weight" val="{weight}" />
\t\t<set name="price" val="{price}" />
\t\t<set name="element_enabled" val="true" />
\t\t<set name="enchant_enabled" val="true" />
\t\t<conditions msgId="1518">
\t\t\t<player races="HUMAN,ELF,DARK_ELF,ORC,DWARF" />
\t\t</conditions>
\t\t<stats>
{chr(10).join(stats)}
\t\t</stats>
\t</item>'''


def weapon(id_, name, icon, wtype, body, p_atk, m_atk, crit, spd, rnd, rng, weight, extra='', skills=''):
    skill_block = f'\n\t\t<skills>\n{skills}\n\t\t</skills>' if skills else ''
    return f'''\t<item id="{id_}" type="Weapon" name="{name}">
\t\t<!-- Ashen TT weapon (ADR-007). -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="weapon_type" val="{wtype}" />
\t\t<set name="bodypart" val="{body}" />
\t\t<set name="damage_range" val="0;0;40;120" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="2700" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ADAMANTAITE" />
\t\t<set name="weight" val="{weight}" />
\t\t<set name="price" val="55000000" />
\t\t<set name="soulshots" val="1" />
\t\t<set name="spiritshots" val="1" />
\t\t<set name="element_enabled" val="true" />
\t\t<set name="enchant_enabled" val="true" />{extra}
\t\t<stats>
\t\t\t<stat type="pAtk">{p_atk}</stat>
\t\t\t<stat type="mAtk">{m_atk}</stat>
\t\t\t<stat type="critRate">{crit}</stat>
\t\t\t<stat type="pAtkSpd">{spd}</stat>
\t\t\t<stat type="randomDamage">{rnd}</stat>
\t\t\t<stat type="pAtkRange">{rng}</stat>
\t\t</stats>{skill_block}
\t</item>'''


items = [
    armor(9300, 'Ashen TT Helmet', 'icon.armor_helmet_i00', None, 'head', 550, 6000000, 93),
    armor(9301, 'Ashen TT Breastplate', 'icon.armor_t88_u_i00', 'HEAVY', 'chest', 7620, 16000000, 230),
    armor(9302, 'Ashen TT Gaiters', 'icon.armor_t88_l_i00', 'HEAVY', 'legs', 3260, 10000000, 143),
    armor(9303, 'Ashen TT Gauntlets', 'icon.armor_t88_g_i00', None, 'gloves', 540, 4000000, 62),
    armor(9304, 'Ashen TT Boots', 'icon.armor_t88_b_i00', None, 'feet', 1110, 4000000, 62),
    '''\t<item id="9305" type="Armor" name="Ashen TT Shield">
\t\t<set name="icon" val="icon.shield_imperial_crusader_shield_i00" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="bodypart" val="lhand" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="200" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="BONE" />
\t\t<set name="weight" val="1170" />
\t\t<set name="price" val="4200000" />
\t\t<set name="enchant_enabled" val="true" />
\t\t<conditions msgId="1518">
\t\t\t<player races="HUMAN,ELF,DARK_ELF,ORC,DWARF" />
\t\t</conditions>
\t\t<stats>
\t\t\t<stat type="rEvas">-8</stat>
\t\t\t<stat type="rShld">20</stat>
\t\t\t<stat type="sDef">325</stat>
\t\t</stats>
\t</item>''',
    armor(9330, 'Ashen TT Leather Helmet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 6000000, 93),
    armor(9331, 'Ashen TT Leather Armor', 'icon.armor_t89_ul_i00', 'LIGHT', 'onepiece', 4950, 19500000, 279),
    armor(9332, 'Ashen TT Leather Gloves', 'icon.armor_t89_g_i00', None, 'gloves', 540, 4000000, 62),
    armor(9333, 'Ashen TT Leather Boots', 'icon.armor_t89_b_i00', None, 'feet', 1110, 4000000, 62),
    armor(9360, 'Ashen TT Circlet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 6000000, 93),
    armor(9361, 'Ashen TT Robe', 'icon.armor_t90_ul_i00', 'MAGIC', 'onepiece', 2300, 19500000, 186, maxmp=970),
    armor(9362, 'Ashen TT Gloves', 'icon.armor_t90_g_i00', None, 'gloves', 540, 4000000, 62),
    armor(9363, 'Ashen TT Shoes', 'icon.armor_t90_b_i00', None, 'feet', 1110, 4000000, 62),
    weapon(9390, 'Ashen TT Blade', 'icon.weapon_forgotten_blade_i00', 'SWORD', 'rhand', 315, 148, 8, 379, 10, 40, 1300),
    weapon(9391, 'Ashen TT Divider', 'icon.weapon_heavens_divider_i00', 'SWORD', 'lrhand', 383, 148, 8, 325, 10, 40, 1380),
    weapon(9392, 'Ashen TT Dual Swords', 'icon.weapon_dual_sword_i00', 'DUAL', 'lrhand', 383, 148, 8, 325, 10, 40, 2080),
    weapon(9393, 'Ashen TT Dagger', 'icon.weapon_angel_slayer_i00', 'DAGGER', 'rhand', 276, 148, 12, 433, 5, 40, 950),
    weapon(
        9394, 'Ashen TT Bow', 'icon.weapon_shining_bow_i00', 'BOW', 'lrhand', 651, 148, 12, 293, 5, 500, 1650,
        extra='\n\t\t<set name="mp_consume" val="11" />\n\t\t<set name="reuse_delay" val="820" />',
    ),
    weapon(9395, 'Ashen TT Hammer', 'icon.weapon_basalt_battlehammer_i00', 'BLUNT', 'rhand', 315, 148, 4, 379, 20, 40, 1570),
    weapon(
        9396, 'Ashen TT Spear', 'icon.weapon_saint_spear_i00', 'POLE', 'lrhand', 315, 148, 8, 325, 10, 80, 1800,
        skills='\t\t\t<skill id="3599" level="1" />',
    ),
    weapon(9397, 'Ashen TT Fist', 'icon.weapon_demon_splinter_i00', 'DUALFIST', 'lrhand', 383, 148, 4, 325, 5, 40, 1350),
    weapon(
        9398, 'Ashen TT Staff', 'icon.weapon_imperial_staff_i00', 'BLUNT', 'lrhand', 307, 216, 4, 325, 20, 40, 910,
        extra='\n\t\t<set name="is_magic_weapon" val="true" />',
    ),
    '''\t<item id="9399" type="EtcItem" name="Ashen TT Fragment">
\t\t<!-- Token for future TT craft (ADR-007). -->
\t\t<set name="icon" val="icon.etc_stone_gray_i00" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="LIQUID" />
\t\t<set name="weight" val="10" />
\t\t<set name="price" val="0" />
\t\t<set name="is_stackable" val="true" />
\t</item>''',
]

write(
    'game/data/stats/items/09300-09399.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynasty TT items — ADR-007 / Sprint 13 -->
{chr(10).join(items)}
</list>
''',
)

write(
    'game/data/stats/armorsets/ashen_tt.xml',
    '<?xml version="1.0" encoding="UTF-8"?>\n<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/armorSets.xsd">\n\t<!-- Element order must match armorSets.xsd: chest before head. -->\n\t<set id="100">\n\t\t<chest id="9301" />\n\t\t<legs id="9302" />\n\t\t<head id="9300" />\n\t\t<gloves id="9303" />\n\t\t<feet id="9304" />\n\t\t<shield id="9305" />\n\t\t<skill id="3006" level="1" />\n\t\t<str val="3" />\n\t\t<con val="2" />\n\t</set>\n\t<set id="101">\n\t\t<chest id="9331" />\n\t\t<head id="9330" />\n\t\t<gloves id="9332" />\n\t\t<feet id="9333" />\n\t\t<skill id="3006" level="1" />\n\t\t<str val="2" />\n\t\t<dex val="3" />\n\t</set>\n\t<set id="102">\n\t\t<chest id="9361" />\n\t\t<head id="9360" />\n\t\t<gloves id="9362" />\n\t\t<feet id="9363" />\n\t\t<skill id="3006" level="1" />\n\t\t<int val="3" />\n\t\t<wit val="2" />\n\t</set>\n</list>\n',
)

write(
    'game/data/stats/npcs/93000-93099.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/npcs.xsd">
\t<npc id="93000" level="80" type="RaidBoss" name="Guardian of Ashen TT" title="Ashen Dynasty">
\t\t<parameters>
\t\t\t<param name="RaidSpawnMusic" value="Rm01_A" />
\t\t</parameters>
\t\t<race>HUMANOID</race>
\t\t<sex>MALE</sex>
\t\t<acquire exp="5200000" sp="1100000" />
\t\t<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
\t\t\t<vitals hp="420000" hpRegen="130" mp="1600" mpRegen="3" />
\t\t\t<attack physical="2600" magical="900" random="50" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
\t\t\t<defence physical="1000" magical="500" evasion="-18" />
\t\t\t<speed>
\t\t\t\t<walk ground="50" />
\t\t\t\t<run ground="190" />
\t\t\t</speed>
\t\t\t<hitTime>470</hitTime>
\t\t</stats>
\t\t<status undying="false" />
\t\t<skillList>
\t\t\t<skill id="4045" level="1" />
\t\t\t<skill id="4494" level="1" />
\t\t</skillList>
\t\t<exCrtEffect>true</exCrtEffect>
\t\t<ai type="BALANCED" clanHelpRange="300" isAggressive="false" />
\t\t<dropLists>
\t\t\t<drop>
\t\t\t\t<group chance="100">
\t\t\t\t\t<item id="57" min="500000" max="900000" chance="100" />
\t\t\t\t</group>
\t\t\t\t<group chance="100">
\t\t\t\t\t<item id="9399" min="2" max="5" chance="100" />
\t\t\t\t</group>
\t\t\t\t<group chance="35">
\t\t\t\t\t<item id="9300" min="1" max="1" chance="16" />
\t\t\t\t\t<item id="9301" min="1" max="1" chance="16" />
\t\t\t\t\t<item id="9302" min="1" max="1" chance="16" />
\t\t\t\t\t<item id="9303" min="1" max="1" chance="16" />
\t\t\t\t\t<item id="9304" min="1" max="1" chance="16" />
\t\t\t\t\t<item id="9305" min="1" max="1" chance="20" />
\t\t\t\t</group>
\t\t\t\t<group chance="25">
\t\t\t\t\t<item id="9330" min="1" max="1" chance="25" />
\t\t\t\t\t<item id="9331" min="1" max="1" chance="25" />
\t\t\t\t\t<item id="9332" min="1" max="1" chance="25" />
\t\t\t\t\t<item id="9333" min="1" max="1" chance="25" />
\t\t\t\t</group>
\t\t\t\t<group chance="25">
\t\t\t\t\t<item id="9360" min="1" max="1" chance="25" />
\t\t\t\t\t<item id="9361" min="1" max="1" chance="25" />
\t\t\t\t\t<item id="9362" min="1" max="1" chance="25" />
\t\t\t\t\t<item id="9363" min="1" max="1" chance="25" />
\t\t\t\t</group>
\t\t\t</drop>
\t\t</dropLists>
\t\t<collision>
\t\t\t<radius normal="20" />
\t\t\t<height normal="40" />
\t\t</collision>
\t</npc>
\t<npc id="93001" level="78" type="RaidBoss" name="Ashen Warden" title="Ashen Dynasty">
\t\t<race>HUMANOID</race>
\t\t<sex>MALE</sex>
\t\t<acquire exp="3600000" sp="800000" />
\t\t<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
\t\t\t<vitals hp="300000" hpRegen="120" mp="1500" mpRegen="3" />
\t\t\t<attack physical="2400" magical="850" random="40" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
\t\t\t<defence physical="920" magical="460" evasion="-18" />
\t\t\t<speed>
\t\t\t\t<walk ground="50" />
\t\t\t\t<run ground="190" />
\t\t\t</speed>
\t\t\t<hitTime>450</hitTime>
\t\t</stats>
\t\t<status undying="false" />
\t\t<skillList>
\t\t\t<skill id="4045" level="1" />
\t\t\t<skill id="4494" level="1" />
\t\t</skillList>
\t\t<exCrtEffect>true</exCrtEffect>
\t\t<ai type="BALANCED" clanHelpRange="300" isAggressive="false" />
\t\t<dropLists>
\t\t\t<drop>
\t\t\t\t<group chance="100">
\t\t\t\t\t<item id="57" min="300000" max="600000" chance="100" />
\t\t\t\t</group>
\t\t\t\t<group chance="100">
\t\t\t\t\t<item id="9399" min="1" max="3" chance="100" />
\t\t\t\t</group>
\t\t\t\t<group chance="40">
\t\t\t\t\t<item id="9390" min="1" max="1" chance="12" />
\t\t\t\t\t<item id="9391" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9392" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9393" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9394" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9395" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9396" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9397" min="1" max="1" chance="11" />
\t\t\t\t\t<item id="9398" min="1" max="1" chance="11" />
\t\t\t\t</group>
\t\t\t</drop>
\t\t</dropLists>
\t\t<collision>
\t\t\t<radius normal="18" />
\t\t\t<height normal="38" />
\t\t</collision>
\t</npc>
</list>
''',
)

write(
    'game/data/spawns/Ashen/AshenTT.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list enabled="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/spawns.xsd">
\t<!-- Local endgame entry bosses near Death Pass / Giran wilds. Respawn 24h / 12h. -->
\t<spawn name="AshenTT">
\t\t<npc id="93000" x="70000" y="130000" z="-3720" heading="0" respawnDelay="86400" />
\t\t<npc id="93001" x="72000" y="128500" z="-3720" heading="0" respawnDelay="43200" />
\t</spawn>
</list>
''',
)

print('done')

# Generator for Ashen DK / Phoenix overlays (Sprint 18). ~15% above Draconic.
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
\t\t<!-- Ashen DK (ADR-009). Client may show generic name/icon until client-patch. -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
{armor_line}\t\t<set name="bodypart" val="{bodypart}" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="1000" />
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
\t\t<!-- Ashen Phoenix weapon (ADR-009). -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="weapon_type" val="{wtype}" />
\t\t<set name="bodypart" val="{body}" />
\t\t<set name="damage_range" val="0;0;40;120" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="3500" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ADAMANTAITE" />
\t\t<set name="weight" val="{weight}" />
\t\t<set name="price" val="85000000" />
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
    armor(9600, 'Ashen DK Helmet', 'icon.armor_helmet_i00', None, 'head', 550, 9500000, 123),
    armor(9601, 'Ashen DK Breastplate', 'icon.armor_t88_u_i00', 'HEAVY', 'chest', 7620, 26000000, 304),
    armor(9602, 'Ashen DK Gaiters', 'icon.armor_t88_l_i00', 'HEAVY', 'legs', 3260, 16000000, 189),
    armor(9603, 'Ashen DK Gauntlets', 'icon.armor_t88_g_i00', None, 'gloves', 540, 6500000, 82),
    armor(9604, 'Ashen DK Boots', 'icon.armor_t88_b_i00', None, 'feet', 1110, 6500000, 82),
    '''\t<item id="9605" type="Armor" name="Ashen DK Shield">
\t\t<set name="icon" val="icon.shield_imperial_crusader_shield_i00" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="bodypart" val="lhand" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="260" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ADAMANTAITE" />
\t\t<set name="weight" val="1170" />
\t\t<set name="price" val="6800000" />
\t\t<set name="enchant_enabled" val="true" />
\t\t<conditions msgId="1518">
\t\t\t<player races="HUMAN,ELF,DARK_ELF,ORC,DWARF" />
\t\t</conditions>
\t\t<stats>
\t\t\t<stat type="rEvas">-8</stat>
\t\t\t<stat type="rShld">20</stat>
\t\t\t<stat type="sDef">430</stat>
\t\t</stats>
\t</item>''',
    armor(9630, 'Ashen DK Leather Helmet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 9500000, 123),
    armor(9631, 'Ashen DK Leather Armor', 'icon.armor_t89_ul_i00', 'LIGHT', 'onepiece', 4950, 30000000, 369),
    armor(9632, 'Ashen DK Leather Gloves', 'icon.armor_t89_g_i00', None, 'gloves', 540, 6500000, 82),
    armor(9633, 'Ashen DK Leather Boots', 'icon.armor_t89_b_i00', None, 'feet', 1110, 6500000, 82),
    armor(9660, 'Ashen DK Circlet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 9500000, 123),
    armor(9661, 'Ashen DK Robe', 'icon.armor_t90_ul_i00', 'MAGIC', 'onepiece', 2300, 30000000, 246, maxmp=1282),
    armor(9662, 'Ashen DK Gloves', 'icon.armor_t90_g_i00', None, 'gloves', 540, 6500000, 82),
    armor(9663, 'Ashen DK Shoes', 'icon.armor_t90_b_i00', None, 'feet', 1110, 6500000, 82),
    weapon(9690, 'Ashen Phoenix Blade', 'icon.weapon_forgotten_blade_i00', 'SWORD', 'rhand', 416, 196, 8, 379, 10, 40, 1300),
    weapon(9691, 'Ashen Phoenix Divider', 'icon.weapon_heavens_divider_i00', 'SWORD', 'lrhand', 506, 196, 8, 325, 10, 40, 1380),
    weapon(9692, 'Ashen Phoenix Dual Swords', 'icon.weapon_dual_sword_i00', 'DUAL', 'lrhand', 506, 196, 8, 325, 10, 40, 2080),
    weapon(9693, 'Ashen Phoenix Dagger', 'icon.weapon_angel_slayer_i00', 'DAGGER', 'rhand', 365, 196, 12, 433, 5, 40, 950),
    weapon(
        9694, 'Ashen Phoenix Bow', 'icon.weapon_shining_bow_i00', 'BOW', 'lrhand', 860, 196, 12, 293, 5, 500, 1650,
        extra='\n\t\t<set name="mp_consume" val="12" />\n\t\t<set name="reuse_delay" val="820" />',
    ),
    weapon(9695, 'Ashen Phoenix Hammer', 'icon.weapon_basalt_battlehammer_i00', 'BLUNT', 'rhand', 416, 196, 4, 379, 20, 40, 1570),
    weapon(
        9696, 'Ashen Phoenix Spear', 'icon.weapon_saint_spear_i00', 'POLE', 'lrhand', 416, 196, 8, 325, 10, 80, 1800,
        skills='\t\t\t<skill id="3599" level="1" />',
    ),
    weapon(9697, 'Ashen Phoenix Fist', 'icon.weapon_demon_splinter_i00', 'DUALFIST', 'lrhand', 506, 196, 4, 325, 5, 40, 1350),
    weapon(
        9698, 'Ashen Phoenix Staff', 'icon.weapon_imperial_staff_i00', 'BLUNT', 'lrhand', 406, 285, 4, 325, 20, 40, 910,
        extra='\n\t\t<set name="is_magic_weapon" val="true" />',
    ),
    '''\t<item id="9699" type="EtcItem" name="Ashen DK Fragment">
\t\t<!-- Token for future DK/Phoenix craft (ADR-009). -->
\t\t<set name="icon" val="icon.etc_stone_gray_i00" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="LIQUID" />
\t\t<set name="weight" val="10" />
\t\t<set name="price" val="0" />
\t\t<set name="is_stackable" val="true" />
\t</item>''',
]

write(
    'game/data/stats/items/09600-09699.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynasty DK / Phoenix items — ADR-009 / Sprint 18 (~15% above Draconic) -->
{chr(10).join(items)}
</list>
''',
)

write(
    'game/data/stats/armorsets/ashen_dk.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/armorSets.xsd">
	<!-- Element order must match armorSets.xsd: chest before head. -->
	<set id="106">
		<chest id="9601" />
		<legs id="9602" />
		<head id="9600" />
		<gloves id="9603" />
		<feet id="9604" />
		<shield id="9605" />
		<skill id="3006" level="1" />
		<str val="5" />
		<con val="3" />
	</set>
	<set id="107">
		<chest id="9631" />
		<head id="9630" />
		<gloves id="9632" />
		<feet id="9633" />
		<skill id="3006" level="1" />
		<str val="3" />
		<dex val="5" />
	</set>
	<set id="108">
		<chest id="9661" />
		<head id="9660" />
		<gloves id="9662" />
		<feet id="9663" />
		<skill id="3006" level="1" />
		<int val="5" />
		<wit val="3" />
	</set>
</list>
''',
)

write(
    'game/data/stats/npcs/93200-93299.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/npcs.xsd">
	<npc id="93200" level="84" type="RaidBoss" name="Ashen Dark Warden" title="Ashen Dynasty">
		<parameters>
			<param name="RaidSpawnMusic" value="Rm01_A" />
		</parameters>
		<race>DEMONIC</race>
		<sex>MALE</sex>
		<acquire exp="7800000" sp="1700000" />
		<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
			<vitals hp="640000" hpRegen="150" mp="2000" mpRegen="3" />
			<attack physical="3200" magical="1100" random="50" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
			<defence physical="1280" magical="620" evasion="-18" />
			<speed>
				<walk ground="50" />
				<run ground="210" />
			</speed>
			<hitTime>470</hitTime>
		</stats>
		<status undying="false" />
		<skillList>
			<skill id="4045" level="1" />
			<skill id="4494" level="1" />
		</skillList>
		<exCrtEffect>true</exCrtEffect>
		<ai type="BALANCED" clanHelpRange="300" isAggressive="false" />
		<dropLists>
			<drop>
				<group chance="100">
					<item id="57" min="900000" max="1500000" chance="100" />
				</group>
				<group chance="100">
					<item id="9699" min="2" max="5" chance="100" />
				</group>
				<group chance="40">
					<item id="9499" min="1" max="2" chance="100" />
				</group>
				<group chance="28">
					<item id="9600" min="1" max="1" chance="16" />
					<item id="9601" min="1" max="1" chance="16" />
					<item id="9602" min="1" max="1" chance="16" />
					<item id="9603" min="1" max="1" chance="16" />
					<item id="9604" min="1" max="1" chance="16" />
					<item id="9605" min="1" max="1" chance="20" />
				</group>
				<group chance="20">
					<item id="9630" min="1" max="1" chance="25" />
					<item id="9631" min="1" max="1" chance="25" />
					<item id="9632" min="1" max="1" chance="25" />
					<item id="9633" min="1" max="1" chance="25" />
				</group>
				<group chance="20">
					<item id="9660" min="1" max="1" chance="25" />
					<item id="9661" min="1" max="1" chance="25" />
					<item id="9662" min="1" max="1" chance="25" />
					<item id="9663" min="1" max="1" chance="25" />
				</group>
			</drop>
		</dropLists>
		<collision>
			<radius normal="24" />
			<height normal="45" />
		</collision>
	</npc>
	<npc id="93201" level="82" type="RaidBoss" name="Phoenix Ember" title="Ashen Dynasty">
		<race>ELEMENTAL</race>
		<sex>MALE</sex>
		<acquire exp="5600000" sp="1200000" />
		<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
			<vitals hp="460000" hpRegen="140" mp="1850" mpRegen="3" />
			<attack physical="3000" magical="1050" random="40" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
			<defence physical="1180" magical="580" evasion="-18" />
			<speed>
				<walk ground="50" />
				<run ground="210" />
			</speed>
			<hitTime>450</hitTime>
		</stats>
		<status undying="false" />
		<skillList>
			<skill id="4045" level="1" />
			<skill id="4494" level="1" />
		</skillList>
		<exCrtEffect>true</exCrtEffect>
		<ai type="BALANCED" clanHelpRange="300" isAggressive="false" />
		<dropLists>
			<drop>
				<group chance="100">
					<item id="57" min="500000" max="1000000" chance="100" />
				</group>
				<group chance="100">
					<item id="9699" min="1" max="3" chance="100" />
				</group>
				<group chance="32">
					<item id="9690" min="1" max="1" chance="12" />
					<item id="9691" min="1" max="1" chance="11" />
					<item id="9692" min="1" max="1" chance="11" />
					<item id="9693" min="1" max="1" chance="11" />
					<item id="9694" min="1" max="1" chance="11" />
					<item id="9695" min="1" max="1" chance="11" />
					<item id="9696" min="1" max="1" chance="11" />
					<item id="9697" min="1" max="1" chance="11" />
					<item id="9698" min="1" max="1" chance="11" />
				</group>
			</drop>
		</dropLists>
		<collision>
			<radius normal="20" />
			<height normal="40" />
		</collision>
	</npc>
</list>
''',
)

write(
    'game/data/spawns/Ashen/AshenDkPhoenix.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list enabled="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/spawns.xsd">
	<!-- DK/Phoenix raids near Death Pass endgame camps. Respawn 48h / 24h. -->
	<spawn name="AshenDkPhoenix">
		<npc id="93200" x="66500" y="132200" z="-3720" heading="0" respawnDelay="172800" />
		<npc id="93201" x="67500" y="130800" z="-3720" heading="0" respawnDelay="86400" />
	</spawn>
</list>
''',
)

print('done')

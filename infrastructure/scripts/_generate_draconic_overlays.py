# Generator for Ashen Draconic overlays (Sprint 14). ~15% above TT.
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
\t\t<!-- Ashen Draconic (ADR-008). Client may show generic name/icon until client-patch. -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
{armor_line}\t\t<set name="bodypart" val="{bodypart}" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="900" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="SCALE_OF_DRAGON" />
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
\t\t<!-- Ashen Draconic weapon (ADR-008). -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="weapon_type" val="{wtype}" />
\t\t<set name="bodypart" val="{body}" />
\t\t<set name="damage_range" val="0;0;40;120" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="3000" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="SCALE_OF_DRAGON" />
\t\t<set name="weight" val="{weight}" />
\t\t<set name="price" val="65000000" />
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
    armor(9400, 'Ashen Draconic Helmet', 'icon.armor_helmet_i00', None, 'head', 550, 7500000, 107),
    armor(9401, 'Ashen Draconic Breastplate', 'icon.armor_t88_u_i00', 'HEAVY', 'chest', 7620, 20000000, 264),
    armor(9402, 'Ashen Draconic Gaiters', 'icon.armor_t88_l_i00', 'HEAVY', 'legs', 3260, 12500000, 164),
    armor(9403, 'Ashen Draconic Gauntlets', 'icon.armor_t88_g_i00', None, 'gloves', 540, 5000000, 71),
    armor(9404, 'Ashen Draconic Boots', 'icon.armor_t88_b_i00', None, 'feet', 1110, 5000000, 71),
    '''\t<item id="9405" type="Armor" name="Ashen Draconic Shield">
\t\t<set name="icon" val="icon.shield_imperial_crusader_shield_i00" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="bodypart" val="lhand" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="220" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="SCALE_OF_DRAGON" />
\t\t<set name="weight" val="1170" />
\t\t<set name="price" val="5200000" />
\t\t<set name="enchant_enabled" val="true" />
\t\t<conditions msgId="1518">
\t\t\t<player races="HUMAN,ELF,DARK_ELF,ORC,DWARF" />
\t\t</conditions>
\t\t<stats>
\t\t\t<stat type="rEvas">-8</stat>
\t\t\t<stat type="rShld">20</stat>
\t\t\t<stat type="sDef">374</stat>
\t\t</stats>
\t</item>''',
    armor(9430, 'Ashen Draconic Leather Helmet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 7500000, 107),
    armor(9431, 'Ashen Draconic Leather Armor', 'icon.armor_t89_ul_i00', 'LIGHT', 'onepiece', 4950, 24000000, 321),
    armor(9432, 'Ashen Draconic Leather Gloves', 'icon.armor_t89_g_i00', None, 'gloves', 540, 5000000, 71),
    armor(9433, 'Ashen Draconic Leather Boots', 'icon.armor_t89_b_i00', None, 'feet', 1110, 5000000, 71),
    armor(9460, 'Ashen Draconic Circlet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 7500000, 107),
    armor(9461, 'Ashen Draconic Robe', 'icon.armor_t90_ul_i00', 'MAGIC', 'onepiece', 2300, 24000000, 214, maxmp=1115),
    armor(9462, 'Ashen Draconic Gloves', 'icon.armor_t90_g_i00', None, 'gloves', 540, 5000000, 71),
    armor(9463, 'Ashen Draconic Shoes', 'icon.armor_t90_b_i00', None, 'feet', 1110, 5000000, 71),
    weapon(9490, 'Ashen Draconic Blade', 'icon.weapon_forgotten_blade_i00', 'SWORD', 'rhand', 362, 170, 8, 379, 10, 40, 1300),
    weapon(9491, 'Ashen Draconic Divider', 'icon.weapon_heavens_divider_i00', 'SWORD', 'lrhand', 440, 170, 8, 325, 10, 40, 1380),
    weapon(9492, 'Ashen Draconic Dual Swords', 'icon.weapon_dual_sword_i00', 'DUAL', 'lrhand', 440, 170, 8, 325, 10, 40, 2080),
    weapon(9493, 'Ashen Draconic Dagger', 'icon.weapon_angel_slayer_i00', 'DAGGER', 'rhand', 317, 170, 12, 433, 5, 40, 950),
    weapon(
        9494, 'Ashen Draconic Bow', 'icon.weapon_shining_bow_i00', 'BOW', 'lrhand', 748, 170, 12, 293, 5, 500, 1650,
        extra='\n\t\t<set name="mp_consume" val="11" />\n\t\t<set name="reuse_delay" val="820" />',
    ),
    weapon(9495, 'Ashen Draconic Hammer', 'icon.weapon_basalt_battlehammer_i00', 'BLUNT', 'rhand', 362, 170, 4, 379, 20, 40, 1570),
    weapon(
        9496, 'Ashen Draconic Spear', 'icon.weapon_saint_spear_i00', 'POLE', 'lrhand', 362, 170, 8, 325, 10, 80, 1800,
        skills='\t\t\t<skill id="3599" level="1" />',
    ),
    weapon(9497, 'Ashen Draconic Fist', 'icon.weapon_demon_splinter_i00', 'DUALFIST', 'lrhand', 440, 170, 4, 325, 5, 40, 1350),
    weapon(
        9498, 'Ashen Draconic Staff', 'icon.weapon_imperial_staff_i00', 'BLUNT', 'lrhand', 353, 248, 4, 325, 20, 40, 910,
        extra='\n\t\t<set name="is_magic_weapon" val="true" />',
    ),
    '''\t<item id="9499" type="EtcItem" name="Ashen Draconic Fragment">
\t\t<!-- Token for future Draconic craft (ADR-008). -->
\t\t<set name="icon" val="icon.etc_stone_gray_i00" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="LIQUID" />
\t\t<set name="weight" val="10" />
\t\t<set name="price" val="0" />
\t\t<set name="is_stackable" val="true" />
\t</item>''',
]

write(
    'game/data/stats/items/09400-09499.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynasty Draconic items — ADR-008 / Sprint 14 (~15% above TT) -->
{chr(10).join(items)}
</list>
''',
)

write(
    'game/data/stats/armorsets/ashen_draconic.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/armorSets.xsd">
	<!-- Element order must match armorSets.xsd: chest before head. -->
	<set id="103">
		<chest id="9401" />
		<legs id="9402" />
		<head id="9400" />
		<gloves id="9403" />
		<feet id="9404" />
		<shield id="9405" />
		<skill id="3006" level="1" />
		<str val="4" />
		<con val="3" />
	</set>
	<set id="104">
		<chest id="9431" />
		<head id="9430" />
		<gloves id="9432" />
		<feet id="9433" />
		<skill id="3006" level="1" />
		<str val="3" />
		<dex val="4" />
	</set>
	<set id="105">
		<chest id="9461" />
		<head id="9460" />
		<gloves id="9462" />
		<feet id="9463" />
		<skill id="3006" level="1" />
		<int val="4" />
		<wit val="3" />
	</set>
</list>
''',
)

write(
    'game/data/stats/npcs/93100-93199.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/npcs.xsd">
	<npc id="93100" level="82" type="RaidBoss" name="Elder of Ashen Scale" title="Ashen Dynasty">
		<parameters>
			<param name="RaidSpawnMusic" value="Rm01_A" />
		</parameters>
		<race>DRAGON</race>
		<sex>MALE</sex>
		<acquire exp="6200000" sp="1400000" />
		<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
			<vitals hp="520000" hpRegen="140" mp="1800" mpRegen="3" />
			<attack physical="2900" magical="1000" random="50" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
			<defence physical="1150" magical="560" evasion="-18" />
			<speed>
				<walk ground="50" />
				<run ground="200" />
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
					<item id="57" min="700000" max="1200000" chance="100" />
				</group>
				<group chance="100">
					<item id="9499" min="2" max="5" chance="100" />
				</group>
				<group chance="40">
					<item id="9399" min="1" max="2" chance="100" />
				</group>
				<group chance="30">
					<item id="9400" min="1" max="1" chance="16" />
					<item id="9401" min="1" max="1" chance="16" />
					<item id="9402" min="1" max="1" chance="16" />
					<item id="9403" min="1" max="1" chance="16" />
					<item id="9404" min="1" max="1" chance="16" />
					<item id="9405" min="1" max="1" chance="20" />
				</group>
				<group chance="22">
					<item id="9430" min="1" max="1" chance="25" />
					<item id="9431" min="1" max="1" chance="25" />
					<item id="9432" min="1" max="1" chance="25" />
					<item id="9433" min="1" max="1" chance="25" />
				</group>
				<group chance="22">
					<item id="9460" min="1" max="1" chance="25" />
					<item id="9461" min="1" max="1" chance="25" />
					<item id="9462" min="1" max="1" chance="25" />
					<item id="9463" min="1" max="1" chance="25" />
				</group>
			</drop>
		</dropLists>
		<collision>
			<radius normal="22" />
			<height normal="42" />
		</collision>
	</npc>
	<npc id="93101" level="80" type="RaidBoss" name="Ashen Scale Warden" title="Ashen Dynasty">
		<race>DRAGON</race>
		<sex>MALE</sex>
		<acquire exp="4500000" sp="1000000" />
		<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
			<vitals hp="380000" hpRegen="130" mp="1650" mpRegen="3" />
			<attack physical="2700" magical="950" random="40" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
			<defence physical="1050" magical="520" evasion="-18" />
			<speed>
				<walk ground="50" />
				<run ground="200" />
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
					<item id="57" min="400000" max="800000" chance="100" />
				</group>
				<group chance="100">
					<item id="9499" min="1" max="3" chance="100" />
				</group>
				<group chance="35">
					<item id="9490" min="1" max="1" chance="12" />
					<item id="9491" min="1" max="1" chance="11" />
					<item id="9492" min="1" max="1" chance="11" />
					<item id="9493" min="1" max="1" chance="11" />
					<item id="9494" min="1" max="1" chance="11" />
					<item id="9495" min="1" max="1" chance="11" />
					<item id="9496" min="1" max="1" chance="11" />
					<item id="9497" min="1" max="1" chance="11" />
					<item id="9498" min="1" max="1" chance="11" />
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
    'game/data/spawns/Ashen/AshenDraconic.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list enabled="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/spawns.xsd">
	<!-- Draconic raids near TT area / Death Pass. Respawn 36h / 18h. -->
	<spawn name="AshenDraconic">
		<npc id="93100" x="68000" y="131500" z="-3720" heading="0" respawnDelay="129600" />
		<npc id="93101" x="69500" y="129800" z="-3720" heading="0" respawnDelay="64800" />
	</spawn>
</list>
''',
)

print('done')

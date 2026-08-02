# Generator for Ashen Dynarty overlays (Sprint 22). ~15% above DK/Phoenix + +30 scrolls.
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'customization'

DYNARTY_ARMOR = [
    9700, 9701, 9702, 9703, 9704, 9705,
    9730, 9731, 9732, 9733,
    9760, 9761, 9762, 9763,
]
DYNARTY_WEAPONS = [9790, 9791, 9792, 9793, 9794, 9795, 9796, 9797, 9798]


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
\t\t<!-- Ashen Dynarty (ADR-010). Client may show generic name/icon until client-patch. -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
{armor_line}\t\t<set name="bodypart" val="{bodypart}" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="1200" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ORIHARUKON" />
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
\t\t<!-- Ashen Dynarty weapon (ADR-010). -->
\t\t<set name="icon" val="{icon}" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="weapon_type" val="{wtype}" />
\t\t<set name="bodypart" val="{body}" />
\t\t<set name="damage_range" val="0;0;40;120" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="4000" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ORIHARUKON" />
\t\t<set name="weight" val="{weight}" />
\t\t<set name="price" val="120000000" />
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
    armor(9700, 'Ashen Dynarty Helmet', 'icon.armor_helmet_i00', None, 'head', 550, 12000000, 141),
    armor(9701, 'Ashen Dynarty Breastplate', 'icon.armor_t88_u_i00', 'HEAVY', 'chest', 7620, 34000000, 350),
    armor(9702, 'Ashen Dynarty Gaiters', 'icon.armor_t88_l_i00', 'HEAVY', 'legs', 3260, 21000000, 217),
    armor(9703, 'Ashen Dynarty Gauntlets', 'icon.armor_t88_g_i00', None, 'gloves', 540, 8500000, 94),
    armor(9704, 'Ashen Dynarty Boots', 'icon.armor_t88_b_i00', None, 'feet', 1110, 8500000, 94),
    '''\t<item id="9705" type="Armor" name="Ashen Dynarty Shield">
\t\t<set name="icon" val="icon.shield_imperial_crusader_shield_i00" />
\t\t<set name="default_action" val="EQUIP" />
\t\t<set name="bodypart" val="lhand" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="crystal_count" val="300" />
\t\t<set name="crystal_type" val="S" />
\t\t<set name="material" val="ORIHARUKON" />
\t\t<set name="weight" val="1170" />
\t\t<set name="price" val="9000000" />
\t\t<set name="enchant_enabled" val="true" />
\t\t<conditions msgId="1518">
\t\t\t<player races="HUMAN,ELF,DARK_ELF,ORC,DWARF" />
\t\t</conditions>
\t\t<stats>
\t\t\t<stat type="rEvas">-8</stat>
\t\t\t<stat type="rShld">20</stat>
\t\t\t<stat type="sDef">495</stat>
\t\t</stats>
\t</item>''',
    armor(9730, 'Ashen Dynarty Leather Helmet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 12000000, 141),
    armor(9731, 'Ashen Dynarty Leather Armor', 'icon.armor_t89_ul_i00', 'LIGHT', 'onepiece', 4950, 38000000, 424),
    armor(9732, 'Ashen Dynarty Leather Gloves', 'icon.armor_t89_g_i00', None, 'gloves', 540, 8500000, 94),
    armor(9733, 'Ashen Dynarty Leather Boots', 'icon.armor_t89_b_i00', None, 'feet', 1110, 8500000, 94),
    armor(9760, 'Ashen Dynarty Circlet', 'icon.armor_leather_helmet_i00', None, 'head', 550, 12000000, 141),
    armor(9761, 'Ashen Dynarty Robe', 'icon.armor_t90_ul_i00', 'MAGIC', 'onepiece', 2300, 38000000, 283, maxmp=1474),
    armor(9762, 'Ashen Dynarty Gloves', 'icon.armor_t90_g_i00', None, 'gloves', 540, 8500000, 94),
    armor(9763, 'Ashen Dynarty Shoes', 'icon.armor_t90_b_i00', None, 'feet', 1110, 8500000, 94),
    weapon(9790, 'Ashen Dynarty Blade', 'icon.weapon_forgotten_blade_i00', 'SWORD', 'rhand', 478, 225, 8, 379, 10, 40, 1300),
    weapon(9791, 'Ashen Dynarty Divider', 'icon.weapon_heavens_divider_i00', 'SWORD', 'lrhand', 582, 225, 8, 325, 10, 40, 1380),
    weapon(9792, 'Ashen Dynarty Dual Swords', 'icon.weapon_dual_sword_i00', 'DUAL', 'lrhand', 582, 225, 8, 325, 10, 40, 2080),
    weapon(9793, 'Ashen Dynarty Dagger', 'icon.weapon_angel_slayer_i00', 'DAGGER', 'rhand', 420, 225, 12, 433, 5, 40, 950),
    weapon(
        9794, 'Ashen Dynarty Bow', 'icon.weapon_shining_bow_i00', 'BOW', 'lrhand', 989, 225, 12, 293, 5, 500, 1650,
        extra='\n\t\t<set name="mp_consume" val="12" />\n\t\t<set name="reuse_delay" val="820" />',
    ),
    weapon(9795, 'Ashen Dynarty Hammer', 'icon.weapon_basalt_battlehammer_i00', 'BLUNT', 'rhand', 478, 225, 4, 379, 20, 40, 1570),
    weapon(
        9796, 'Ashen Dynarty Spear', 'icon.weapon_saint_spear_i00', 'POLE', 'lrhand', 478, 225, 8, 325, 10, 80, 1800,
        skills='\t\t\t<skill id="3599" level="1" />',
    ),
    weapon(9797, 'Ashen Dynarty Fist', 'icon.weapon_demon_splinter_i00', 'DUALFIST', 'lrhand', 582, 225, 4, 325, 5, 40, 1350),
    weapon(
        9798, 'Ashen Dynarty Staff', 'icon.weapon_imperial_staff_i00', 'BLUNT', 'lrhand', 467, 328, 4, 325, 20, 40, 910,
        extra='\n\t\t<set name="is_magic_weapon" val="true" />',
    ),
    '''\t<item id="9799" type="EtcItem" name="Ashen Dynarty Fragment">
\t\t<!-- Token for future Dynarty craft (ADR-010). -->
\t\t<set name="icon" val="icon.etc_stone_gray_i00" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="LIQUID" />
\t\t<set name="weight" val="10" />
\t\t<set name="price" val="0" />
\t\t<set name="is_stackable" val="true" />
\t</item>''',
    '''\t<item id="9570" type="EtcItem" name="Scroll: Enchant Ashen Dynarty Weapon">
\t\t<!-- Dynarty-only weapon scroll; max +30 (ADR-010). -->
\t\t<set name="icon" val="icon.etc_scroll_of_enchant_weapon_i05" />
\t\t<set name="default_action" val="SKILL_REDUCE" />
\t\t<set name="etcitem_type" val="SCRL_ENCHANT_WP" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="PAPER" />
\t\t<set name="weight" val="120" />
\t\t<set name="price" val="0" />
\t\t<set name="is_stackable" val="true" />
\t\t<set name="is_oly_restricted" val="true" />
\t\t<set name="handler" val="EnchantScrolls" />
\t\t<skills>
\t\t\t<skill id="2021" level="1" />
\t\t</skills>
\t</item>''',
    '''\t<item id="9571" type="EtcItem" name="Scroll: Enchant Ashen Dynarty Armor">
\t\t<!-- Dynarty-only armor scroll; max +30 (ADR-010). -->
\t\t<set name="icon" val="icon.etc_scroll_of_enchant_armor_i05" />
\t\t<set name="default_action" val="SKILL_REDUCE" />
\t\t<set name="etcitem_type" val="SCRL_ENCHANT_AM" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="PAPER" />
\t\t<set name="weight" val="120" />
\t\t<set name="price" val="0" />
\t\t<set name="is_stackable" val="true" />
\t\t<set name="is_oly_restricted" val="true" />
\t\t<set name="handler" val="EnchantScrolls" />
\t\t<skills>
\t\t\t<skill id="2022" level="1" />
\t\t</skills>
\t</item>''',
]

write(
    'game/data/stats/items/09700-09799.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynasty Dynarty items — ADR-010 / Sprint 22 (~15% above DK) -->
{chr(10).join(items[:-2])}
</list>
''',
)

# Scrolls live in 09500 file gap — separate small file 09570-09579 to avoid regenerating craft file
write(
    'game/data/stats/items/09570-09579.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynarty enchant scrolls — ADR-010 / Sprint 22 -->
{chr(10).join(items[-2:])}
</list>
''',
)

write(
    'game/data/stats/armorsets/ashen_dynarty.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/armorSets.xsd">
	<set id="109">
		<chest id="9701" />
		<legs id="9702" />
		<head id="9700" />
		<gloves id="9703" />
		<feet id="9704" />
		<shield id="9705" />
		<skill id="3006" level="1" />
		<str val="6" />
		<con val="3" />
	</set>
	<set id="110">
		<chest id="9731" />
		<head id="9730" />
		<gloves id="9732" />
		<feet id="9733" />
		<skill id="3006" level="1" />
		<str val="3" />
		<dex val="6" />
	</set>
	<set id="111">
		<chest id="9761" />
		<head id="9760" />
		<gloves id="9762" />
		<feet id="9763" />
		<skill id="3006" level="1" />
		<int val="6" />
		<wit val="3" />
	</set>
</list>
''',
)

weapon_items_xml = '\n'.join(f'\t\t<item id="{i}" />' for i in DYNARTY_WEAPONS)
armor_items_xml = '\n'.join(f'\t\t<item id="{i}" />' for i in DYNARTY_ARMOR)

write(
    'game/data/EnchantItemData.ashen.fragment.xml',
    f'''\t<!-- BEGIN ASHEN DYNASTY ENCHANT -->
\t<!-- Sprint 22: Dynarty-only scrolls max +30. Listing items blocks retail S scrolls on Dynarty. -->
\t<enchant id="9570" targetGrade="S" maxEnchant="30" scrollGroupId="1">
{weapon_items_xml}
\t</enchant>
\t<enchant id="9571" targetGrade="S" maxEnchant="30" scrollGroupId="1">
{armor_items_xml}
\t</enchant>
\t<!-- END ASHEN DYNASTY ENCHANT -->
''',
)

write(
    'game/data/EnchantItemGroups.ashen.fragment.xml',
    '''\t<!-- BEGIN ASHEN DYNASTY ENCHANT GROUPS -->
\t<!-- Raising chance>0 to 29 also raises OverEnchantProtection ceiling to 30 globally;
\t     retail enchant remains capped by EnchantItemData maxEnchant=16 on retail scrolls. -->
\t<enchantRateGroup name="DYNARTY_ARMOR_GROUP">
\t\t<current enchant="0-2" chance="100" />
\t\t<current enchant="3-15" chance="66" />
\t\t<current enchant="16-20" chance="40" />
\t\t<current enchant="21-25" chance="25" />
\t\t<current enchant="26-29" chance="15" />
\t\t<current enchant="30-65535" chance="0" />
\t</enchantRateGroup>
\t<enchantRateGroup name="DYNARTY_FULL_ARMOR_GROUP">
\t\t<current enchant="0-3" chance="100" />
\t\t<current enchant="4-15" chance="66" />
\t\t<current enchant="16-20" chance="40" />
\t\t<current enchant="21-25" chance="25" />
\t\t<current enchant="26-29" chance="15" />
\t\t<current enchant="30-65535" chance="0" />
\t</enchantRateGroup>
\t<enchantRateGroup name="DYNARTY_FIGHTER_WEAPON_GROUP">
\t\t<current enchant="0-2" chance="100" />
\t\t<current enchant="3-15" chance="66" />
\t\t<current enchant="16-20" chance="40" />
\t\t<current enchant="21-25" chance="25" />
\t\t<current enchant="26-29" chance="15" />
\t\t<current enchant="30-65535" chance="0" />
\t</enchantRateGroup>
\t<enchantRateGroup name="DYNARTY_MAGE_WEAPON_GROUP">
\t\t<current enchant="0-2" chance="100" />
\t\t<current enchant="3-15" chance="66" />
\t\t<current enchant="16-20" chance="40" />
\t\t<current enchant="21-25" chance="25" />
\t\t<current enchant="26-29" chance="15" />
\t\t<current enchant="30-65535" chance="0" />
\t</enchantRateGroup>
\t<enchantScrollGroup id="1">
\t\t<enchantRate group="DYNARTY_ARMOR_GROUP">
\t\t\t<item slot="lhand" />
\t\t\t<item slot="head" />
\t\t\t<item slot="chest" />
\t\t\t<item slot="legs" />
\t\t\t<item slot="feet" />
\t\t\t<item slot="gloves" />
\t\t</enchantRate>
\t\t<enchantRate group="DYNARTY_FULL_ARMOR_GROUP">
\t\t\t<item slot="fullarmor" />
\t\t</enchantRate>
\t\t<enchantRate group="DYNARTY_FIGHTER_WEAPON_GROUP">
\t\t\t<item slot="rhand" magicWeapon="false" />
\t\t\t<item slot="lrhand" magicWeapon="false" />
\t\t</enchantRate>
\t\t<enchantRate group="DYNARTY_MAGE_WEAPON_GROUP">
\t\t\t<item slot="rhand" magicWeapon="true" />
\t\t\t<item slot="lrhand" magicWeapon="true" />
\t\t</enchantRate>
\t</enchantScrollGroup>
\t<!-- END ASHEN DYNASTY ENCHANT GROUPS -->
''',
)

write(
    'game/data/stats/npcs/93300-93399.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/npcs.xsd">
	<npc id="93300" level="85" type="RaidBoss" name="Ashen Dynasty Lord" title="Ashen Dynasty">
		<parameters>
			<param name="RaidSpawnMusic" value="Rm01_A" />
		</parameters>
		<race>DIVINE</race>
		<sex>MALE</sex>
		<acquire exp="9500000" sp="2100000" />
		<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
			<vitals hp="780000" hpRegen="160" mp="2200" mpRegen="3" />
			<attack physical="3600" magical="1250" random="50" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
			<defence physical="1420" magical="700" evasion="-18" />
			<speed>
				<walk ground="50" />
				<run ground="220" />
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
					<item id="57" min="1200000" max="2000000" chance="100" />
				</group>
				<group chance="100">
					<item id="9799" min="2" max="5" chance="100" />
				</group>
				<group chance="100">
					<item id="9571" min="1" max="2" chance="100" />
				</group>
				<group chance="35">
					<item id="9699" min="1" max="2" chance="100" />
				</group>
				<group chance="25">
					<item id="9700" min="1" max="1" chance="16" />
					<item id="9701" min="1" max="1" chance="16" />
					<item id="9702" min="1" max="1" chance="16" />
					<item id="9703" min="1" max="1" chance="16" />
					<item id="9704" min="1" max="1" chance="16" />
					<item id="9705" min="1" max="1" chance="20" />
				</group>
				<group chance="18">
					<item id="9730" min="1" max="1" chance="25" />
					<item id="9731" min="1" max="1" chance="25" />
					<item id="9732" min="1" max="1" chance="25" />
					<item id="9733" min="1" max="1" chance="25" />
				</group>
				<group chance="18">
					<item id="9760" min="1" max="1" chance="25" />
					<item id="9761" min="1" max="1" chance="25" />
					<item id="9762" min="1" max="1" chance="25" />
					<item id="9763" min="1" max="1" chance="25" />
				</group>
			</drop>
		</dropLists>
		<collision>
			<radius normal="26" />
			<height normal="48" />
		</collision>
	</npc>
	<npc id="93301" level="84" type="RaidBoss" name="Ashen Dynasty Blade" title="Ashen Dynasty">
		<race>DIVINE</race>
		<sex>MALE</sex>
		<acquire exp="7000000" sp="1500000" />
		<stats str="60" int="76" dex="73" wit="70" con="57" men="80">
			<vitals hp="560000" hpRegen="150" mp="2000" mpRegen="3" />
			<attack physical="3400" magical="1200" random="40" critical="4" accuracy="9" attackSpeed="253" type="SWORD" range="40" distance="80" width="120" />
			<defence physical="1320" magical="650" evasion="-18" />
			<speed>
				<walk ground="50" />
				<run ground="220" />
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
					<item id="57" min="700000" max="1200000" chance="100" />
				</group>
				<group chance="100">
					<item id="9799" min="1" max="3" chance="100" />
				</group>
				<group chance="100">
					<item id="9570" min="1" max="2" chance="100" />
				</group>
				<group chance="30">
					<item id="9790" min="1" max="1" chance="12" />
					<item id="9791" min="1" max="1" chance="11" />
					<item id="9792" min="1" max="1" chance="11" />
					<item id="9793" min="1" max="1" chance="11" />
					<item id="9794" min="1" max="1" chance="11" />
					<item id="9795" min="1" max="1" chance="11" />
					<item id="9796" min="1" max="1" chance="11" />
					<item id="9797" min="1" max="1" chance="11" />
					<item id="9798" min="1" max="1" chance="11" />
				</group>
			</drop>
		</dropLists>
		<collision>
			<radius normal="22" />
			<height normal="42" />
		</collision>
	</npc>
</list>
''',
)

write(
    'game/data/spawns/Ashen/AshenDynarty.xml',
    '''<?xml version="1.0" encoding="UTF-8"?>
<list enabled="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/spawns.xsd">
	<!-- Dynarty raids near Death Pass apex. Respawn 72h / 36h. -->
	<spawn name="AshenDynarty">
		<npc id="93300" x="65000" y="133000" z="-3720" heading="0" respawnDelay="259200" />
		<npc id="93301" x="66000" y="131500" z="-3720" heading="0" respawnDelay="129600" />
	</spawn>
</list>
''',
)

print('done')

# Generator for Ashen TT/Draconic/DK/Dynarty craft recipes (Sprint 15/19/23).
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ROOT = REPO / 'infrastructure' / 'customization'
DOCS = REPO / 'docs' / 'design'
CRYSTAL_S = 1462  # Crystal: S-Grade


def write(rel: str, text: str) -> None:
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.lstrip('\n'), encoding='utf-8', newline='\n')
    print('wrote', path.relative_to(ROOT))


# (product_id, name, tier, kind)
# tier: 'tt' | 'draconic' | 'dk' | 'dynarty'; kind: 'minor' | 'major' | 'weapon' | 'shield'
PRODUCTS = [
    (9300, 'Ashen TT Helmet', 'tt', 'minor'),
    (9301, 'Ashen TT Breastplate', 'tt', 'major'),
    (9302, 'Ashen TT Gaiters', 'tt', 'major'),
    (9303, 'Ashen TT Gauntlets', 'tt', 'minor'),
    (9304, 'Ashen TT Boots', 'tt', 'minor'),
    (9305, 'Ashen TT Shield', 'tt', 'shield'),
    (9330, 'Ashen TT Leather Helmet', 'tt', 'minor'),
    (9331, 'Ashen TT Leather Armor', 'tt', 'major'),
    (9332, 'Ashen TT Leather Gloves', 'tt', 'minor'),
    (9333, 'Ashen TT Leather Boots', 'tt', 'minor'),
    (9360, 'Ashen TT Circlet', 'tt', 'minor'),
    (9361, 'Ashen TT Robe', 'tt', 'major'),
    (9362, 'Ashen TT Gloves', 'tt', 'minor'),
    (9363, 'Ashen TT Shoes', 'tt', 'minor'),
    (9390, 'Ashen TT Blade', 'tt', 'weapon'),
    (9391, 'Ashen TT Divider', 'tt', 'weapon'),
    (9392, 'Ashen TT Dual Swords', 'tt', 'weapon'),
    (9393, 'Ashen TT Dagger', 'tt', 'weapon'),
    (9394, 'Ashen TT Bow', 'tt', 'weapon'),
    (9395, 'Ashen TT Hammer', 'tt', 'weapon'),
    (9396, 'Ashen TT Spear', 'tt', 'weapon'),
    (9397, 'Ashen TT Fist', 'tt', 'weapon'),
    (9398, 'Ashen TT Staff', 'tt', 'weapon'),
    (9400, 'Ashen Draconic Helmet', 'draconic', 'minor'),
    (9401, 'Ashen Draconic Breastplate', 'draconic', 'major'),
    (9402, 'Ashen Draconic Gaiters', 'draconic', 'major'),
    (9403, 'Ashen Draconic Gauntlets', 'draconic', 'minor'),
    (9404, 'Ashen Draconic Boots', 'draconic', 'minor'),
    (9405, 'Ashen Draconic Shield', 'draconic', 'shield'),
    (9430, 'Ashen Draconic Leather Helmet', 'draconic', 'minor'),
    (9431, 'Ashen Draconic Leather Armor', 'draconic', 'major'),
    (9432, 'Ashen Draconic Leather Gloves', 'draconic', 'minor'),
    (9433, 'Ashen Draconic Leather Boots', 'draconic', 'minor'),
    (9460, 'Ashen Draconic Circlet', 'draconic', 'minor'),
    (9461, 'Ashen Draconic Robe', 'draconic', 'major'),
    (9462, 'Ashen Draconic Gloves', 'draconic', 'minor'),
    (9463, 'Ashen Draconic Shoes', 'draconic', 'minor'),
    (9490, 'Ashen Draconic Blade', 'draconic', 'weapon'),
    (9491, 'Ashen Draconic Divider', 'draconic', 'weapon'),
    (9492, 'Ashen Draconic Dual Swords', 'draconic', 'weapon'),
    (9493, 'Ashen Draconic Dagger', 'draconic', 'weapon'),
    (9494, 'Ashen Draconic Bow', 'draconic', 'weapon'),
    (9495, 'Ashen Draconic Hammer', 'draconic', 'weapon'),
    (9496, 'Ashen Draconic Spear', 'draconic', 'weapon'),
    (9497, 'Ashen Draconic Fist', 'draconic', 'weapon'),
    (9498, 'Ashen Draconic Staff', 'draconic', 'weapon'),
    # Sprint 19 — DK armor / Phoenix weapons
    (9600, 'Ashen DK Helmet', 'dk', 'minor'),
    (9601, 'Ashen DK Breastplate', 'dk', 'major'),
    (9602, 'Ashen DK Gaiters', 'dk', 'major'),
    (9603, 'Ashen DK Gauntlets', 'dk', 'minor'),
    (9604, 'Ashen DK Boots', 'dk', 'minor'),
    (9605, 'Ashen DK Shield', 'dk', 'shield'),
    (9630, 'Ashen DK Leather Helmet', 'dk', 'minor'),
    (9631, 'Ashen DK Leather Armor', 'dk', 'major'),
    (9632, 'Ashen DK Leather Gloves', 'dk', 'minor'),
    (9633, 'Ashen DK Leather Boots', 'dk', 'minor'),
    (9660, 'Ashen DK Circlet', 'dk', 'minor'),
    (9661, 'Ashen DK Robe', 'dk', 'major'),
    (9662, 'Ashen DK Gloves', 'dk', 'minor'),
    (9663, 'Ashen DK Shoes', 'dk', 'minor'),
    (9690, 'Ashen Phoenix Blade', 'dk', 'weapon'),
    (9691, 'Ashen Phoenix Divider', 'dk', 'weapon'),
    (9692, 'Ashen Phoenix Dual Swords', 'dk', 'weapon'),
    (9693, 'Ashen Phoenix Dagger', 'dk', 'weapon'),
    (9694, 'Ashen Phoenix Bow', 'dk', 'weapon'),
    (9695, 'Ashen Phoenix Hammer', 'dk', 'weapon'),
    (9696, 'Ashen Phoenix Spear', 'dk', 'weapon'),
    (9697, 'Ashen Phoenix Fist', 'dk', 'weapon'),
    (9698, 'Ashen Phoenix Staff', 'dk', 'weapon'),
    # Sprint 23 — Dynarty (scroll IDs skip 9569-9571: gap + enchant scrolls)
    (9700, 'Ashen Dynarty Helmet', 'dynarty', 'minor'),
    (9701, 'Ashen Dynarty Breastplate', 'dynarty', 'major'),
    (9702, 'Ashen Dynarty Gaiters', 'dynarty', 'major'),
    (9703, 'Ashen Dynarty Gauntlets', 'dynarty', 'minor'),
    (9704, 'Ashen Dynarty Boots', 'dynarty', 'minor'),
    (9705, 'Ashen Dynarty Shield', 'dynarty', 'shield'),
    (9730, 'Ashen Dynarty Leather Helmet', 'dynarty', 'minor'),
    (9731, 'Ashen Dynarty Leather Armor', 'dynarty', 'major'),
    (9732, 'Ashen Dynarty Leather Gloves', 'dynarty', 'minor'),
    (9733, 'Ashen Dynarty Leather Boots', 'dynarty', 'minor'),
    (9760, 'Ashen Dynarty Circlet', 'dynarty', 'minor'),
    (9761, 'Ashen Dynarty Robe', 'dynarty', 'major'),
    (9762, 'Ashen Dynarty Gloves', 'dynarty', 'minor'),
    (9763, 'Ashen Dynarty Shoes', 'dynarty', 'minor'),
    (9790, 'Ashen Dynarty Blade', 'dynarty', 'weapon'),
    (9791, 'Ashen Dynarty Divider', 'dynarty', 'weapon'),
    (9792, 'Ashen Dynarty Dual Swords', 'dynarty', 'weapon'),
    (9793, 'Ashen Dynarty Dagger', 'dynarty', 'weapon'),
    (9794, 'Ashen Dynarty Bow', 'dynarty', 'weapon'),
    (9795, 'Ashen Dynarty Hammer', 'dynarty', 'weapon'),
    (9796, 'Ashen Dynarty Spear', 'dynarty', 'weapon'),
    (9797, 'Ashen Dynarty Fist', 'dynarty', 'weapon'),
    (9798, 'Ashen Dynarty Staff', 'dynarty', 'weapon'),
]

COSTS = {
    ('tt', 'minor'): {'9399': 8, 'crystal': 20, 'mp': 80},
    ('tt', 'major'): {'9399': 15, 'crystal': 40, 'mp': 120},
    ('tt', 'shield'): {'9399': 10, 'crystal': 25, 'mp': 90},
    ('tt', 'weapon'): {'9399': 25, 'crystal': 50, 'mp': 150},
    ('draconic', 'minor'): {'9499': 10, '9399': 5, 'crystal': 30, 'mp': 100},
    ('draconic', 'major'): {'9499': 20, '9399': 10, 'crystal': 60, 'mp': 160},
    ('draconic', 'shield'): {'9499': 12, '9399': 6, 'crystal': 35, 'mp': 110},
    ('draconic', 'weapon'): {'9499': 30, '9399': 15, 'crystal': 80, 'mp': 200},
    ('dk', 'minor'): {'9699': 12, '9499': 6, 'crystal': 40, 'mp': 120},
    ('dk', 'major'): {'9699': 25, '9499': 12, 'crystal': 80, 'mp': 200},
    ('dk', 'shield'): {'9699': 15, '9499': 8, 'crystal': 45, 'mp': 140},
    ('dk', 'weapon'): {'9699': 35, '9499': 18, 'crystal': 100, 'mp': 240},
    ('dynarty', 'minor'): {'9799': 15, '9699': 8, 'crystal': 50, 'mp': 140},
    ('dynarty', 'major'): {'9799': 30, '9699': 15, 'crystal': 100, 'mp': 240},
    ('dynarty', 'shield'): {'9799': 18, '9699': 10, 'crystal': 55, 'mp': 160},
    ('dynarty', 'weapon'): {'9799': 40, '9699': 20, 'crystal': 120, 'mp': 280},
}

FRAGMENT_ORDER = ('9799', '9699', '9499', '9399')
FIRST_LIST_ID = 872
FIRST_SCROLL_ID = 9500
# Enchant scrolls 9570/9571 live in 09570-09579.xml — skip 9569-9571 for craft scrolls.
SCROLL_SKIP_FROM = 9569
SCROLL_SKIP_COUNT = 3


def scroll_id_for_index(index: int) -> int:
    scroll_id = FIRST_SCROLL_ID + index
    if scroll_id >= SCROLL_SKIP_FROM:
        scroll_id += SCROLL_SKIP_COUNT
    return scroll_id


scroll_items = []
recipe_items = []

for index, (product_id, name, tier, kind) in enumerate(PRODUCTS):
    list_id = FIRST_LIST_ID + index
    scroll_id = scroll_id_for_index(index)
    cost = COSTS[(tier, kind)]
    slug = name.lower().replace(' ', '_').replace("'", '')

    scroll_items.append(
        f'''\t<item id="{scroll_id}" type="EtcItem" name="Recipe: {name}">
\t\t<!-- Ashen craft (Sprint 15/19/23). Common recipe; fragment sink. -->
\t\t<set name="icon" val="icon.etc_recipe_black_i00" />
\t\t<set name="default_action" val="RECIPE" />
\t\t<set name="etcitem_type" val="RECIPE" />
\t\t<set name="immediate_effect" val="true" />
\t\t<set name="material" val="PAPER" />
\t\t<set name="weight" val="30" />
\t\t<set name="price" val="0" />
\t\t<set name="recipe_id" val="{list_id}" />
\t\t<set name="is_stackable" val="true" />
\t\t<set name="handler" val="Recipes" />
\t</item>'''
    )

    ingredients = []
    for frag in FRAGMENT_ORDER:
        if frag in cost:
            ingredients.append(f'\t\t<ingredient id="{frag}" count="{cost[frag]}" />')
    ingredients.append(f'\t\t<ingredient id="{CRYSTAL_S}" count="{cost["crystal"]}" />')

    recipe_items.append(
        f'''\t<item id="{list_id}" recipeId="{scroll_id}" name="mk_{slug}" craftLevel="1" type="common" successRate="100">
{chr(10).join(ingredients)}
\t\t<production id="{product_id}" count="1" />
\t\t<statUse name="MP" value="{cost['mp']}" />
\t</item>'''
    )

last_list = FIRST_LIST_ID + len(PRODUCTS) - 1
last_scroll = scroll_id_for_index(len(PRODUCTS) - 1)
if last_scroll >= 9600 or last_scroll in (9570, 9571):
    raise SystemExit(f'Scroll IDs collide with reserved range: last scroll {last_scroll}')

write(
    'game/data/stats/items/09500-09599.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynasty craft recipe scrolls — Sprint 15/19/23 (IDs 9500-{last_scroll}, skip 9569-9571) -->
{chr(10).join(scroll_items)}
</list>
''',
)

write(
    'game/data/Recipes.ashen.fragment.xml',
    f'''\t<!-- BEGIN ASHEN DYNASTY RECIPES -->
\t<!-- Sprint 15/19/23: fragment sink TT/Draconic/DK/Dynarty. Regenerate via _generate_ashen_craft_overlays.py -->
{chr(10).join(recipe_items)}
\t<!-- END ASHEN DYNASTY RECIPES -->
''',
)

rows = ['| ListId | Scroll | Produz | Nome |', '|---|---|---|---|']
for index, (product_id, name, _, _) in enumerate(PRODUCTS):
    rows.append(f'| {FIRST_LIST_ID + index} | {scroll_id_for_index(index)} | {product_id} | {name} |')
docs_path = DOCS / 'ASHEN_CRAFT_IDS.md'
docs_path.parent.mkdir(parents=True, exist_ok=True)
docs_path.write_text(
    '# Ashen craft — mapa de IDs (Sprint 15 + 19 + 23)\n\n'
    'Recipes `common` craftLevel 1 / 100%.\n'
    'Fragmentos: TT `9399`, Draconic `9499`, DK `9699`, Dynarty `9799` (+ Crystal S `1462`).\n'
    'Scrolls de craft pulam `9569–9571` (gap + scrolls de enchant Dynarty).\n\n'
    + '\n'.join(rows)
    + '\n',
    encoding='utf-8',
    newline='\n',
)
print('wrote', docs_path.relative_to(REPO))
print(f'done: {len(PRODUCTS)} recipes (list {FIRST_LIST_ID}-{last_list}, scrolls {FIRST_SCROLL_ID}-{last_scroll}, skip 9569-9571)')

# Generator for Ashen TT/Draconic craft recipes (Sprint 15). Fragment sink.
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


# (product_id, name_suffix, tier, kind)
# tier: 'tt' | 'draconic'; kind: 'minor' | 'major' | 'weapon' | 'shield'
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
}

FIRST_LIST_ID = 872
FIRST_SCROLL_ID = 9500

scroll_items = []
recipe_items = []

for index, (product_id, name, tier, kind) in enumerate(PRODUCTS):
    list_id = FIRST_LIST_ID + index
    scroll_id = FIRST_SCROLL_ID + index
    cost = COSTS[(tier, kind)]
    slug = name.lower().replace(' ', '_').replace("'", '')

    scroll_items.append(
        f'''\t<item id="{scroll_id}" type="EtcItem" name="Recipe: {name}">
\t\t<!-- Ashen craft (Sprint 15). Common recipe; fragment sink TT/Draconic. -->
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
    if '9499' in cost:
        ingredients.append(f'\t\t<ingredient id="9499" count="{cost["9499"]}" />')
    if '9399' in cost:
        ingredients.append(f'\t\t<ingredient id="9399" count="{cost["9399"]}" />')
    ingredients.append(f'\t\t<ingredient id="{CRYSTAL_S}" count="{cost["crystal"]}" />')

    recipe_items.append(
        f'''\t<item id="{list_id}" recipeId="{scroll_id}" name="mk_{slug}" craftLevel="1" type="common" successRate="100">
{chr(10).join(ingredients)}
\t\t<production id="{product_id}" count="1" />
\t\t<statUse name="MP" value="{cost['mp']}" />
\t</item>'''
    )

write(
    'game/data/stats/items/09500-09599.xml',
    f'''<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../xsd/items.xsd">
\t<!-- Ashen Dynasty craft recipe scrolls — Sprint 15 (IDs 9500+) -->
{chr(10).join(scroll_items)}
</list>
''',
)

write(
    'game/data/Recipes.ashen.fragment.xml',
    f'''\t<!-- BEGIN ASHEN DYNASTY RECIPES -->
\t<!-- Sprint 15: fragment sink for TT (9399) and Draconic (9499 + 9399). Do not edit by hand; regenerate via _generate_ashen_craft_overlays.py -->
{chr(10).join(recipe_items)}
\t<!-- END ASHEN DYNASTY RECIPES -->
''',
)

# ID map for docs
rows = ['| ListId | Scroll | Produz | Nome |', '|---|---|---|---|']
for index, (product_id, name, _, _) in enumerate(PRODUCTS):
    rows.append(f'| {FIRST_LIST_ID + index} | {FIRST_SCROLL_ID + index} | {product_id} | {name} |')
docs_path = DOCS / 'ASHEN_CRAFT_IDS.md'
docs_path.parent.mkdir(parents=True, exist_ok=True)
docs_path.write_text(
    '# Ashen craft — mapa de IDs (Sprint 15)\n\n'
    'Recipes `common` craftLevel 1 / 100%. Fragmentos TT `9399` e Draconic `9499`.\n\n'
    + '\n'.join(rows)
    + '\n',
    encoding='utf-8',
    newline='\n',
)
print('wrote', docs_path.relative_to(REPO))

print(f'done: {len(PRODUCTS)} recipes (list {FIRST_LIST_ID}-{FIRST_LIST_ID + len(PRODUCTS) - 1}, scrolls {FIRST_SCROLL_ID}-{FIRST_SCROLL_ID + len(PRODUCTS) - 1})')

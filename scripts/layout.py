#!/usr/bin/env python3

import json

XKB_PREFIX = '''
hidden partial alphanumeric_keys
xkb_symbols "enthium" {
    key <AE01> {[          1,      exclam  ]};
    key <AE02> {[          2,    quotedbl  ]};
    key <AE03> {[          3,  numbersign  ]};
    key <AE04> {[          4,    asterisk  ]};
    key <AE05> {[          5,       colon  ]};
    key <AE06> {[          6,       comma  ]};
    key <AE07> {[          7,      period  ]};
    key <AE08> {[          8,   semicolon  ]};
    key <AE09> {[          9,   parenleft  ]};
    key <AE10> {[          0,  parenright  ]};
    key <BKSL> {[  backslash,         bar  ]};

    key <LSGT> {[      slash,         bar  ]};

    key <TLDE> {[       Cyrillic_io,       Cyrillic_IO  ]}; // ` -> ё
'''

XKB_SUFFIX = '''
    include "kpdl(comma)"
};
'''

VENDOR_ID = 18003
PRODUCT_ID = 1

qwerty_rows = {
    'AE':'1234567890-=',
    'AD':'qwertyuiop[]',
    'AC':'asdfghjkl;\'',
    'AB':'zxcvbnm,./',
}

qwerty_codemap = dict([
    (key, f'{prefix}{code:02d}')
    for (prefix, keys) in qwerty_rows.items()
    for (code, key) in enumerate(keys, start=1)
] + [('\\','LSGT'), ('`','TILDE')])

xkb_ru_codes = {
    'ё': ('Cyrillic_io', 'Cyrillic_IO'),
    'й': ('Cyrillic_shorti','Cyrillic_SHORTI'),
    'ц': ('Cyrillic_tse','Cyrillic_TSE'),
    'у': ('Cyrillic_u','Cyrillic_U'),
    'к': ('Cyrillic_ka','Cyrillic_KA'),
    'е': ('Cyrillic_ie','Cyrillic_IE'),
    'н': ('Cyrillic_en','Cyrillic_EN'),
    'г': ('Cyrillic_ghe','Cyrillic_GHE'),
    'ш': ('Cyrillic_sha','Cyrillic_SHA'),
    'щ': ('Cyrillic_shcha','Cyrillic_SHCHA'),
    'з': ('Cyrillic_ze','Cyrillic_ZE'),
    'х': ('Cyrillic_ha','Cyrillic_HA'),
    'ъ': ('Cyrillic_hardsign','Cyrillic_HARDSIGN'),

    'ф': ('Cyrillic_ef','Cyrillic_EF'),
    'ы': ('Cyrillic_yeru','Cyrillic_YERU'),
    'в': ('Cyrillic_ve','Cyrillic_VE'),
    'а': ('Cyrillic_a','Cyrillic_A'),
    'п': ('Cyrillic_pe','Cyrillic_PE'),
    'р': ('Cyrillic_er','Cyrillic_ER'),
    'о': ('Cyrillic_o','Cyrillic_O'),
    'л': ('Cyrillic_el','Cyrillic_EL'),
    'д': ('Cyrillic_de','Cyrillic_DE'),
    'ж': ('Cyrillic_zhe','Cyrillic_ZHE'),
    'э': ('Cyrillic_e','Cyrillic_E'),

    'я': ('Cyrillic_ya','Cyrillic_YA'),
    'ч': ('Cyrillic_che','Cyrillic_CHE'),
    'с': ('Cyrillic_es','Cyrillic_ES'),
    'м': ('Cyrillic_em','Cyrillic_EM'),
    'и': ('Cyrillic_i','Cyrillic_I'),
    'т': ('Cyrillic_te','Cyrillic_TE'),
    'ь': ('Cyrillic_softsign','Cyrillic_SOFTSIGN'),
    'б': ('Cyrillic_be','Cyrillic_BE'),
    'ю': ('Cyrillic_yu','Cyrillic_YU'),
    '.': ('period','comma'),
}

qwerty_keymap = ['qwertyuiop[]','asdfghjkl;\'','zxcvbnm,./']
ru_keymap     = ['йцукенгшщзхъ','фывапролджэ','ячсмитьбю.']
enth_keymap   = ['qyou=xldpz[]','ciae-khtnsw','\',./;jmgfv']

enth_qwerty_remap = dict([
    (enth, qwerty)
    for (enth_row, qwerty_row) in zip(enth_keymap, qwerty_keymap)
    for (enth, qwerty) in zip(enth_row, qwerty_row)
    if enth !='@'
])

enth_ru_remap = [
    (enth, enth_qwerty_remap[enth], qwerty_codemap[enth], ru, xkb_ru_codes[ru])
    for (enth_row, ru_row) in zip(enth_keymap, ru_keymap)
    for (enth, ru) in zip(enth_row, ru_row)
    if enth !='@'
]

karabiner_special = {
    '=': 'equal_sign',
    '-': 'hyphen',
    ';': 'semicolon',
    '\'': 'quote',
    ',': 'comma',
    '.': 'period',
    '/': 'slash',
    '[': 'open_bracket',
    ']': 'close_bracket',
}

xkb = XKB_PREFIX.strip() + '\n'
karabiner = { 'description': 'Enthium Cyrillic remap', 'manipulators': [] }

for (enth, qwerty, code, ru, (lower, upper)) in enth_ru_remap:
    xkb += f'    key <{code}> {'{'}[ {lower:>17}, {upper:>17}  ]{'}'}; // {enth} -> {ru}\n'

    enth_k = karabiner_special.get(enth, enth)
    qwerty_k = karabiner_special.get(qwerty, qwerty)

    if qwerty == '/':
        continue

    karabiner['manipulators'].append({
        'type': 'basic',
        'conditions': [
            {
                'type': 'device_if',
                'identifiers': [ {'vendor_id': VENDOR_ID, 'product_id': PRODUCT_ID} ],
            },
            {
                'type': 'input_source_if',
                'input_sources': [ {'language': 'ru' } ],
            },
        ],
        'from': {'key_code': enth_k, 'modifiers': {'optional': ['shift']}},
        'to': [{'key_code': qwerty_k}],
    })

karabiner['manipulators'].append({
    'type': 'basic',
    'conditions': [
        {
            'type': 'device_if',
            'identifiers': [ {'vendor_id': VENDOR_ID, 'product_id': PRODUCT_ID} ],
        },
        {
            'type': 'input_source_if',
            'input_sources': [ {'language': 'ru' } ],
        },
    ],
    'from': {'key_code': 'v', 'modifiers': {}},
    'to': [ { 'key_code': '7', 'modifiers': ['shift'] } ],
})

karabiner['manipulators'].append({
    'type': 'basic',
    'conditions': [
        {
            'type': 'device_if',
            'identifiers': [ {'vendor_id': VENDOR_ID, 'product_id': PRODUCT_ID} ],
        },
        {
            'type': 'input_source_if',
            'input_sources': [ {'language': 'ru' } ],
        },
    ],
    'from': {'key_code': 'v', 'modifiers': {'mandatory': ['shift']}},
    'to': [ { 'key_code': '6', 'modifiers': ['shift'] } ],
})

xkb += XKB_SUFFIX
karabiner_json = json.dumps(karabiner, indent=2)

with open('modules/linux/data/ru_enthium', 'w') as f:
    f.write(xkb)

with open('modules/linux/data/ru_enthium.json', 'w') as f:
    f.write(karabiner_json)

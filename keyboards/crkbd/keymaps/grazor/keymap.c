/*
Copyright 2019 @foostan
Copyright 2020 Drashna Jaelre <@drashna>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include QMK_KEYBOARD_H

#include "bongocat.h"
#include "raw_hid.h"

enum keycodes {
    LT_SYMMD = SAFE_RANGE,
    MACRO_ESC_L1,
    LANG_EN,
    LANG_RU,
};

enum layers {
    _BASE_ENTHIUM,
    _RU,
    _SYMBOL,
    _NUMBER,
    _COMMAND,
};

enum combos {
    _COMBO_HT_ESC,
    _COMBO_HTN_ESC_L1,
    _COMBO_LAYOUT1,
    _COMBO_LAYOUT2,
};

enum tapdance {
    _TD_LRBRAC,
};


// Aliases
#define LT_RCMD LT(_COMMAND, KC_R)
#define LT_NUM  MO(_NUMBER)

// Left-hand home row mods
#define HRM_GC LGUI_T(KC_C)
#define HRM_AI LALT_T(KC_I)
#define HRM_CA LCTL_T(KC_A)
#define HRM_SE LSFT_T(KC_E)

// Right-hand home row mods
#define HRM_SH RSFT_T(KC_H)
#define HRM_CT RCTL_T(KC_T)
#define HRM_AN LALT_T(KC_N)
#define HRM_GS RGUI_T(KC_S)

// Home row mods on the RU (QWERTY-position) layer, same mods per finger
#define RU_GA LGUI_T(KC_A)
#define RU_AS LALT_T(KC_S)
#define RU_CD LCTL_T(KC_D)
#define RU_SF LSFT_T(KC_F)
#define RU_SJ RSFT_T(KC_J)
#define RU_CK RCTL_T(KC_K)
#define RU_AL LALT_T(KC_L)
#define RU_GS RGUI_T(KC_SCLN)

#define KC_STAB LSFT(KC_TAB)

// OS layout keys: Caps selects en, Shift+Caps selects ru
#define OS_EN KC_CAPS
#define OS_RU S(KC_CAPS)

// Combos
const uint16_t PROGMEM ht_esc[] = {HRM_SH, HRM_CT, COMBO_END};
const uint16_t PROGMEM htn_esc_l1[] = {HRM_SH, HRM_CT, HRM_AN, COMBO_END};
const uint16_t PROGMEM um_layout1[] = {KC_U, KC_MINS, COMBO_END};
const uint16_t PROGMEM lk_layout2[] = {KC_L, KC_K, COMBO_END};

combo_t key_combos[] = {
    [_COMBO_HT_ESC] = COMBO(ht_esc, KC_ESC),
    [_COMBO_HTN_ESC_L1] = COMBO(htn_esc_l1, MACRO_ESC_L1),
    [_COMBO_LAYOUT1] = COMBO(um_layout1, LANG_EN),
    [_COMBO_LAYOUT2] = COMBO(lk_layout2, LANG_RU),
};

// Combos are defined with Enthium keycodes; keep them positional on the RU layer
uint8_t combo_ref_from_layer(uint8_t layer) {
    return layer == _RU ? _BASE_ENTHIUM : layer;
}

// Tap dance
tap_dance_action_t tap_dance_actions[] = {
    [_TD_LRBRAC] = ACTION_TAP_DANCE_DOUBLE(KC_LBRC, KC_RBRC),
};

# define TD_BRCS TD(_TD_LRBRAC)


/*
  q y o u = x l d p z
b c i a e - k h t n s w
  ' , . ; / j m g f v
            r
*/

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_BASE_ENTHIUM] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_GRV,    KC_Q,    KC_Y,    KC_O,    KC_U,  KC_EQL,                         KC_X,    KC_L,    KC_D,    KC_P,   KC_Z,  TD_BRCS,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
         KC_B,  HRM_GC,  HRM_AI,  HRM_CA,  HRM_SE, KC_MINS,                         KC_K,  HRM_SH,  HRM_CT,  HRM_AN,  HRM_GS,    KC_W,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
       KC_TAB, KC_QUOT, KC_COMM,  KC_DOT, KC_SLSH, KC_SCLN,                         KC_J,    KC_M,    KC_G,    KC_F,    KC_V, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                           KC_ENT,  LT_NUM,  KC_SPC,    LT_RCMD,LT_SYMMD, KC_BSPC
                                      //`--------------------------'  `--------------------------'
  ),

    // QWERTY positions, which the OS Russian layout turns into ЙЦУКЕН.
    // Transparent keys keep their Enthium keycode (ё, х/ъ, Tab, thumbs).
    [_RU] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      _______,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                         KC_Y,    KC_U,    KC_I,    KC_O,    KC_P, _______,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      _______,   RU_GA,   RU_AS,   RU_CD,   RU_SF,    KC_G,                         KC_H,   RU_SJ,   RU_CK,   RU_AL,   RU_GS, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      _______,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, _______,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,    _______, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),

    [_SYMBOL] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      KC_EXLM, KC_LBRC, KC_LPRN, KC_RPRN, KC_RBRC, KC_PERC,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_HASH, KC_CIRC, KC_LCBR, KC_RCBR,  KC_DLR, KC_ASTR,                      XXXXXXX, KC_BSLS, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_AMPR,   KC_LT, KC_PIPE, KC_MINS,   KC_GT,   KC_AT,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, XXXXXXX, _______,    XXXXXXX, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),

    [_NUMBER] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      XXXXXXX,    KC_1,    KC_2,    KC_3,    KC_4,    KC_5,                         KC_6,    KC_7,    KC_8,    KC_9,    KC_0, KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT, XXXXXXX,                      KC_ASTR,    KC_4,    KC_5,    KC_6, KC_PLUS,  KC_EQL,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
       KC_TAB, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                     KC_SLASH,    KC_1,    KC_2,    KC_3, KC_MINS, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,     KC_DOT,    KC_0, _______
                                      //`--------------------------'  `--------------------------'
  ),

    [_COMMAND] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_F18, XXXXXXX, XXXXXXX, LANG_EN, LANG_RU, KC_STAB,                      XXXXXXX, XXXXXXX,   KC_UP, XXXXXXX, XXXXXXX,  KC_DEL,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT,  KC_TAB,                      XXXXXXX, KC_LEFT, KC_DOWN, KC_RGHT, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, KC_VOLD, KC_MUTE, KC_VOLU, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, XXXXXXX, _______,    _______, XXXXXXX, _______
                                      //`--------------------------'  `--------------------------'
  ),

/*
    [XXXXXXX] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, _______, XXXXXXX
                                      //`--------------------------'  `--------------------------'
  ),
*/
};

// Send the OS layout hotkey without any held mods leaking into it
static void os_layout(uint16_t keycode) {
    const uint8_t mods = get_mods();
    clear_mods();
    tap_code16(keycode);
    set_mods(mods);
    send_keyboard_report();
}

// The host helper (kb-layout-sync) reports the active OS layout over Raw HID:
// data[0] = HID_LAYOUT_SYNC, data[1] = 1 for ru, 0 for anything else.
#define HID_LAYOUT_SYNC 0x4C
#define SYM_SYNC_SETTLE_MS 500

static bool     sym_from_ru;
static uint32_t sync_ignore_until;

void raw_hid_receive(uint8_t *data, uint8_t length) {
    if (data[0] != HID_LAYOUT_SYNC) {
        return;
    }
    // The symbol key flips the OS layout to en and back; don't follow that
    if (sym_from_ru || !timer_expired32(timer_read32(), sync_ignore_until)) {
        return;
    }
    if (data[1]) {
        layer_on(_RU);
    } else {
        layer_off(_RU);
    }
}

static void set_russian(bool ru) {
    os_layout(ru ? OS_RU : OS_EN);
    if (ru) {
        layer_on(_RU);
    } else {
        layer_off(_RU);
    }
}

// Hotkeys stay on Enthium: a key pressed on the RU layer while Ctrl, Alt or
// GUI is held sends the Enthium keycode of that position instead.
static uint8_t ru_hotkey[MATRIX_ROWS][MATRIX_COLS];

static bool process_ru_hotkey(uint16_t keycode, keyrecord_t *record) {
    if (!IS_KEYEVENT(record->event)) {
        return true;
    }
    const keypos_t pos = record->event.key;

    if (!record->event.pressed) {
        const uint8_t held = ru_hotkey[pos.row][pos.col];
        if (held == KC_NO) {
            return true;
        }
        unregister_code(held);
        ru_hotkey[pos.row][pos.col] = KC_NO;
        return false;
    }

    if (!(get_mods() & MOD_MASK_CAG) || layer_switch_get_layer(pos) != _RU) {
        return true;
    }
    if (IS_QK_MOD_TAP(keycode) && !record->tap.count) {
        return true; // held as a modifier, same mod on both layers
    }

    uint16_t enthium = keymap_key_to_keycode(_BASE_ENTHIUM, pos);
    if (IS_QK_MOD_TAP(enthium)) {
        enthium = QK_MOD_TAP_GET_TAP_KEYCODE(enthium);
    }
    if (!IS_BASIC_KEYCODE(enthium)) {
        return true;
    }
    register_code(enthium);
    ru_hotkey[pos.row][pos.col] = enthium;
    return false;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  if (!process_ru_hotkey(keycode, record)) {
    return false;
  }

  switch (keycode) {
    case LT_SYMMD:
      // Symbols are typed in the en layout, then ru is restored
      if (record->event.pressed) {
        layer_on(_SYMBOL);
        sym_from_ru = IS_LAYER_ON(_RU);
        if (sym_from_ru) {
          os_layout(OS_EN);
        }
      } else {
        layer_off(_SYMBOL);
        if (sym_from_ru) {
          sym_from_ru       = false;
          sync_ignore_until = timer_read32() + SYM_SYNC_SETTLE_MS;
          os_layout(OS_RU);
        }
      }
      return false;

    case MACRO_ESC_L1:
      if (record->event.pressed) {
        tap_code(KC_ESC);
        set_russian(false);
      }
      return false;

    case LANG_EN:
    case LANG_RU:
      if (record->event.pressed) {
        set_russian(keycode == LANG_RU);
      }
      return false;
  }
  return true;
}

#ifdef CHORDAL_HOLD
const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM =
    LAYOUT(
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
                       '*', '*', '*',  '*', '*', '*'
    );
#endif


#ifdef OLED_ENABLE

bool render_status(void) {
    oled_set_cursor(17, 0);
    //oled_write_P(PSTR("Layer: "), false);
    switch (get_highest_layer(layer_state)) {
        case _BASE_ENTHIUM:
            oled_write_P(PSTR("ENTH"), false);
            break;
        case _RU:
            oled_write_P(PSTR(" RUS"), false);
            break;
        case _SYMBOL:
            oled_write_P(PSTR(" SYM"), false);
            break;
        case _NUMBER:
            oled_write_P(PSTR(" NUM"), false);
            break;
        case _COMMAND:
            oled_write_P(PSTR(" CMD"), false);
            break;
        default:
            oled_write_P(PSTR(" ???"), false);
    }

    oled_set_cursor(18, 1);
    oled_write(get_u8_str(get_current_wpm(), '0'), false);

    /*
    led_t led_state = host_keyboard_led_state();
    oled_write_P(led_state.num_lock ? PSTR("NUM ") : PSTR("    "), false);
    oled_write_P(led_state.caps_lock ? PSTR("CAP ") : PSTR("    "), false);
    oled_write_P(led_state.scroll_lock ? PSTR("SCR ") : PSTR("    "), false);
    */

    return false;
}

bool oled_task_user(void) {
    if (is_keyboard_master()) {
        render_bongocat();
        render_status();
        return false;
    }
    // Offhand: let the keyboard-level code draw the Corne logo
    return true;
}
#endif

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

enum keycodes {
    LT_SYMMD = SAFE_RANGE,
    MACRO_ESC_L1,
};

enum layers {
    _BASE_ENTHIUM,
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

// Layout keys
#define LAYOUT1 LSA(KC_1)
#define LAYOUT2 LSA(KC_3)

// Combos
const uint16_t PROGMEM ht_esc[] = {HRM_SH, HRM_CT, COMBO_END};
const uint16_t PROGMEM htn_esc_l1[] = {HRM_SH, HRM_CT, HRM_AN, COMBO_END};
const uint16_t PROGMEM um_layout1[] = {KC_U, KC_MINS, COMBO_END};
const uint16_t PROGMEM lk_layout2[] = {KC_L, KC_K, COMBO_END};

combo_t key_combos[] = {
    [_COMBO_HT_ESC] = COMBO(ht_esc, KC_ESC),
    [_COMBO_HTN_ESC_L1] = COMBO(htn_esc_l1, MACRO_ESC_L1),
    [_COMBO_LAYOUT1] = COMBO(um_layout1, LAYOUT1),
    [_COMBO_LAYOUT2] = COMBO(lk_layout2, LAYOUT2),
};

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

    [_SYMBOL] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      KC_EXLM, KC_LBRC, KC_LPRN, KC_RPRN, KC_RBRC, KC_PERC,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_HASH, KC_CIRC, KC_LCBR, KC_RCBR,  KC_DLR, KC_ASTR,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
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
       KC_F18, XXXXXXX, XXXXXXX, LAYOUT1, LAYOUT2, XXXXXXX,                      XXXXXXX, XXXXXXX,   KC_UP, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT, XXXXXXX,                       KC_TAB, KC_LEFT, KC_DOWN, KC_RGHT, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
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

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case LT_SYMMD:
      if (record->event.pressed) {
        register_code(KC_F17);
        layer_on(_SYMBOL);
      } else {
        unregister_code(KC_F17);
        layer_off(_SYMBOL);
      }
      return false;

    case MACRO_ESC_L1:
        if (record->event.pressed) {
            tap_code16(KC_ESC);
            tap_code16(LAYOUT1);
        }
        return true;
  }
  return true;
}

#ifdef CHORDAL_HOLD
const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM =
    LAYOUT(
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
                       'L', 'L', 'L',  'R', 'R', 'R'
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

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    if (!is_keyboard_master()) {
        //return OLED_ROTATION_270;
        return rotation;
    }
    return rotation;
}

bool oled_task_user(void) {
    if (is_keyboard_master()) {
        render_bongocat();
        render_status();
    } else {
        //render_status();
    }
    return false;
}
#endif

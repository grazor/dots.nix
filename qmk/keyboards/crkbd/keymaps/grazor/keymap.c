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
#include "transactions.h"

enum layers {
    L_BASE,
    L_RU,
    L_SYM,
    L_NUM,
    L_CMD,
    L_MOUSE,
};

enum custom_keycodes {
    SYMBOLS = SAFE_RANGE, // Symbols layer while held; in Russian also the en layout
    ESC_EN,               // Escape, then the English layout
    LANG_EN,
    LANG_RU,
    NUM_DOT,              // . and , that come out right in either layout
    NUM_COMM,
};

enum combos {
    C_ESC,
    C_ESC_EN,
    C_LANG_EN,
    C_LANG_RU,
};

// Thumb layer keys
#define NUMBERS MO(L_NUM)
#define CMD_R   LT(L_CMD, KC_R)
#define CMD_RU  LT(L_CMD, KC_RBRC) // ъ on tap in Russian, where Enthium has r

// Home row mods, written GACS; on macOS Ctrl and GUI trade places (CAGS)
#define HRM_GC LGUI_T(KC_C)
#define HRM_AI LALT_T(KC_I)
#define HRM_CA LCTL_T(KC_A)
#define HRM_SE LSFT_T(KC_E)

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

#define SFT_TAB  S(KC_TAB)

// OS layout keys: Caps selects en, Shift+Caps selects ru
#define OS_EN KC_CAPS
#define OS_RU S(KC_CAPS)

// Combos
const uint16_t PROGMEM combo_esc[]     = {HRM_SH, HRM_CT, COMBO_END};
const uint16_t PROGMEM combo_esc_en[]  = {HRM_SH, HRM_CT, HRM_AN, COMBO_END};
const uint16_t PROGMEM combo_lang_en[] = {KC_U, KC_MINS, COMBO_END};
const uint16_t PROGMEM combo_lang_ru[] = {KC_L, KC_K, COMBO_END};

combo_t key_combos[] = {
    [C_ESC]     = COMBO(combo_esc, KC_ESC),
    [C_ESC_EN]  = COMBO(combo_esc_en, ESC_EN),
    [C_LANG_EN] = COMBO(combo_lang_en, LANG_EN),
    [C_LANG_RU] = COMBO(combo_lang_ru, LANG_RU),
};

// Combos are defined with Enthium keycodes; keep them positional on the RU layer
uint8_t combo_ref_from_layer(uint8_t layer) {
    return layer == L_RU ? L_BASE : layer;
}

// Combos only start after a pause in typing, so fast rolls such as "th" or
// "lk" stay letters
static uint32_t prev_press_time;
static uint32_t last_press_time;

bool pre_process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (IS_KEYEVENT(record->event) && record->event.pressed) {
        prev_press_time = last_press_time;
        last_press_time = timer_read32();
    }
    return true;
}

bool combo_should_trigger(uint16_t combo_index, combo_t *combo, uint16_t keycode, keyrecord_t *record) {
    // Releases, and further keys of a combo already under way, always count
    if (!record->event.pressed || combo->state) {
        return true;
    }
    return timer_elapsed32(prev_press_time) >= COMBO_IDLE_TERM;
}

// The h+t combos sit on home row mods, so held together they stay Shift and
// Ctrl/Cmd for shortcuts; only a quick tap of them is a combo
bool get_combo_must_tap(uint16_t combo_index, combo_t *combo) {
    return combo_index == C_ESC || combo_index == C_ESC_EN;
}

// Caps Word: defaults, plus the Russian letters that sit on punctuation keys
bool caps_word_press_user(uint16_t keycode) {
    switch (keycode) {
        case KC_A ... KC_Z:
        case KC_MINS:
            add_weak_mods(MOD_BIT(KC_LSFT));
            return true;

        case KC_1 ... KC_0:
        case KC_BSPC:
        case KC_DEL:
        case KC_UNDS:
            return true;

        // ж э б ю ё х ъ
        case KC_SCLN:
        case KC_QUOT:
        case KC_COMM:
        case KC_DOT:
        case KC_GRV:
        case KC_LBRC:
        case KC_RBRC:
            if (get_highest_layer(layer_state) != L_RU) {
                return false;
            }
            add_weak_mods(MOD_BIT(KC_LSFT));
            return true;

        default:
            return false;
    }
}

// Key overrides
const key_override_t delete_key_override = ko_make_basic(MOD_MASK_SHIFT, KC_BSPC, KC_DEL);

const key_override_t *key_overrides[] = {
    &delete_key_override,
};

/*
  Enthium v14

  q y o u = x l d p z
b c i a e - k h t n s w
  ' , . ; / j m g f v
            r
*/

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [L_BASE] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_GRV,    KC_Q,    KC_Y,    KC_O,    KC_U,  KC_EQL,                         KC_X,    KC_L,    KC_D,    KC_P,    KC_Z, KC_LBRC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
         KC_B,  HRM_GC,  HRM_AI,  HRM_CA,  HRM_SE, KC_MINS,                         KC_K,  HRM_SH,  HRM_CT,  HRM_AN,  HRM_GS,    KC_W,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
       KC_TAB, KC_QUOT, KC_COMM,  KC_DOT, KC_SCLN, KC_SLSH,                         KC_J,    KC_M,    KC_G,    KC_F,    KC_V, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                           KC_ENT, NUMBERS,  KC_SPC,      CMD_R, SYMBOLS, KC_BSPC
                                      //`--------------------------'  `--------------------------'
  ),

    // QWERTY positions, which the OS Russian layout turns into ЙЦУКЕН.
    // Transparent keys keep their Enthium keycode (ё, х, Tab, thumbs); ъ is a
    // tap of the R thumb.
    [L_RU] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      _______,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                         KC_Y,    KC_U,    KC_I,    KC_O,    KC_P, _______,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      _______,   RU_GA,   RU_AS,   RU_CD,   RU_SF,    KC_G,                         KC_H,   RU_SJ,   RU_CK,   RU_AL,   RU_GS, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      _______,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, _______,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,     CMD_RU, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),

    // After sunaku's Glove80 symbol layer: brackets and operators roll inward on
    // the left hand, = _ and the Vim motions ^ $ # * sit on the home row, ? * /
    // stack on the inner column. What his extra rows and thumbs hold moves to
    // the right hand: braces on the home fingers, quotes on the ring finger.
    [L_SYM] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      KC_EXLM, KC_LBRC, KC_LPRN, KC_RPRN, KC_RBRC, KC_QUES,                      KC_PERC, KC_PLUS, KC_AMPR, KC_QUOT, KC_SCLN,  KC_GRV,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_HASH, KC_CIRC,  KC_EQL, KC_UNDS,  KC_DLR, KC_ASTR,                      KC_BSLS, KC_LCBR, KC_RCBR, KC_DQUO, KC_COLN,   KC_AT,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_TILD,   KC_LT, KC_PIPE, KC_MINS,   KC_GT, KC_SLSH,                      XXXXXXX, XXXXXXX, KC_COMM,  KC_DOT, XXXXXXX, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,    XXXXXXX, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),

    [L_NUM] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      XXXXXXX,    KC_1,    KC_2,    KC_3,    KC_4,    KC_5,                         KC_6,    KC_7,    KC_8,    KC_9,    KC_0, KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT,  KC_SPC,                      KC_ASTR,    KC_4,    KC_5,    KC_6, KC_PLUS,  KC_EQL,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
       KC_TAB, XXXXXXX,NUM_COMM, NUM_DOT, XXXXXXX, XXXXXXX,                      KC_SLSH,    KC_1,    KC_2,    KC_3, KC_MINS, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,       KC_0, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),

    [L_CMD] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_F18, XXXXXXX, XXXXXXX, LANG_EN, LANG_RU, SFT_TAB,                      XXXXXXX, XXXXXXX,   KC_UP, XXXXXXX, KC_PGUP,  KC_DEL,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT,  KC_TAB,                      XXXXXXX, KC_LEFT, KC_DOWN, KC_RGHT, KC_PGDN, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, KC_VOLD, KC_MUTE, KC_VOLU, XXXXXXX, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, XXXXXXX, _______,    _______, XXXXXXX, _______
                                      //`--------------------------'  `--------------------------'
  ),

    // Symbols + Numbers held together. Pointer under the right hand, buttons
    // on the left home row so a drag is one hand holding and the other moving.
    [L_MOUSE] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, MS_BTN1,   MS_UP, MS_BTN2, MS_WHLU, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, MS_BTN3, MS_BTN2, MS_BTN1, XXXXXXX,                      XXXXXXX, MS_LEFT, MS_DOWN, MS_RGHT, MS_WHLD, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,    XXXXXXX, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),
};

layer_state_t layer_state_set_user(layer_state_t state) {
    if (is_layer_locked(L_MOUSE)) {
        return state;
    }
    return update_tri_layer_state(state, L_SYM, L_NUM, L_MOUSE);
}

// Send the OS layout hotkey without any held mods leaking into it
static void os_layout(uint16_t keycode) {
    const uint8_t mods = get_mods();
    clear_mods();
    tap_code16(keycode);
    set_mods(mods);
    send_keyboard_report();
}

// Home row mods are written GACS (GUI on the pinky). On macOS, where Cmd does the
// job of Ctrl, Ctrl and GUI trade places for CAGS: Cmd on the middle finger.
// The host is macOS when OS detection says so, or when kb-layout-sync (a macOS
// helper) talks to the keyboard.
static bool host_is_mac;

static void set_host_mac(bool mac) {
    if (mac == host_is_mac) {
        return;
    }
    host_is_mac = mac;
    // A modifier held across the swap would be released as the other one
    clear_mods();
    send_keyboard_report();
    keymap_config.swap_lctl_lgui = mac;
    keymap_config.swap_rctl_rgui = mac;
}

bool process_detected_host_os_user(os_variant_t detected_os) {
    set_host_mac(detected_os == OS_MACOS || detected_os == OS_IOS);
    return true;
}

// The offhand display shows the mods by name, so it needs to know the host too
static void host_sync_handler(uint8_t in_buflen, const void *in_data, uint8_t out_buflen, void *out_data) {
    host_is_mac = *(const bool *)in_data;
}

void keyboard_post_init_user(void) {
    transaction_register_rpc(USER_SYNC_HOST, host_sync_handler);
}

void housekeeping_task_user(void) {
    static uint32_t last_sync;
    static bool     synced_mac;
    if (!is_keyboard_master()) {
        return;
    }
    // Resend now and then too, in case the other half restarted
    if (synced_mac != host_is_mac || timer_elapsed32(last_sync) > 1000) {
        if (transaction_rpc_send(USER_SYNC_HOST, sizeof(host_is_mac), &host_is_mac)) {
            synced_mac = host_is_mac;
            last_sync  = timer_read32();
        }
    }
}

// The firmware follows the OS layout however it was switched:
//   macOS  kb-layout-sync reports it over Raw HID,
//          data[0] = HID_LAYOUT_SYNC, data[1] = 1 for ru, 0 otherwise
//   Linux  xkb option grp_led:scroll lights Scroll Lock while ru is active
#define HID_LAYOUT_SYNC 0x4C
#define BORROW_SETTLE_MS 500

// While Russian is on, the OS layout is borrowed back to en for as long as the
// Symbols layer is held, so symbols come out the same in both layouts. Shortcuts
// need no switch: process_ru_hotkey sends their Enthium keycodes.
#define BORROW_SYMBOLS (1 << 0)

static uint8_t  en_borrowed;
static uint32_t sync_ignore_until;

static void borrow_en(uint8_t reason) {
    if (!IS_LAYER_ON(L_RU) || (en_borrowed & reason)) {
        return;
    }
    if (!en_borrowed) {
        os_layout(OS_EN);
    }
    en_borrowed |= reason;
}

static void return_en(uint8_t reason) {
    if (!(en_borrowed & reason)) {
        return;
    }
    en_borrowed &= ~reason;
    if (!en_borrowed) {
        sync_ignore_until = timer_read32() + BORROW_SETTLE_MS;
        os_layout(OS_RU);
    }
}

static void follow_os_layout(bool ru) {
    // Borrowing flips the OS layout to en and back; don't follow that
    if (en_borrowed || !timer_expired32(timer_read32(), sync_ignore_until)) {
        return;
    }
    if (ru) {
        layer_on(L_RU);
    } else {
        layer_off(L_RU);
    }
}

void raw_hid_receive(uint8_t *data, uint8_t length) {
    if (data[0] == HID_LAYOUT_SYNC) {
        set_host_mac(true);
        follow_os_layout(data[1]);
    }
}

// Only changes count, so a host that never drives Scroll Lock is unaffected
bool led_update_user(led_t led_state) {
    static bool scroll_lock;
    if (led_state.scroll_lock != scroll_lock) {
        scroll_lock = led_state.scroll_lock;
        follow_os_layout(scroll_lock);
    }
    return true;
}

// A locked Symbols layer outlives its key; switch back to ru once it unlocks
bool layer_lock_set_user(layer_state_t locked_layers) {
    if (!(locked_layers & ((layer_state_t)1 << L_SYM)) && !IS_LAYER_ON(L_SYM)) {
        return_en(BORROW_SYMBOLS);
    }
    return true;
}

static void set_russian(bool ru) {
    en_borrowed = 0;
    os_layout(ru ? OS_RU : OS_EN);
    if (ru) {
        layer_on(L_RU);
    } else {
        layer_off(L_RU);
    }
}

// Hotkeys stay on Enthium: a key tapped on the RU layer while Ctrl, Alt or GUI
// is held sends the Enthium keycode of that position instead.
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

    if (!(get_mods() & MOD_MASK_CAG) || layer_switch_get_layer(pos) != L_RU) {
        return true;
    }
    if ((IS_QK_MOD_TAP(keycode) || IS_QK_LAYER_TAP(keycode)) && !record->tap.count) {
        return true; // held as a modifier or layer key, same on both layers
    }

    uint16_t enthium = keymap_key_to_keycode(L_BASE, pos);
    if (IS_QK_MOD_TAP(enthium)) {
        enthium = QK_MOD_TAP_GET_TAP_KEYCODE(enthium);
    } else if (IS_QK_LAYER_TAP(enthium)) {
        enthium = QK_LAYER_TAP_GET_TAP_KEYCODE(enthium);
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
        case SYMBOLS:
            // Symbols are typed in the en layout, then ru is restored
            if (record->event.pressed) {
                layer_on(L_SYM);
                borrow_en(BORROW_SYMBOLS);
            } else if (!is_layer_locked(L_SYM)) {
                layer_off(L_SYM);
                return_en(BORROW_SYMBOLS);
            }
            return false;

        case NUM_DOT:
        case NUM_COMM:
            // In Russian . and , live on the slash key (Shift for the comma)
            if (record->event.pressed) {
                if (IS_LAYER_ON(L_RU) && !en_borrowed) {
                    tap_code16(keycode == NUM_DOT ? KC_SLSH : S(KC_SLSH));
                } else {
                    tap_code(keycode == NUM_DOT ? KC_DOT : KC_COMM);
                }
            }
            return false;

        case ESC_EN:
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
    LAYOUT_split_3x6_3(
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
        'L', 'L', 'L', 'L', 'L', 'L',  'R', 'R', 'R', 'R', 'R', 'R',
                       '*', '*', '*',  '*', '*', '*'
    );
#endif

#ifdef OLED_ENABLE

static void render_layer(void) {
    switch (get_highest_layer(layer_state)) {
        case L_BASE:
            oled_write_P(PSTR("ENTH"), false);
            break;
        case L_RU:
            oled_write_P(PSTR(" RUS"), false);
            break;
        case L_SYM:
            oled_write_P(PSTR(" SYM"), false);
            break;
        case L_NUM:
            oled_write_P(PSTR(" NUM"), false);
            break;
        case L_CMD:
            oled_write_P(PSTR(" CMD"), false);
            break;
        case L_MOUSE:
            oled_write_P(PSTR("MOUS"), false);
            break;
        default:
            oled_write_P(PSTR(" ???"), false);
    }
}

// Offhand display: the active layout in large type, the layer being held, and
// the held modifiers along the bottom in finger order, pinky to index.

extern const unsigned char font[];

// A font glyph scaled 3x: 18x24 px from the top of the screen
static void render_big_char(char c, uint8_t x0) {
    for (uint8_t col = 0; col < 6; col++) {
        const uint8_t bits = pgm_read_byte(&font[(uint8_t)c * 6 + col]);
        for (uint8_t bit = 0; bit < 8; bit++) {
            for (uint8_t d = 0; d < 9; d++) {
                oled_write_pixel(x0 + col * 3 + d % 3, bit * 3 + d / 3, bits & (1 << bit));
            }
        }
    }
}

static void render_layout(bool ru) {
    // The big letters own the first 42 px of rows 0-2
    for (uint8_t y = 0; y < 24; y++) {
        for (uint8_t x = 0; x < 3; x++) {
            oled_write_pixel(x, y, false);
            oled_write_pixel(39 + x, y, false);
        }
    }
    render_big_char(ru ? 'R' : 'E', 3);
    render_big_char(ru ? 'U' : 'N', 21);
    oled_set_cursor(7, 0);
    oled_write_P(PSTR("              "), false);
    oled_set_cursor(7, 1);
    oled_write_P(ru ? PSTR("  Russian     ") : PSTR("  Enthium v14 "), false);
}

static void render_held_layer(void) {
    oled_set_cursor(7, 2);
    switch (get_highest_layer(layer_state)) {
        case L_SYM:
            oled_write_P(PSTR("  Symbols     "), false);
            break;
        case L_NUM:
            oled_write_P(PSTR("  Numbers     "), false);
            break;
        case L_CMD:
            oled_write_P(PSTR("  Command     "), false);
            break;
        case L_MOUSE:
            oled_write_P(PSTR("  Mouse       "), false);
            break;
        default:
            oled_write_P(PSTR("              "), false);
    }
}

static void render_mod(const char *name, bool held) {
    oled_write_P(PSTR("  "), false);
    oled_write_P(name, held);
}

static void render_mods(void) {
    const uint8_t mods = get_mods();
    oled_set_cursor(0, 3);
    if (host_is_mac) {
        render_mod(PSTR("CTL"), mods & MOD_MASK_CTRL);
        render_mod(PSTR("ALT"), mods & MOD_MASK_ALT);
        render_mod(PSTR("GUI"), mods & MOD_MASK_GUI);
    } else {
        render_mod(PSTR("GUI"), mods & MOD_MASK_GUI);
        render_mod(PSTR("ALT"), mods & MOD_MASK_ALT);
        render_mod(PSTR("CTL"), mods & MOD_MASK_CTRL);
    }
    render_mod(PSTR("SFT"), mods & MOD_MASK_SHIFT);
    oled_write_P(PSTR(" "), false);
}

static void render_offhand(void) {
    render_layout(IS_LAYER_ON(L_RU));
    render_held_layer();
    render_mods();
}

bool oled_task_user(void) {
    // The driver wakes a display only when its content changes; wake both on
    // typing too (activity reaches the offhand via SPLIT_ACTIVITY_ENABLE)
    if (last_input_activity_elapsed() < OLED_TIMEOUT) {
        oled_on();
    }

    if (is_keyboard_master()) {
        render_bongocat();
        oled_set_cursor(17, 0);
        render_layer();
        oled_set_cursor(18, 1);
        oled_write(get_u8_str(get_current_wpm(), '0'), false);
    } else {
        render_offhand();
    }
    return false;
}
#endif

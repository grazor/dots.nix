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

#include "raw_hid.h"
#include "transactions.h"

enum layers {
    L_BASE,
    L_RU,
    L_SYM,
    L_NUM,
    L_CMD,
    L_TYPO,
    L_MOUSE,
};

enum custom_keycodes {
    SYMBOLS = SAFE_RANGE, // Symbols layer while held; in Russian also the en layout
    ESC_EN,               // Escape, then the English layout
    LANG_EN,
    LANG_RU,
    NUM_DOT,              // . and , that come out right in either layout
    NUM_COMM,
    POMO,                 // Pomodoro: start, pause, resume
    POMO_RST,             // Pomodoro: back to idle
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

// Typography: Option shortcuts of the macOS English (ABC) layout. The layer sits
// on top of Symbols, which keeps the system in English, so they serve Russian too.
#define TY_MDASH LSA(KC_MINS) // —
#define TY_HELLP A(KC_SCLN)   // …
#define TY_NEQ   A(KC_EQL)    // ≠
#define TY_PLMN  LSA(KC_EQL)  // ±
#define TY_APPRX A(KC_X)      // ≈
#define TY_DEG   LSA(KC_8)    // °
#define TY_BULLT A(KC_8)      // •
#define TY_EURO  LSA(KC_2)    // €
#define TY_SECT  A(KC_6)      // §
#define TY_LEQ   A(KC_COMM)   // ≤
#define TY_GEQ   A(KC_DOT)    // ≥
#define TY_DIV   A(KC_SLSH)   // ÷
#define TY_MIDOT LSA(KC_9)    // ·
#define TY_INF   A(KC_5)      // ∞
#define TY_PI    A(KC_P)      // π
#define TY_MICRO A(KC_M)      // µ
#define TY_SQRT  A(KC_V)      // √
#define TY_DELTA A(KC_J)      // ∆
#define TY_COPY  A(KC_G)      // ©
#define TY_TM    A(KC_2)      // ™
#define TY_NBSP  A(KC_SPC)    // no-break space

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

    // Symbols + Numbers held together. Each character sits on the key of its
    // plain cousin on the Symbols layer (— on -, ≤ ≥ on < >, ÷ on /), and the
    // letter-like ones on their Enthium letter (π on p, µ on m, ∆ on d, √ on v,
    // ™ on t).
    [L_TYPO] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, TY_PLMN,TY_DELTA,   TY_PI, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      TY_SECT,  TY_DEG,  TY_NEQ,TY_MIDOT, TY_EURO,TY_BULLT,                      XXXXXXX, XXXXXXX,   TY_TM, XXXXXXX, XXXXXXX, TY_COPY,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
     TY_APPRX,  TY_LEQ,  TY_INF,TY_MDASH,  TY_GEQ,  TY_DIV,                      XXXXXXX,TY_MICRO, XXXXXXX,TY_HELLP, TY_SQRT, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, TY_NBSP,    XXXXXXX, _______, _______
                                      //`--------------------------'  `--------------------------'
  ),

    [L_CMD] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_F18, XXXXXXX, XXXXXXX, LANG_EN, LANG_RU, SFT_TAB,                      XXXXXXX, XXXXXXX,   KC_UP, XXXXXXX, KC_PGUP,  KC_DEL,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT,  KC_TAB,                      XXXXXXX, KC_LEFT, KC_DOWN, KC_RGHT, KC_PGDN, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX,POMO_RST,    POMO, XXXXXXX,                      XXXXXXX, KC_VOLD, KC_MUTE, KC_VOLU, XXXXXXX, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,    _______, XXXXXXX, _______
                                      //`--------------------------'  `--------------------------'
  ),

    // Command (R thumb), then Numbers held. Pointer under the right hand, buttons
    // on the left home row so a drag is one hand holding and the other moving.
    [L_MOUSE] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, MS_BTN1,   MS_UP, MS_BTN2, MS_WHLU, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, MS_BTN3, MS_BTN2, MS_BTN1, XXXXXXX,                      XXXXXXX, MS_LEFT, MS_DOWN, MS_RGHT, MS_WHLD, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, QK_LLCK,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          _______, _______, _______,    _______, XXXXXXX, _______
                                      //`--------------------------'  `--------------------------'
  ),
};

// Two-thumb layers: Symbols + Numbers is Typography, Command + Numbers is
// Mouse. A locked one stays on after its thumbs let go.
layer_state_t layer_state_set_user(layer_state_t state) {
    if (!is_layer_locked(L_TYPO)) {
        state = update_tri_layer_state(state, L_SYM, L_NUM, L_TYPO);
    }
    if (!is_layer_locked(L_MOUSE)) {
        state = update_tri_layer_state(state, L_CMD, L_NUM, L_MOUSE);
    }
    return state;
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

// Pomodoro, kept by the master half: 25 min of work, then 5 min of rest, a
// 15 min one after every fourth work session. A finished phase waits for POMO
// before the next one starts.
#define POMO_WORK_MS       (25 * 60 * 1000UL)
#define POMO_REST_MS       (5 * 60 * 1000UL)
#define POMO_LONG_MS       (15 * 60 * 1000UL)
#define POMO_SESSIONS      4
#define POMO_ALERT_MS      5000

enum pomo_phase {
    PHASE_IDLE,
    PHASE_WORK,
    PHASE_REST,
    PHASE_LONG,
};

static struct {
    uint8_t  phase;
    bool     running;
    bool     waiting;  // phase over, the next one not started yet
    uint8_t  sessions; // work sessions done in this cycle
    uint32_t end;      // when running
    uint32_t left;     // when paused or waiting
    uint32_t alert_until;
} pomo;

static uint32_t pomo_length(uint8_t phase) {
    switch (phase) {
        case PHASE_REST:
            return POMO_REST_MS;
        case PHASE_LONG:
            return POMO_LONG_MS;
        default:
            return POMO_WORK_MS;
    }
}

static uint32_t pomo_left(void) {
    if (!pomo.running) {
        return pomo.left;
    }
    const uint32_t now = timer_read32();
    return timer_expired32(now, pomo.end) ? 0 : pomo.end - now;
}

static void pomo_toggle(void) {
    if (pomo.phase == PHASE_IDLE) {
        pomo.phase = PHASE_WORK;
        pomo.left  = POMO_WORK_MS;
    }
    if (pomo.running) {
        pomo.left    = pomo_left();
        pomo.running = false;
    } else {
        pomo.end     = timer_read32() + pomo.left;
        pomo.running = true;
        pomo.waiting = false;
    }
}

static void pomo_reset(void) {
    memset(&pomo, 0, sizeof(pomo));
}

static void pomo_task(void) {
    if (!pomo.running || pomo_left()) {
        return;
    }
    if (pomo.phase == PHASE_WORK) {
        pomo.sessions++;
        pomo.phase = pomo.sessions >= POMO_SESSIONS ? PHASE_LONG : PHASE_REST;
    } else {
        if (pomo.phase == PHASE_LONG) {
            pomo.sessions = 0;
        }
        pomo.phase = PHASE_WORK;
    }
    pomo.left        = pomo_length(pomo.phase);
    pomo.running     = false;
    pomo.waiting     = true;
    pomo.alert_until = timer_read32() + POMO_ALERT_MS;
}

// Mattermost badge, as kb-layout-sync reads it off the Dock icon:
//   data[0] = HID_MM_BADGE, data[1] = flags below, data[2] = mention count
#define HID_MM_BADGE     0x4D
#define MM_RUNNING       (1 << 0)
#define MM_UNREAD        (1 << 1) // unread but no mentions: a dot on the badge
#define MM_ALERT_MS      3000

static struct {
    uint8_t  flags;
    uint8_t  count;
    uint32_t alert_until;
} mm;

static void mm_update(uint8_t flags, uint8_t count) {
    const bool more = count > mm.count || (!mm.count && !(mm.flags & MM_UNREAD) && (flags & MM_UNREAD));
    if ((flags & MM_RUNNING) && (mm.flags & MM_RUNNING) && more) {
        mm.alert_until = timer_read32() + MM_ALERT_MS;
    }
    mm.flags = flags;
    mm.count = count;
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
    pomo_task();
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
    } else if (data[0] == HID_MM_BADGE) {
        set_host_mac(true);
        mm_update(data[1], data[2]);
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

        case POMO:
            if (record->event.pressed) {
                pomo_toggle();
            }
            return false;

        case POMO_RST:
            if (record->event.pressed) {
                pomo_reset();
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

// Both displays stand upright (32x128). The master shows the Mattermost badge
// and the Pomodoro; the offhand shows the layout, the held layer and the mods.

#define DISPLAY_WIDTH 32

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    return OLED_ROTATION_270;
}

extern const unsigned char font[];

static void fill_rect(uint8_t x, uint8_t y, uint8_t w, uint8_t h, bool on) {
    for (uint8_t dx = 0; dx < w; dx++) {
        for (uint8_t dy = 0; dy < h; dy++) {
            oled_write_pixel(x + dx, y + dy, on);
        }
    }
}

// Draws a box of the full display width, h px tall from y, with the text centred
// in it at the given scale. Every pixel of the box is written, so nothing from
// the previous frame survives. Glyphs are the 5x7 part of the font cells, 1 px
// apart, so three letters fit at 2x and two at 3x.
static void render_text_box(const char *text, uint8_t y, uint8_t h, uint8_t scale, bool invert) {
    const uint8_t len    = strlen(text);
    const uint8_t pitch  = 5 * scale + 1;
    const uint8_t text_w = len ? len * pitch - 1 : 0;
    const uint8_t x0     = (DISPLAY_WIDTH - text_w) / 2;
    const uint8_t y0     = (h - 7 * scale) / 2;

    for (uint8_t x = 0; x < DISPLAY_WIDTH; x++) {
        const uint8_t i    = (x - x0) / pitch;
        const uint8_t col  = (x - x0) % pitch / scale;
        uint8_t       bits = 0;
        if (x >= x0 && i < len && col < 5) {
            bits = pgm_read_byte(&font[(uint8_t)text[i] * 6 + col]);
        }
        for (uint8_t dy = 0; dy < h; dy++) {
            const bool on = dy >= y0 && dy < y0 + 7 * scale && (bits & (1 << ((dy - y0) / scale)));
            oled_write_pixel(x, y + dy, on != invert);
        }
    }
}

// Alternates every period ms
static bool blink(uint16_t period) {
    return timer_read32() / period % 2;
}

// Master: Mattermost badge

#define ENVELOPE_W 21
#define ENVELOPE_H 13

// An envelope outline with the flap folded to the middle
static bool envelope_pixel(uint8_t x, uint8_t y) {
    if (x == 0 || x == ENVELOPE_W - 1 || y == 0 || y == ENVELOPE_H - 1) {
        return true;
    }
    const uint8_t dx = x < ENVELOPE_W / 2 ? x : ENVELOPE_W - 1 - x;
    return y == dx * (ENVELOPE_H / 2) / (ENVELOPE_W / 2);
}

static void render_badge(void) {
    // New mentions make the envelope hop and the count flash
    static const uint8_t hop[] = {0, 2, 3, 3, 2, 0, 0, 0};
    const bool           alert = !timer_expired32(timer_read32(), mm.alert_until);
    const uint8_t        lift  = alert ? hop[timer_read32() / 75 % sizeof(hop)] : 0;
    const uint8_t        top   = 4 - lift;
    const uint8_t        left  = (DISPLAY_WIDTH - ENVELOPE_W) / 2;

    for (uint8_t x = 0; x < DISPLAY_WIDTH; x++) {
        for (uint8_t y = 0; y < 18; y++) {
            const bool inside = x >= left && x < left + ENVELOPE_W && y >= top && y < top + ENVELOPE_H;
            oled_write_pixel(x, y, inside && envelope_pixel(x - left, y - top));
        }
    }

    char count[4] = "-";
    if (!(mm.flags & MM_RUNNING)) {
        // Mattermost is not running, or no word from kb-layout-sync
    } else if (mm.count > 99) {
        strcpy(count, "99+");
    } else if (mm.count) {
        const char *digits = get_u8_str(mm.count, ' ');
        strcpy(count, digits + strspn(digits, " "));
    } else {
        strcpy(count, mm.flags & MM_UNREAD ? "\x07" : "0");
    }
    render_text_box(count, 19, 18, 2, alert && !blink(250));
}

// Master: Pomodoro

static void render_pomodoro(void) {
    const bool     alert = !timer_expired32(timer_read32(), pomo.alert_until);
    const bool     flash = alert && !blink(250);
    const uint32_t left  = pomo_left();
    const uint16_t secs  = (left + 999) / 1000;

    // Dotted rule under the badge
    for (uint8_t x = 0; x < DISPLAY_WIDTH; x++) {
        oled_write_pixel(x, 42, x % 2 && x > 2 && x < DISPLAY_WIDTH - 3);
    }

    const char *label;
    switch (pomo.phase) {
        case PHASE_WORK:
            label = "WORK";
            break;
        case PHASE_REST:
            label = "REST";
            break;
        case PHASE_LONG:
            label = "LONG";
            break;
        default:
            label = "POMO";
    }
    // Waiting for POMO: the label of the next phase blinks
    render_text_box(label, 48, 11, 1, flash || (pomo.waiting && !alert && blink(500)));

    char minutes[3] = "25";
    char seconds[4] = ":00";
    if (pomo.phase != PHASE_IDLE) {
        minutes[0] = '0' + secs / 600;
        minutes[1] = '0' + secs / 60 % 10;
        seconds[1] = '0' + secs % 60 / 10;
        seconds[2] = '0' + secs % 10;
    }
    // Paused: the time blinks
    const bool hide = pomo.phase != PHASE_IDLE && !pomo.running && !pomo.waiting && blink(500);
    render_text_box(hide ? "" : minutes, 60, 25, 3, flash);
    render_text_box(hide ? "" : seconds, 85, 11, 1, flash);

    // Progress through the phase
    const uint32_t length = pomo_length(pomo.phase);
    const uint8_t  done   = pomo.phase == PHASE_IDLE ? 0 : (uint64_t)(length - left) * DISPLAY_WIDTH / length;
    fill_rect(0, 101, done, 3, true);
    fill_rect(done, 101, DISPLAY_WIDTH - done, 3, false);

    // Work sessions in this cycle: filled when done, outlined otherwise
    fill_rect(0, 112, DISPLAY_WIDTH, 16, false);
    for (uint8_t i = 0; i < POMO_SESSIONS; i++) {
        const uint8_t x = 2 + i * 8;
        fill_rect(x, 114, 5, 5, true);
        if (i >= pomo.sessions) {
            fill_rect(x + 1, 115, 3, 3, false);
        }
    }
}

// Offhand: the active layout and the layer being held in large type, the held
// modifiers below in right-hand finger order, index to pinky.

static const char *held_layer_name(void) {
    switch (get_highest_layer(layer_state)) {
        case L_SYM:
            return "SYM";
        case L_NUM:
            return "NUM";
        case L_CMD:
            return "CMD";
        case L_TYPO:
            return "TYP";
        case L_MOUSE:
            return "MOU";
        default:
            return "";
    }
}

static void render_offhand(void) {
    const uint8_t mods = get_mods();
    const bool    ctrl = mods & MOD_MASK_CTRL;
    const bool    gui  = mods & MOD_MASK_GUI;

    render_text_box(IS_LAYER_ON(L_RU) ? "RU" : "EN", 0, 28, 3, false);
    render_text_box(held_layer_name(), 28, 28, 2, false);

    render_text_box("SFT", 80, 11, 1, mods & MOD_MASK_SHIFT);
    render_text_box(host_is_mac ? "GUI" : "CTL", 92, 11, 1, host_is_mac ? gui : ctrl);
    render_text_box("ALT", 104, 11, 1, mods & MOD_MASK_ALT);
    render_text_box(host_is_mac ? "CTL" : "GUI", 116, 11, 1, host_is_mac ? ctrl : gui);
}

bool oled_task_user(void) {
    // The driver wakes a display only when its content changes; wake both on
    // typing too (activity reaches the offhand via SPLIT_ACTIVITY_ENABLE)
    const bool active = last_input_activity_elapsed() < OLED_TIMEOUT;
    if (active) {
        oled_on();
    }

    if (is_keyboard_master()) {
        // Any change of content keeps the display on, so the ticking timer
        // and the blinking are only drawn while typing or during an alert
        const uint32_t now   = timer_read32();
        const bool     alert = !timer_expired32(now, mm.alert_until) || !timer_expired32(now, pomo.alert_until);
        if (active || alert) {
            render_badge();
            render_pomodoro();
        }
    } else {
        render_offhand();
    }
    return false;
}
#endif

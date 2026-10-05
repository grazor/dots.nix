/*
This is the c configuration file for the keymap

Copyright 2012 Jun Wako <wakojun@gmail.com>
Copyright 2015 Jack Humbert

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

#pragma once

// Home row mods
#define TAPPING_TERM 200
#define QUICK_TAP_TERM 0
#define CHORDAL_HOLD
#define PERMISSIVE_HOLD
#define FLOW_TAP_TERM 150

// Combos: only after a pause in typing, and the home row mod ones only as taps
#define COMBO_STRICT_TIMER
#define COMBO_TERM 40
#define COMBO_SHOULD_TRIGGER
#define COMBO_MUST_TAP_PER_COMBO
#define COMBO_IDLE_TERM FLOW_TAP_TERM

// Display
#define OLED_BRIGHTNESS 16

// Split: share layer, modifier and activity state with the offhand OLED
#define SPLIT_LAYER_STATE_ENABLE
#define SPLIT_MODS_ENABLE
#define SPLIT_ACTIVITY_ENABLE
#define SPLIT_TRANSACTION_IDS_USER USER_SYNC_HOST

// Caps
#define BOTH_SHIFTS_TURNS_ON_CAPS_WORD

// Caps Lock is only sent as the OS layout hotkey, no need to hold it
#define TAP_HOLD_CAPS_DELAY 0

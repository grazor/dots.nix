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

// HMR
#define TAPPING_TERM 200
#define QUICK_TAP_TERM 0
#define CHORDAL_HOLD

// Combo
#define COMBO_STRICT_TIMER
#define COMBO_TERM 40

// Display
#define OLED_BRIGHTNESS 16

// Caps
#define BOTH_SHIFTS_TURNS_ON_CAPS_WORD

// Input lag
// https://keebsforall.com/blogs/mechanical-keyboards-101/reduce-keyboard-input-lag-with-qmk
//#define DEBOUNCE 3
//#define DEBOUNCE_TYPE symm
#define USB_POLLING_INTERVAL_MS 1
//#define QMK_KEYS_PER_SCAN 12
#define F_CPU 16000000
//#define DIODE_DIRECTION COL2ROW  // or ROW2COL based on your PCB design

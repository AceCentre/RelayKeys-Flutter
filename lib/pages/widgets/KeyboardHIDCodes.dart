import 'package:flutter/material.dart';
import 'package:relay_keys/consts/Const.dart';

const int LCTRL_BIT = 0x01;
const int LSHFT_BIT = 0x02;
const int LALT_BIT = 0x04;
const int LMETA_BIT = 0x08;
const int RCTRL_BIT = 0x10;
const int RSHFT_BIT = 0x20;
const int RALT_BIT = 0x40;
const int RMETA_BIT = 0x80;

const List<List<HidKey>> hidKeys = [
  [
    const HidKey(0x3a, 'F1'),
    const HidKey(0x3b, 'F2'),
    const HidKey(0x3c, 'F3'),
    const HidKey(0x3d, 'F4'),
    const HidKey(0x3e, 'F5'),
    const HidKey(0x3f, 'F6'),
    const HidKey(0x40, 'F7'),
    const HidKey(0x41, 'F8'),
  ],
  [
    const HidKey(0x29, 'Esc'),
    const HidKey(0x2b, 'Tab'),
    const HidKey(0x42, 'F9'),
    const HidKey(0x43, 'F10'),
    const HidKey(0x44, 'F11'),
    const HidKey(0x45, 'F12'),
    // const HidKey(0x4c, 'Del', 'Insert'),
    const HidKey(0x2a, 'Backspace'),
  ],
  [
    const HidKey(LSHFT_BIT, 'L-Shift', isSpecial: true),
    const HidKey(0x52, 'Up', secondary: 'PgUp', secondryCode: 0x4B),
    const HidKey(0x51, 'Down', secondary: 'PgDn', secondryCode: 0x4E),
    const HidKey(0x50, 'Left', secondary: 'home', secondryCode: 0x4A),
    const HidKey(0x4f, 'Right', secondary: 'End', secondryCode: 0x4D),
    const HidKey(RSHFT_BIT, 'R-Shift', isSpecial: true),
  ],
  [
    const HidKey(LCTRL_BIT, 'L-Ctrl', isSpecial: true),
    const HidKey(LALT_BIT, 'LAlt', isSpecial: true),
    const HidKey(0x33, ';', secondary: ':'),
    const HidKey(0x34, '\'', secondary: '\"'),
    const HidKey(0x38, '/', secondary: '?'),
    const HidKey(LALT_BIT, 'RAlt', isSpecial: true),
    const HidKey(RCTRL_BIT, 'R-Ctrl', isSpecial: true),
  ],
  [
    const HidKey(0x1e, '1', secondary: '!'),
    const HidKey(0x1f, '2', secondary: '@'),
    const HidKey(0x20, '3', secondary: '#'),
    const HidKey(0x21, '4', secondary: '\$'),
    const HidKey(0x22, '5', secondary: '%'),
    const HidKey(0x23, '6', secondary: '^'),
    const HidKey(0x24, '7', secondary: '&'),
    const HidKey(0x25, '8', secondary: '*'),
  ],
  [
    const HidKey(0x26, '9', secondary: '('),
    const HidKey(0x27, '0', secondary: ')'),
    const HidKey(0x36, ',', secondary: '<'),
    const HidKey(0x37, '.', secondary: '>'),
    const HidKey(0x31, '\\', secondary: '|'),
    const HidKey(0x2e, '=', secondary: '+'),
    const HidKey(0x2f, '[', secondary: '{'),
    const HidKey(0x30, ']', secondary: '}'),
  ],
  [
    const HidKey(0x04, 'A'),
    const HidKey(0x05, 'B'),
    const HidKey(0x06, 'C'),
    const HidKey(0x07, 'D'),
    const HidKey(0x08, 'E'),
    const HidKey(0x09, 'F'),
    const HidKey(0x0a, 'G'),
    const HidKey(0x0b, 'H'),
  ],
  [
    const HidKey(0x0c, 'I'),
    const HidKey(0x0d, 'J'),
    const HidKey(0x0e, 'K'),
    const HidKey(0x0f, 'L'),
    const HidKey(0x10, 'M'),
    const HidKey(0x11, 'N'),
    const HidKey(0x12, 'O'),
    const HidKey(0x13, 'P'),
  ],
  [
    const HidKey(0x14, 'Q'),
    const HidKey(0x15, 'R'),
    const HidKey(0x16, 'S'),
    const HidKey(0x17, 'T'),
    const HidKey(0x18, 'U'),
    const HidKey(0x19, 'V'),
    const HidKey(0x1a, 'W'),
    const HidKey(0x1b, 'X'),
  ],
  [
    const HidKey(0x1c, 'Y'),
    const HidKey(0x1d, 'Z'),
    const HidKey(0x2d, '-', secondary: '_'),
    const HidKey(0x39, 'Capslock'),
    const HidKey(0x2c, 'Space'),
    const HidKey(0x28, 'Enter'),
  ],
];

class HidKey {
  final int hidCode;
  final String primary;
  final String secondary;
  final int secondryCode;
  final bool isSpecial;

  const HidKey(this.hidCode, this.primary,
      {this.isSpecial = false, this.secondary, this.secondryCode});

  getBgColor(int value) =>
      (isSpecial && (value & hidCode) > 0) ? Const.primaryColor : null;

  getTxtColor(int value) =>
      (isSpecial && (value & hidCode) > 0) ? Colors.white : null;

  String getTxt(int value) {
    return (secondary != null) &&
            (((value & LSHFT_BIT) > 0) || ((value & RSHFT_BIT) > 0))
        ? secondary
        : primary;
  }
}

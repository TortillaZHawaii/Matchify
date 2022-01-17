import 'package:flutter/material.dart';

class ThemeProvider {
  static ThemeData buildTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: kMatchifyGreen100,
        onPrimary: kMachifyBrown900,
        secondary: kMatchifyBeige100,
        onSecondary: kMachifyBrown900,
        primaryVariant: kMatchifyBeige50,
        error: kMatchifyErrorRed,
        surface: kMatchifyBeige50,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: kMatchifyBeige50,
        selectedColor: kMatchifyBeige200,
      ),
    );
  }
}

const kMatchifyGreen50 = Color(0xffd1fc8e);
const kMatchifyGreen100 = Color(0xff9ec95e);
const kMatchifyGreen200 = Color(0xff6d982f);

const kMatchifyBeige50 = Color(0xffffffbe);
const kMatchifyBeige100 = Color(0xffede18d);
const kMatchifyBeige200 = Color(0xffb9af5e);

const kMachifyBrown900 = Color(0xff3b2d1f);
const kMatchifyErrorRed = Color(0xfff44336);
const kMatchifyBlack = Color(0xff000000);

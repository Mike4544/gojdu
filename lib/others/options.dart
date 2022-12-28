import 'package:flutter/material.dart';
import "package:gojdu/others/colors.dart";

class Misc {
  static String appName = "GojduApp";
  static String link = "https://teenstarapps.com";
  static String scoala = 'Colegiul National "Emanuil Gojdu"';

  static Map<String, Color> categories = {
    "Students": ColorsB.gray800,
    "Teachers": Colors.amber,
    "Parents": Colors.indigoAccent,
    "C. Elevilor": Colors.blue
  };

  static const int INT_MAX = 9223372036854775807;
  static const int INT_MIN = -9223372036854775808;

  // The values for lastMax and so on
  static int lastMax = -1;
  static int maxScrollCount = 10;
  static int turns = 10;
  static int lastID = INT_MAX;
}

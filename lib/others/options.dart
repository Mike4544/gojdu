import 'package:flutter/material.dart';
import "package:gojdu/others/colors.dart";
import 'package:gojdu/widgets/searchBar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:email_launcher/email_launcher.dart';

import '../pages/searchPage.dart';

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

  static const TextStyle defTextHighlightStyle =
      TextStyle(color: ColorsB.yellow500);

  static final BoxDecoration defHighlightStyle = BoxDecoration(
      color: ColorsB.yellow500.withOpacity(.25),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: ColorsB.yellow500.withOpacity(.5), width: 1));

  static void defSearch(
      String searchTerm, SearchType searchType, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchResultPage(
        searchType: searchType,
        searchTerm: searchTerm,
        filters: const [],
      );
    }));
  }

  static void openUrl(String url) async {
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "https://$url";
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void openPhone(String url) async {
    if (await canLaunch("tel://$url")) {
      await launch("tel://$url");
    } else {
      throw 'Could not launch $url';
    }
  }

  static void openEmail(String url) async {
    Email email = Email(to: [url], subject: 'subject', body: 'body');
    await EmailLauncher.launch(email);
  }

  // The values for lastMax and so on
  static int lastMax = -1;
  static int maxScrollCount = 10;
  static int turns = 10;
  static int lastID = INT_MAX;
}

//  Import material
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:gojdu/others/api.dart';

// Import colors from others/
import '../others/colors.dart';
import '../others/options.dart';

// This will be an extension of the RichText widget
// The main functionality will be highlighting of:
// - hashtags
// - links
// - phone numbers
// - emails
// etc.

class TextPP extends StatelessWidget {
  final String string;

  final TextStyle? defaultStyle;

  final TextStyle? textHighlightStyle;
  final BoxDecoration? highlightStyle;

  final Function(String tag)? onHashtagClick;
  final Function(String link)? onLinkClick;
  final Function(String number)? onPhoneClick;
  final Function(String email)? onEmailClick;

  const TextPP({
    Key? key,
    required this.string,
    this.defaultStyle,
    this.textHighlightStyle,
    this.highlightStyle,
    this.onHashtagClick,
    this.onLinkClick,
    this.onPhoneClick,
    this.onEmailClick,
  }) : super(key: key);

  final _defTextStyle =
      const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 16);

  List<InlineSpan> splitWords() {
    List<InlineSpan> textSpans = [];

    //  Create a regex to match hashtags
    final hashtagRegex = RegExp(r'#[a-zA-Z0-9]+');

    //  Create a regex to match links
    final linkRegex = RegExp(
        r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
        multiLine: true);

    //  Create a regex to match Romanian phone numbers
    final phoneRegex = RegExp(r'07[0-9]{8}');

    //  Create a regex to match emails
    final emailRegex =
        RegExp(r'([a-zA-Z0-9+._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)');

    List<Function(String)> regexFunctions = [
      onHashtagClick ?? (tag) {},
      onLinkClick ?? (tag) {},
      onPhoneClick ?? (tag) {},
      onEmailClick ?? (tag) {},
    ];

    List<RegExp> regexes = [
      hashtagRegex,
      linkRegex,
      phoneRegex,
      emailRegex,
    ];

    bool regexMatch(String word) {
      for (var rgex in regexes) {
        if (rgex.hasMatch(word)) {
          textSpans.add(WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: GestureDetector(
                onTap: () {
                  regexFunctions[regexes.indexOf(rgex)](word);
                },
                child: Container(
                  decoration: highlightStyle ?? Misc.defHighlightStyle,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                  child: Text(
                    "$word ",
                    style: textHighlightStyle ?? Misc.defTextHighlightStyle,
                  ),
                ),
              ),
            ),
          ));
          return true;
        }
      }

      return false;
    }

    // First split the text in paragraphs
    List<String> paragraphs = string.split('\n');

    for (String paragraph in paragraphs) {
      List<String> words = paragraph.split(' ');

      for (String word in words) {
        bool hasMatch = regexMatch(word);

        if (!hasMatch) {
          textSpans.add(TextSpan(
            text: "$word ",
            style: defaultStyle ?? _defTextStyle,
          ));
        }
      }
      textSpans.add(
        TextSpan(
          text: '\n',
          style: defaultStyle ?? _defTextStyle,
        ),
      );
    }

    return textSpans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: '',
            style: defaultStyle ?? _defTextStyle,
            children: splitWords()));
  }
}

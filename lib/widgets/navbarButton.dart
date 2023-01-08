//  Import material and colors
import 'package:flutter/material.dart';
import '../others/colors.dart';

//  Create a stateless widget
class NavbarButton extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final String text;
  final int currentIndex;
  final int index;
  const NavbarButton(
      {Key? key,
      required this.onTap,
      required this.icon,
      required this.text,
      required this.currentIndex,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap(),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon,
                          color: currentIndex == index
                              ? ColorsB.yellow500
                              : Colors.white),
                      Text(text,
                          style: TextStyle(
                              color: currentIndex == index
                                  ? ColorsB.yellow500
                                  : Colors.white,
                              fontSize: 7.5)),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

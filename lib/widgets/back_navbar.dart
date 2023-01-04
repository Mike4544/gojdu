import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/others/colors.dart';

class BackNavbar extends StatelessWidget {
  final int? variation;
  final VoidCallback? update;
  const BackNavbar({Key? key, this.variation, this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (variation == null) {
      return NavigationBar(
        backgroundColor: Colors.transparent,
        height: 50,
        destinations: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.only(
                // All 8, bottom: 16
                left: 8,
                right: 8,
                top: 8,
                bottom: 16,
              ),
              child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    RoundedTriangle.polygon_1,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  )),
            ),
          ),
          const SizedBox(),
          const SizedBox()
        ],
      );
    } else {
      return ClipPath(
        clipper: RoundedNavbar(),
        child: Container(
          color: ColorsB.yellow500,
          height: 90,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    if (update != null) {
                      update!();
                    }
                  },
                  icon: const Icon(
                    RoundedTriangle.polygon_1,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  )),
            ),
          ),
        ),
      );
    }
  }
}

class RoundedNavbar extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double down = 35;
    double radius = 0;

    Path path = Path()
      ..moveTo(radius, down)
      ..lineTo(size.width - 50, down)
      ..quadraticBezierTo(size.width - 5, down, size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, down + radius)
      ..quadraticBezierTo(0, down, radius, down)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

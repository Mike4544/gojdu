import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

class RoundedNavbar extends StatelessWidget {
  const RoundedNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);
    return Container(
      height: 75,
      width: device.size.width,
      decoration: BoxDecoration(
        color: ColorsB.gray800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.map),
          Icon(Icons.announcement),
          Icon(Icons.calendar_today)
        ],
      ),
    );
  }
}

//TODO: Make the functionality -Navbar

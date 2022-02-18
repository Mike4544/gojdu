import 'package:flutter/material.dart';
import 'package:gojdu/others/rounded_triangle.dart';

class BackNavbar extends StatelessWidget {
  const BackNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.transparent,
      height: 75,
      destinations: [
        TextButton.icon(onPressed: () {Navigator.pop(context);},
            icon: Icon(RoundedTriangle.polygon_1, color: Colors.white,),
            label: Text(
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
            )
        ),
        SizedBox(),
        SizedBox()
      ],
    );
  }
}

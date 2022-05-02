import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Import others/colors.dart
import 'package:gojdu/others/colors.dart';

class Verified extends StatelessWidget {
  const Verified({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsB.gray900,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SafeArea(
          child: Stack(
            children: [

              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 300,
                    child: SvgPicture.asset(
                      'assets/svgs/verified.svg',
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, 100),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Account verified! Welcome!',
                        style: TextStyle(
                          fontSize: 24,
                          color: ColorsB.yellow500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: Flexible(
                          child: Text(
                            'You can now use our app to receive announcements, explore our highschool and much more!',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(-100, -75),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Sweet!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),

                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                  ),
                ),
              ),


            ],
          )
        ),
      ),
    );
  }
}

// TODO: Complete the page and add the rest of the assets

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
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account verified! Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  color: ColorsB.yellow500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'You can now use our app to receive announcements, explore our highschool and much more!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              SizedBox(
                height: 300,
                child: SvgPicture.asset(
                  'assets/svgs/verified.svg',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: Complete the page and add the rest of the assets

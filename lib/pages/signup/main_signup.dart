import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/back_navbar.dart';

//Importing the signup pages
import 'package:gojdu/pages/signup/student.dart';
import 'package:gojdu/pages/signup/teacher.dart';
import 'package:gojdu/pages/signup/parent/parent_init.dart';

//Importing the transitions file
import 'package:gojdu/others/transitions.dart';

class SignupSelect extends StatelessWidget {
  const SignupSelect({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: ColorsB.gray900,
      bottomNavigationBar: const BackNavbar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: Column(
          children: [
            const Text(
              'Select your account type:',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 35,
                color: ColorsB.yellow500,
              ),
            ),

            const Divider(
              height: 25,
              thickness: 2,
              color: ColorsB.yellow500,
            ),

            SizedBox(
              height: device.size.height * 0.075,
            ),

            SizedBox(
              width: device.size.width*0.75,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(context, SlideRightRoute(page: StudentSignUp()));
                  },
                  child: const Text(
                      'Student',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w100,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontSize: 30,
                    ),
                  ),
                style: TextButton.styleFrom(
                  backgroundColor: ColorsB.yellow500,
                  padding: EdgeInsets.all(12.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )
                ),
              ),
            ),

            const SizedBox(height: 75),

            SizedBox(
              width: device.size.width*0.75,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, SlideRightRoute(page: ParentsSignupPage1()));
                },
                child: const Text(
                  'Parent',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 30,
                  ),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: ColorsB.yellow500,
                    padding: const EdgeInsets.all(12.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )
                ),
              ),
            ),

            const SizedBox(height: 75,),

            SizedBox(
              width: device.size.width*0.75,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, SlideRightRoute(page: TeacherSignUp()));
                },
                child: const Text(
                  'Teacher',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 30,
                  ),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: ColorsB.yellow500,
                    padding: const EdgeInsets.all(12.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}

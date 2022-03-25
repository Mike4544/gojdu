
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Importing the 'main' pages
import 'package:gojdu/pages/login.dart';
import 'package:gojdu/pages/news.dart';

//Import the main signup page
import 'package:gojdu/pages/signup/main_signup.dart';

//Importing the sub-signup pages
import 'package:gojdu/pages/signup/student.dart';
import 'package:gojdu/pages/signup/teacher.dart';
import 'package:gojdu/pages/signup/parent/parent_init.dart';


//Importing the splash screen
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() {
  
  FlutterNativeSplash.removeAfter(initialization);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(MaterialApp(

    theme: ThemeData(
      fontFamily: 'Nunito',
    ),

    onGenerateRoute: (settings) {
      switch(settings.name) {
        case '/signup/student':
          //return SlideRightRoute(page: StudentSignUp());
          break;
      }
    },


    initialRoute: '/',
    routes: {
      '/': (context) => const Login(),
      '/signup': (context) => const SignupSelect(),
      '/signup/student': (context) => const StudentSignUp(),
      '/signup/teachers': (context) => const TeacherSignUp(),
      'signup/parents/1': (context) => const ParentsSignupPage1(),
    },

    //TODO: Note to self: add the dependecy of 'NewsPage' to the rest of the pages.
  ));
}

void initialization(BuildContext context) async {
  await Future.delayed(Duration(seconds: 2));
}


// class SlideRightRoute extends PageRouteBuilder {
//   final Widget page;
//   SlideRightRoute({required this.page})
//       : super(
//     pageBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         ) =>
//     page,
//     transitionsBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         Widget child,
//         ) =>
//         SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(-1, 0),
//             end: Offset.zero,
//           ).animate(animation),
//           child: child,
//         ),
//   );
// }





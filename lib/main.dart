import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

//  Preferences
import 'package:shared_preferences/shared_preferences.dart';

//  HTTP
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import Connectivity
import 'package:connectivity_plus/connectivity_plus.dart';

// Firebase thingys
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Import the verified page
import 'package:gojdu/pages/verified.dart';

import 'package:gojdu/others/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './local_notif_service.dart';

String type = '';

Future<void> main() async {

  final LocalNotificationService _locNotifs = LocalNotificationService();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.requestPermission();

  final Widget homeWidget = await getPage();

  Paint.enableDithering = true;

  //FlutterNativeSplash.removeAfter(initialization);

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await _locNotifs.init();

  // SUBSCRIBING TO THE NOTIFICATIONS
  await messaging.subscribeToTopic(type + 's');
  await messaging.subscribeToTopic('all');

  await _locNotifs.showPeriodicNotification(
      id: 0,
      title: "Don't miss out!",
      body: "You might have new posts, events, opportunities or offers awaiting for you! Open the app and find out!",
      repeatInterval: RepeatInterval.weekly
  );


  runApp(ScreenUtilInit(
    designSize: const Size(412, 732),
    minTextAdapt: true,
    builder: (context, child){
      return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Nunito',
        ),

        home: homeWidget,
        routes: {
          '/login': (context) => const Login(),
          '/signup': (context) => const SignupSelect(),
          '/signup/student': (context) => const StudentSignUp(),
          '/signup/teachers': (context) => const TeacherSignUp(),
          'signup/parents/1': (context) => const ParentsSignupPage1(),
        },

        //TODO: Note to self: add the dependecy of 'NewsPage' to the rest of the pages.
      );
    },
  ));
}

void initialization(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2));
}

Future<Widget> getPage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print(prefs.getString('email').toString());

  String? token = await FirebaseMessaging.instance.getToken();

  if (!(prefs.getString('email') != null &&
      prefs.getString("password") != null)) {
    print(false);
    return const Login();
  } else {
    try {
      //print(true);
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/login_gojdu.php');
      final response = await http.post(url, body: {
        "email": prefs.getString('email').toString(),
        "password": prefs.getString('password').toString(),
        "token": token,
      });
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["error"]) {
          return const Login();
        } else {
          if (jsondata["success"]) {
            String fn = jsondata["first_name"].toString();
            String ln = jsondata["last_name"].toString();
            String email = jsondata["email"].toString();
            String acc_type = jsondata["account"].toString();
            //String acc_type = 'Teacher';

            final loginMap = {
              'first_name': fn,
              'last_name': ln,
              'email': email,
              'account': acc_type,
              'verification': jsondata['verification'],
              'id': jsondata['id'],
            };

            type = acc_type;
            await prefs.setString('type', type);

            return NewsPage(
              data: loginMap,
            );
          } else {
            return const Login();
          }
        }
      } else {
        return const Login();
      }
    } catch (e) {
      return const Login();
    }
    //return NewsPage(isAdmin: false);
  }
}

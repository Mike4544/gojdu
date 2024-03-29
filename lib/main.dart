import 'dart:async';

import '../others/options.dart';

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

//  Preferences
import 'package:shared_preferences/shared_preferences.dart';

//  HTTP
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import Connectivity

// Firebase thingys
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Import the verified page

import 'package:flutter_screenutil/flutter_screenutil.dart';

import './local_notif_service.dart';
import 'others/api.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

String type = '';

Future<void> main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final LocalNotificationService _locNotifs = LocalNotificationService();
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
    debug:
        false, // optional: set to false to disable printing logs to console (default: true)
    ignoreSsl:
        true, // optional: set to true if you want to ignore SSL certificate errors (default: false)
  );

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await FirebaseMessaging.instance.requestPermission();

    Paint.enableDithering = true;

    //FlutterNativeSplash.removeAfter(initialization);

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final Widget homeWidget = await getPage();

    m_debugPrint('TYPE: $type');

    //  await _locNotifs.init();

    // SUBSCRIBING TO THE NOTIFICATIONS
    await messaging.subscribeToTopic(type.replaceAll(' ', ''));
    await messaging.subscribeToTopic('all');

    // await _locNotifs.showPeriodicNotification(
    //     id: 0,
    //     title: "Don't miss out!",
    //     body: "You might have new posts, events, opportunities or offers awaiting for you! Open the app and find out!",
    //     repeatInterval: RepeatInterval.weekly
    // );

    runApp(ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      builder: (context, child) {
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
  } catch (e, s) {
    m_debugPrint(e);
    m_debugPrint(s);

    //  If topic recognition fails, ensure working app
    runApp(ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
          ),

          home: const Login(),
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
}

void initialization(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2));
}

ValueNotifier notifs = ValueNotifier(0);

Future<void> getNotifs(int id) async {
  try {
    final response = await http.post(
        Uri.parse("${Misc.link}/${Misc.appName}/getInitNotifs.php"),
        body: {'persID': '$id'});

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);

      notifs.value = jsondata['notifs'];
    }
  } catch (e, stack) {
    m_debugPrint(e.toString());
    m_debugPrint(stack.toString());
  }
}

Future<Widget> getPage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  m_debugPrint(prefs.getString('email').toString());

  String? token = await FirebaseMessaging.instance.getToken();

  if (!(prefs.getString('email') != null &&
      prefs.getString("password") != null)) {
    m_debugPrint(false.toString());
    return const Login();
  } else {
    try {
      //m_debugPrint(true);
      var url = Uri.parse('${Misc.link}/${Misc.appName}/login_gojdu.php');
      final response = await http.post(url, body: {
        "email": prefs.getString('email').toString(),
        "password": prefs.getString('password').toString(),
        "token": token,
      }).timeout(const Duration(seconds: 15));
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

            if (acc_type == 'Admin') {
              await getNotifs(loginMap['id']);
            }

            type = acc_type;
            await prefs.setString('type', type);
            await prefs.setString('first_name', fn);
            await prefs.setString('last_name', ln);
            await prefs.setString('email', email);

            return NewsPage(
              notifs: notifs,
              data: loginMap,
            );
          } else {
            return const Login();
          }
        }
      } else {
        return const Login();
      }
    } on TimeoutException {
      return const Login();
    } catch (e) {
      return const Login();
    }
    //return NewsPage(isAdmin: false);
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gojdu/others/api.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/widgets/back_navbar.dart';
//import 'package:gojdu/others/rounded_triangle.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gojdu/pages/news.dart';
//import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Firebase thingys
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gojdu/others/options.dart';

class AdminSignUp extends StatefulWidget {
  const AdminSignUp({Key? key}) : super(key: key);

  @override
  _AdminSignUpState createState() => _AdminSignUpState();
}

class _AdminSignUpState extends State<AdminSignUp> {
  // Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //Text controllers

  var _mail = TextEditingController();
  var _username = TextEditingController();
  var _lastname = TextEditingController();
  var _password = TextEditingController();
  var _repPassword = TextEditingController();
  var _schoolCode = TextEditingController();

  //  <---------------  Form key  ----------------->
  final _formKey = GlobalKey<FormState>();

  // <---------------- Error messages -------------->
  late String error;

  bool acceptedTerms = false;
  String termsError = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mail = TextEditingController();
    _username = TextEditingController();
    _lastname = TextEditingController();
    _password = TextEditingController();
    _repPassword = TextEditingController();

    error = '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _mail.dispose();
    _username.dispose();
    _lastname.dispose();
    _password.dispose();
    _repPassword.dispose();
    _schoolCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    var height = device.size.height < 675
        ? MediaQuery.of(context).size.height * .125
        : MediaQuery.of(context).size.height * .1;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorsB.gray900,
        bottomNavigationBar: const BackNavbar(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          toolbarHeight: height,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 35, 0, 0),
            child: Row(
              children: [
                const Text(
                  'Admin account',
                  style: TextStyle(
                    color: ColorsB.yellow500,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  color: ColorsB.yellow500,
                  width: 2.5,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: device.size.height * 0.05,
                  ),
                  const Text(
                    'Input your details below:',
                    style: TextStyle(
                      color: ColorsB.yellow500,
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
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
                  InputField(
                      fieldName: 'Email Address',
                      isPassword: false,
                      controller: _mail,
                      label: 'example@example.com',
                      errorMessage: error,
                      isEmail: true),
                  const SizedBox(
                    height: 50,
                  ),
                  InputField(
                    fieldName: 'First Name',
                    isPassword: false,
                    controller: _username,
                    errorMessage: error,
                    isEmail: false,
                    label: 'Ex: Mihai',
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InputField(
                    fieldName: 'Last Name',
                    isPassword: false,
                    controller: _lastname,
                    errorMessage: error,
                    isEmail: false,
                    label: 'Ex: Popescu',
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InputField(
                    fieldName: 'Password',
                    isPassword: true,
                    controller: _password,
                    errorMessage: error,
                    isEmail: false,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InputField(
                    fieldName: 'Repeat Password',
                    isPassword: true,
                    controller: _repPassword,
                    errorMessage: error,
                    isEmail: false,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InputField(
                    fieldName: 'Admin Code',
                    isPassword: false,
                    controller: _schoolCode,
                    errorMessage: error,
                    isEmail: false,
                    label: 'Ex: A1B2C3',
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(children: [
                    Checkbox(
                      activeColor: ColorsB.yellow500,
                      value: acceptedTerms,
                      onChanged: (nvalue) {
                        setState(() {
                          acceptedTerms = nvalue!;

                          termsError = "";
                        });
                      },
                    ),
                    RichText(
                      text: TextSpan(
                          text: 'I accept the ',
                          style: TextStyle(color: Colors.white.withOpacity(.5)),
                          children: [
                            TextSpan(
                                text: 'terms and conditions.',
                                style: const TextStyle(
                                    color: ColorsB.yellow500,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    if (await canLaunchUrl(Uri.parse(
                                        '${Misc.link}/${Misc.appName}/terms.html'))) {
                                      await launchUrl(
                                          Uri.parse(
                                              '${Misc.link}/${Misc.appName}/terms.html'),
                                          mode: LaunchMode.externalApplication);
                                    }
                                  })
                          ]),
                    )
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    termsError,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!acceptedTerms) {
                          setState(() {
                            termsError =
                                "Please accept the terms and conditions to further continue using the app.";
                          });

                          return;
                        }

                        termsError = "";

                        setState(() {});

                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                  child: SpinKitRing(
                                    color: ColorsB.yellow500,
                                  ),
                                ));

                        //await Future.delayed(Duration(seconds: 3));

                        final _prefs = await SharedPreferences.getInstance();
                        String? token = await _firebaseMessaging.getToken();

                        var url = Uri.parse(
                            '${Misc.link}/${Misc.appName}/register_admin.php');
                        final response = await http.post(url, body: {
                          "first_name": _username.value.text,
                          "last_name": _lastname.value.text,
                          "password_1": _password.value.text,
                          "password_2": _repPassword.value.text,
                          "email": _mail.value.text,
                          "code": _schoolCode.text,
                          "token": token,
                        });
                        m_debugPrint(response.statusCode);

                        if (response.statusCode == 200) {
                          var jsondata = await json.decode(response.body);
                          m_debugPrint(jsondata.toString());
                          if (jsondata["error"]) {
                            setState(() {
                              error = jsondata["message"];
                              Navigator.of(context).pop('dialog');
                            });
                          } else {
                            if (jsondata["success"]) {
                              //save the data returned from server
                              //and navigate to home page
                              String? user = jsondata["username"];
                              String? email = _mail.value.text;
                              String first_name = _username.value.text;
                              String last_name = _lastname.value.text;
                              String? acc_type = jsondata["account"];

                              _prefs.setString('email', email);
                              _prefs.setString('first_name', first_name);
                              _prefs.setString(
                                  'password', _password.value.text);
                              _prefs.setString('last_name', last_name);
                              _prefs.setString('type', acc_type!);

                              Navigator.of(context).pop('dialog');

                              final loginMap = {
                                'first_name': _username.value.text,
                                'last_name': _lastname.value.text,
                                'email': email,
                                'account': acc_type,
                                'verification': 'Verified',
                                'id': jsondata['id'],
                              };

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewsPage(
                                            notifs: ValueNotifier(0),
                                            data: loginMap,
                                            newlyCreated: true,
                                          )));

                              //user shared preference to save data
                            } else {
                              error = "Error connecting.";
                              Navigator.of(context).pop('dialog');
                            }
                          }
                        } else {
                          setState(() {
                            error = "wtf?";
                            Navigator.of(context).pop('dialog');
                          });
                        }

                        //TODO: Add funtionality to the student register button
                      }
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 2,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: ColorsB.yellow500,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(360))),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    //TODO: M: Make the student page.
  }
}

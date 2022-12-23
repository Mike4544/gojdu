import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/styled_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gojdu/pages/news.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase thingys
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gojdu/others/options.dart';

import '../../../others/api.dart';

String? fntopass;
String? lntopass;
String? email1topass;
String? pass1topass;
String? pass2topass;
String? email2topass;

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class ParentsSignupPage1 extends StatefulWidget {
  const ParentsSignupPage1({Key? key}) : super(key: key);

  @override
  _ParentsSignupPage1State createState() => _ParentsSignupPage1State();
}

class _ParentsSignupPage1State extends State<ParentsSignupPage1> {
  bool firstPage = true;

  void _update(bool fPage) {
    setState(() {
      firstPage = fPage;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstPage = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          elevation: 0,
          toolbarHeight: height,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 35, 0, 0),
            child: Row(
              children: [
                const Text(
                  'Parent account',
                  style: TextStyle(
                    color: ColorsB.yellow500,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(
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
        body: AnimatedSwitcher(
            //Changing the screens. The update function makes it possible for a class to modify the value of a parent.
            duration: Duration(seconds: 1),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
                    .animate(
                        CurvedAnimation(parent: animation, curve: Curves.ease)),
              );
            },
            child: firstPage
                ? FirstPage(
                    key: Key('1'),
                    update: _update,
                  )
                : SecondPage(
                    key: Key('2'),
                  )),
      ),
    );

    //TODO: M: Make the parents signup page (1/2).
  }
}

class FirstPage extends StatefulWidget {
  final ValueChanged<bool>? update;

  const FirstPage({Key? key, this.update}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  //Text controllers

  var _mail = TextEditingController();
  var _username = TextEditingController();
  var _lastname = TextEditingController();
  var _password = TextEditingController();
  var _repPassword = TextEditingController();

  var error = "";

  //  <---------------  Form key  --------------------->
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mail = TextEditingController();
    _username = TextEditingController();
    _lastname = TextEditingController();
    _password = TextEditingController();
    _repPassword = TextEditingController();
  }

  var acceptedTerms = false;
  var termsError = "";

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _mail.dispose();
    _username.dispose();
    _lastname.dispose();
    _password.dispose();
    _repPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
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
                errorMessage: '',
                isEmail: true,
              ),
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
                errorMessage: '',
                isEmail: false,
              ),
              const SizedBox(
                height: 50,
              ),
              InputField(
                fieldName: 'Repeat Password',
                isPassword: true,
                controller: _repPassword,
                errorMessage: '',
                isEmail: false,
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
                    await Future.delayed(const Duration(seconds: 3));
                    fntopass = _username.value.text;
                    lntopass = _lastname.value.text;
                    email1topass = _mail.value.text;
                    pass1topass = _password.value.text;
                    pass2topass = _repPassword.value.text;
                    m_debugPrint('Done');
                    Navigator.of(context).pop('dialog');

                    setState(() {
                      widget.update!(false);
                    });
                  }

                  //Butonu de continue la parinti
                  //Dupa cum ai obs, am adaugat loading-uri
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: ColorsB.yellow500,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 2,
                      fontSize: 30,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(360),
                      side: const BorderSide(
                        color: ColorsB.yellow500,
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  var _containerHeight = ValueNotifier<double>(0);
  bool open = false;

  AnimateIconController _iconController = AnimateIconController();

  var _childUsername = TextEditingController();

  //  <-------------  Error Text  ---------------------->
  String _errorText = '';
  //  <---------------  Form key  --------------------->
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _containerHeight = ValueNotifier<double>(0);
    _iconController = AnimateIconController();
    open = false;
    _errorText = '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _containerHeight.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "One more thing...",
                style: TextStyle(
                  color: ColorsB.yellow500,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(
                height: 25,
                thickness: 2,
                color: ColorsB.yellow500,
              ),
              SizedBox(
                height: device.size.height * 0.025,
              ),
              const Text(
                "Before you can create your account, please input your child's email below.",
                style: TextStyle(
                  color: ColorsB.yellow500,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(
                height: device.size.height * 0.1,
              ),
              InputField(
                  fieldName: 'Child\'s email',
                  isPassword: false,
                  controller: _childUsername,
                  isEmail: true,
                  errorMessage: _errorText),
              SizedBox(
                height: device.size.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      final _prefs = await SharedPreferences.getInstance();

                      if (_formKey.currentState!.validate()) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                  child: SpinKitRing(
                                    color: ColorsB.yellow500,
                                  ),
                                ));

                        email2topass = _childUsername.value.text;

                        m_debugPrint(fntopass);
                        m_debugPrint(lntopass);
                        m_debugPrint(pass1topass);
                        m_debugPrint(pass2topass);
                        m_debugPrint(email1topass);
                        m_debugPrint(email2topass);

                        _prefs.setString('email', email1topass!);
                        _prefs.setString('first_name', fntopass!);
                        _prefs.setString('last_name', lntopass!);
                        _prefs.setString('password', pass1topass!);
                        _prefs.setString('type', 'Parent');
                        String? token = await _firebaseMessaging.getToken();

                        var url = Uri.parse(
                            '${Misc.link}/${Misc.appName}/register_parent.php');
                        final response = await http.post(url, body: {
                          "first_name": fntopass,
                          "last_name": lntopass,
                          "password_1": pass1topass,
                          "password_2": pass2topass,
                          "email": email1topass,
                          "kid": email2topass,
                          "token": token,
                        });
                        if (response.statusCode == 200) {
                          m_debugPrint(response.statusCode.toString());
                          var jsondata = json.decode(response.body);
                          if (jsondata["error"]) {
                            setState(() {
                              _errorText = jsondata["message"];
                              Navigator.of(context).pop('dialog');
                            });
                          } else {
                            if (jsondata["success"]) {
                              //save the data returned from server
                              //and navigate to home page
                              String? user = jsondata["username"];
                              String? email = jsondata["email"];
                              String? acc_type = jsondata["account"];
                              String? kid = jsondata["kid"];
                              Navigator.of(context).pop('dialog');

                              final loginMap = {
                                'first_name': fntopass,
                                'last_name': lntopass,
                                'email': email,
                                'account': acc_type,
                                'verification': jsondata['verification'],
                                'id': jsondata['id'],
                              };

                              await _firebaseMessaging
                                  .subscribeToTopic('Parents');
                              await _firebaseMessaging.subscribeToTopic('all');

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
                              _errorText = "Error connecting.";
                              //m_debugPrint(jsondata.toString());
                              Navigator.of(context).pop('dialog');
                            }
                          }
                        } else {
                          setState(() {
                            _errorText = "wtf?";
                            Navigator.of(context).pop('dialog');
                          });
                        }

                        //TODO: Add funtionality to the student register button
                      }
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Text("Finish",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Nunito',
                            letterSpacing: 2.5,
                          )),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: ColorsB.yellow500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: device.size.height * 0.05,
              ),
              StyledDropdown(
                containerHeight: _containerHeight,
                device: device,
                sopen: open,
                title:
                    'We require parents\' and students\' accounts to be linked.',
                description:
                    'To keep third-parties from making fake accounts of parents, we require this type of account to be verified.',
                controller: _iconController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

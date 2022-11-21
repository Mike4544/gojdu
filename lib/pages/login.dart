import 'dart:async';
import 'dart:convert';
import 'package:gojdu/pages/verified.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/pages/news.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gojdu/pages/forgot_password.dart';

// Messaging token
import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:gojdu/others/options.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class _LoginState extends State<Login> {
  //Username and password 'submiters'
  final _nameController =
      ValueNotifier<TextEditingController>(TextEditingController());
  final _passController =
      ValueNotifier<TextEditingController>(TextEditingController());

  //  <-------------------------  Prefs Files ------------------>
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  //Transition width and height
  final _tWidth = ValueNotifier<double>(0);
  final _tHeight = ValueNotifier<double>(0);
  final _radius = ValueNotifier<double>(360);

  //  <------------- Form Key ---------------->
  final _formKey = GlobalKey<FormState>();

  //  <-----------  Error Strings  ------------>
  late String nameError;

  //  <-------------- Global size --------------->
  late Size globalSize;

  //  <-------------  Login Indicator ------------>
  bool isLoggingIn = false;

  @override
  void initState() {
    nameError = '';
    isLoggingIn = false;

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      if (message.data['type'] == 'Verify') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Verified()));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: D/M: Add more to dispose if necessary
    super.dispose();
    _nameController.dispose();
    _passController.dispose();

    debugPrint('disposed');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("building");

    var size = MediaQuery.of(context);
    globalSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: ColorsB.gray900,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 100, horizontal: 20), //Padding
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Logo.png',
                      height: 300,
                    ),
                    SizedBox(
                      height: size.size.height * 0.10,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputField(
                            fieldName: "Email",
                            isPassword: false,
                            controller: _nameController.value,
                            errorMessage: nameError,
                            isEmail: true,
                          ),

                          const SizedBox(height: 50),

                          InputField(
                            fieldName: "Password",
                            isPassword: true,
                            controller: _passController.value,
                            errorMessage: nameError,
                            isEmail: false,
                          ),

                          //TODO: Make the error text pop only on sign-in

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPassword()));
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: Text(
                                "Forgot your password?",
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: ColorsB.gray700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _passController.value,
                      builder: (_, value, __) => TextButton(
                        onPressed: (_nameController.value.text.isNotEmpty &&
                                    _passController.value.text.isNotEmpty) ||
                                isLoggingIn
                            ? login
                            : null,
                        style: TextButton.styleFrom(
                            backgroundColor:
                                _nameController.value.text.isNotEmpty &&
                                        _passController.value.text.isNotEmpty
                                    ? ColorsB.yellow500
                                    : ColorsB.gray800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            shadowColor: ColorsB.yellow500.withOpacity(0.25),
                            elevation: _nameController.value.text.isNotEmpty &&
                                    _passController.value.text.isNotEmpty
                                ? 15
                                : 0),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: !isLoggingIn
                                ? const Text("Sign-in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Nunito',
                                      letterSpacing: 2.5,
                                    ))
                                : const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorsB.gray900),
                                  )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text(
                            'or',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 12.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign-Up',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: ColorsB.yellow500,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Center(
              child: ValueListenableBuilder(
            valueListenable: _tWidth,
            builder: (_, width, __) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: _tWidth.value,
              height: _tHeight.value,
              onEnd: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewsPage(
                              data: loginInfo,
                              notifs: notifs,
                            ))

                    //TODO: Remove the hardcoded value

                    );
              },
              decoration: BoxDecoration(
                color: ColorsB.gray900,
                borderRadius: BorderRadius.circular(_radius.value),
              ),
            ),
          )),
        ],
      ),
    );
  }

  late Map loginInfo;
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
      debugPrint(e.toString());
      debugPrint(stack.toString());
    }
  }

  Future<void> login() async {
    //  TODO: Pass the login info gen

    final SharedPreferences prefs2 = await prefs;

    String? token = await _firebaseMessaging.getToken();
    //debugPrint(token);

    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoggingIn = true;
        });

        var url = Uri.parse('${Misc.link}/${Misc.appName}/login_gojdu.php');
        final response = await http.post(url, body: {
          "email": _nameController.value.text,
          "password": _passController.value.text,
          "token": token,
        }).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          var jsondata1 = json.decode(response.body);
          debugPrint(jsondata1);
          if (jsondata1["error"]) {
            if (jsondata1['message'] ==
                'Your account is still pending. Check your email and activate it.') {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    TextEditingController _code = TextEditingController();
                    GlobalKey _formKey1 = GlobalKey<FormState>();

                    return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: ColorsB.gray900,
                        title: Column(
                          children: const [
                            Text(
                              'Verify your email',
                              style: TextStyle(
                                  color: ColorsB.yellow500, fontSize: 15),
                            ),
                            Divider(
                              color: ColorsB.yellow500,
                              thickness: 1,
                              height: 10,
                            )
                          ],
                        ),
                        content: SizedBox(
                          height: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'A code has been sent to your email. Please enter it here and verify your account!',
                                style: TextStyle(
                                    color: ColorsB.yellow500, fontSize: 15),
                              ),
                              const SizedBox(height: 10),
                              Form(
                                key: _formKey1,
                                child: TextFormField(
                                  cursorColor: ColorsB.yellow500,
                                  controller: _code,
                                  decoration: InputDecoration(
                                      filled: true,
                                      labelText: "Enter Code",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 7.5),
                                      fillColor: ColorsB.gray200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: BorderSide.none)),
                                  validator: (pwrd) {
                                    if (pwrd!.isEmpty) {
                                      return "This field cannot be empty.";
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    var url = Uri.parse(
                                        '${Misc.link}/${Misc.appName}/verify_accounts.php');
                                    final response = await http.post(url,
                                        body: {
                                          'email': _nameController.value.text,
                                          'code': _code.text
                                        });
                                    debugPrint(response.statusCode.toString());
                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);
                                      //  debugPrint(jsondata);
                                      if (jsondata['success']) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          backgroundColor: ColorsB.yellow500,
                                          content: Text(
                                            'Account verified!',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito'),
                                          ),
                                        ));

                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        await _firebaseMessaging
                                            .subscribeToTopic(
                                                jsondata["account"].toString());
                                        await _firebaseMessaging
                                            .subscribeToTopic('all');

                                        String fn =
                                            jsondata1["first_name"].toString();
                                        String ln =
                                            jsondata1["last_name"].toString();
                                        String email =
                                            jsondata1["email"].toString();
                                        String acc_type =
                                            jsondata1["account"].toString();

                                        final loginMap = {
                                          'first_name': fn,
                                          'last_name': ln,
                                          'email': email,
                                          'account': acc_type,
                                          'verification': 'Verified',
                                          'id': jsondata['id'],
                                        };

                                        await prefs2.setString('email', email);
                                        await prefs2.setString('password',
                                            _passController.value.text);
                                        await prefs2.setString(
                                            'first_name', fn);
                                        await prefs2.setString('last_name', ln);
                                        await prefs2.setString(
                                            'type', acc_type);

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => NewsPage(
                                                      notifs: notifs,
                                                      data: loginMap,
                                                      newlyCreated: true,
                                                    )));
                                      }
                                      if (jsondata['error']) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'The code might be incorrect!',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito'),
                                          ),
                                        ));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          'Something went wrong!',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Nunito'),
                                        ),
                                      ));
                                    }
                                  }

                                  //  logoff(context);
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: ColorsB.yellow500,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  height: 50,
                                  width: 75,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ));
                  });
            } else {
              setState(() {
                isLoggingIn = false;
                nameError = jsondata1["message"];
              });
            }
          } else {
            if (jsondata1["success"]) {
              //save the data returned from server
              //and navigate to home page
              String fn = jsondata1["first_name"].toString();
              String ln = jsondata1["last_name"].toString();
              String email = jsondata1["email"].toString();
              String acc_type = jsondata1["account"].toString();
              //String acc_type = 'Teacher';

              // debugPrint(ln);
              // debugPrint(fn);
              // debugPrint(email);
              debugPrint(jsondata1["token"]);

              await prefs2.setString('email', email);
              await prefs2.setString('password', _passController.value.text);
              await prefs2.setString('first_name', fn);
              await prefs2.setString('last_name', ln);
              await prefs2.setString('type', acc_type);

              debugPrint(
                  "The name is ${_nameController.value.text} and the password is ${_passController.value.text}");

              await _firebaseMessaging.subscribeToTopic('${acc_type}s');
              await _firebaseMessaging.subscribeToTopic('all');

              setState(() {
                isLoggingIn = false;
              });

              final loginMap = {
                'first_name': fn,
                'last_name': ln,
                'email': email,
                'account': acc_type,
                'verification': jsondata1['verification'],
                'id': jsondata1['id'],
              };

              if (acc_type == 'Admin') {
                await getNotifs(loginMap['id']);
              }

              loginInfo = loginMap;

              _tWidth.value = globalSize.width;
              _tHeight.value = globalSize.height;
              _radius.value = 0;
              //user shared preference to save data
            } else {
              isLoggingIn = false;
              nameError = "Something went wrong.";
              setState(() {});
            }
          }
        } else {
          setState(() {
            isLoggingIn = false;
            nameError = "Error during connecting to server.";
          });
        }
      } on TimeoutException {
        setState(() {
          isLoggingIn = false;
          nameError = "Error during connecting to server.";
        });
        throw Future.error('Timeout');
      } catch (e) {
        setState(() {
          isLoggingIn = false;
          nameError = "Error during connecting to server.";
        });
      }
    }
  }
}

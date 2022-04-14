import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/pages/news.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //Username and password 'submiters'
  final _nameController = ValueNotifier<TextEditingController>(
      TextEditingController());
  final _passController = ValueNotifier<TextEditingController>(
      TextEditingController());

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
    super.initState();

  }


  @override
  void dispose() {
    // TODO: D/M: Add more to dispose if necessary
    super.dispose();
    _nameController.dispose();
    _passController.dispose();

    print('disposed');
  }

  @override
  Widget build(BuildContext context) {
    print("building");

    var size = MediaQuery.of(context);
    globalSize = MediaQuery
        .of(context)
        .size;

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset('assets/images/Logo.png'),
                        SizedBox(height: size.size.height * 0.20,),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InputField(fieldName: "Email",
                                isPassword: false,
                                controller: _nameController.value,
                                errorMessage: nameError,
                                isStudent: false,
                                isEmail: true,),

                              const SizedBox(height: 50),

                              InputField(fieldName: "Password",
                                isPassword: true,
                                controller: _passController.value,
                                errorMessage: nameError,
                                isEmail: false,),

                              //TODO: Make the error text pop only on sign-in

                              GestureDetector(
                                onTap: () {},
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


                        const SizedBox(height: 50,),

                        ValueListenableBuilder(
                          valueListenable: _passController.value,
                          builder: (_, value, __) =>
                              TextButton(
                                onPressed: (_nameController.value.text
                                    .isNotEmpty &&
                                    _passController.value.text.isNotEmpty) || isLoggingIn
                                    ? login
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 30),
                                  child: !isLoggingIn ? const Text(
                                      "Sign-in",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Nunito',
                                        letterSpacing: 2.5,
                                      )
                                  ) :
                                  const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(ColorsB.gray900),
                                  )
                                ),
                                style: TextButton.styleFrom(
                                    backgroundColor: _nameController.value.text
                                        .isNotEmpty &&
                                        _passController.value.text.isNotEmpty
                                        ? ColorsB.yellow500
                                        : ColorsB.gray800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    shadowColor: ColorsB.yellow500.withOpacity(0.25),
                                    elevation: _nameController.value.text
                                        .isNotEmpty &&
                                        _passController.value.text.isNotEmpty
                                        ? 15
                                        : 0
                                ),
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
                  ],
                ),
              ),
            ),
          ),

          Center(
              child: ValueListenableBuilder(
                valueListenable: _tWidth,
                builder: (_, width, __) =>
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: _tWidth.value,
                      height: _tHeight.value,
                      onEnd: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => NewsPage(data: loginInfo,))

                          //TODO: Remove the hardcoded value

                        );
                      },
                      decoration: BoxDecoration(
                        color: ColorsB.gray900,
                        borderRadius: BorderRadius.circular(_radius.value),
                      ),
                    ),
              )
          ),

        ],
      ),
    );
  }

  late Map loginInfo;

  void login() async {
    //  TODO: Pass the login info gen

    final SharedPreferences prefs2 = await prefs;

    if (_formKey.currentState!.validate()) {

      setState(() {
        isLoggingIn = true;
      });

      var url = Uri.parse('https://automemeapp.com/login_gojdu.php');
      final response = await http.post(url, body: {
        "email": _nameController.value.text,
        "password": _passController.value.text,
      });
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["error"]) {
          setState(() {
            isLoggingIn = false;
            nameError = jsondata["message"];
          });
        } else {
          if (jsondata["success"]) {
            //save the data returned from server
            //and navigate to home page
            String fn = jsondata["first_name"].toString();
            String ln = jsondata["last_name"].toString();
            String email = jsondata["email"].toString();
            String acc_type = jsondata["account"].toString();
            //String acc_type = 'Teacher';

            print(ln);
            print(fn);
            print(email);

            await prefs2.setString('email', email);
            await prefs2.setString('password', _passController.value.text);
            await prefs2.setString('first_name', fn);
            await prefs2.setString('last_name', ln);

            print("The name is ${_nameController.value
                .text} and the password is ${_passController.value.text}");
            //TODO: D: Send info to the server - Darius fa-ti magia
            //TODO: M: Make page transition animation
            /*TODO: M/D: Make a 'remember me' check.
                                        We wouldn't want to make the users uncomfy UwU
                                 */
            setState(() {
              isLoggingIn = false;
            });

            final loginMap = {
              'first_name': fn,
              'last_name': ln,
              'email': email,
              'account': acc_type,
            };

            loginInfo = loginMap;

            _tWidth.value = globalSize.width;
            _tHeight.value = globalSize.height;
            _radius.value = 0;
            //user shared preference to save data
          } else {
            isLoggingIn = false;
            nameError = "Something went wrong.";
            setState(() {

            });
          }
        }
      } else {
        setState(() {
          isLoggingIn = false;
          nameError = "Error during connecting to server.";
        });
      }
    }
  }

}
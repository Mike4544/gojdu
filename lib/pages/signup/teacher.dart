import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/styled_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Firebase thingys
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TeacherSignUp extends StatefulWidget {
  const TeacherSignUp({Key? key}) : super(key: key);

  @override
  _TeacherSignUpState createState() => _TeacherSignUpState();
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class _TeacherSignUpState extends State<TeacherSignUp> {

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
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 35, 0, 0),
            child: Row(
              children: [
                const Text(
                  'Teacher account',
                  style: TextStyle(
                    color: ColorsB.yellow500,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(width: 10,),

                Container(
                  color: ColorsB.yellow500,
                  width: 2.5,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
        body: AnimatedSwitcher( //Changing the screens. The update function makes it possible for a class to modify the value of a parent.
          duration: Duration(seconds: 1),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
              position: Tween<Offset>(
                  begin: Offset(1, 0),
                  end: Offset.zero
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.ease)
              ),
            );
          },
          child: firstPage ?
              FirstPage(
                key: Key('1'),
                update: _update,
              )
              : SecondPage(
            key: Key('2'),
          )
        ),
      ),
    );
  }
}

//TODO: M: Make the teachers' page (signup)


//First page of the signup

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

  //  <---------------- Form global key ------------------->
  final _formKey = GlobalKey<FormState>();

  var error = '';


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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _mail.dispose();
    _username.dispose();
    _password.dispose();
    _repPassword.dispose();

  }



  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Form(
          key: _formKey,

          child: Column(
            children: [


              SizedBox(height: device.size.height * 0.05,),

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

              InputField(fieldName: 'Email Address', isPassword: false, controller: _mail, label: 'example@example.com', isEmail: true, isStudent: false, errorMessage: ''),

              const SizedBox(height: 50,),

              InputField(fieldName: 'First Name', isPassword: false, controller: _username, errorMessage: error, isEmail: false, label: 'Ex: Mihai',),

              const SizedBox(height: 50,),

              InputField(fieldName: 'Last Name', isPassword: false, controller: _lastname, errorMessage: error, isEmail: false, label: 'Ex: Popescu',),

              const SizedBox(height: 50,),

              InputField(fieldName: 'Password', isPassword: true, controller: _password, isEmail: false, errorMessage: ''),

              const SizedBox(height: 50,),

              InputField(fieldName: 'Repeat Password', isPassword: true, controller:  _repPassword, isEmail: false, errorMessage: ''),

              const SizedBox(height: 100,),

              TextButton(
                onPressed: () async {
                  if(_formKey.currentState!.validate()){
                    showDialog(context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                        const Center(
                          child: SpinKitRing(
                            color: ColorsB.yellow500,
                          ),
                        )
                    );
                    //await Future.delayed(Duration(seconds: 3));
                    final _prefs = await SharedPreferences.getInstance();
                    String? token = await _firebaseMessaging.getToken();

                    var url = Uri.parse('https://automemeapp.com/gojdu/register_teacher.php');
                    final response = await http.post(url, body: {
                      "first_name": _username.value.text,
                      "last_name": _lastname.value.text,
                      "password_1": _password.value.text,
                      "password_2": _repPassword.value.text,
                      "email": _mail.value.text,
                      "token": token
                    });
                    print(response.statusCode);
                    if(response.statusCode == 200){
                      var jsondata = json.decode(response.body);
                      if(jsondata["error"]){
                        setState(() {
                          error = jsondata["message"];
                          Navigator.of(context).pop('dialog');
                        });
                      }else{
                        if(jsondata["success"]){
                          //save the data returned from server
                          //and navigate to home page
                          String? user = jsondata["username"];
                          String? email = jsondata["email"];
                          String? acc_type = jsondata["account"];
                          String first_name = jsondata["first_name"];
                          String last_name = jsondata["last_name"];

                          _prefs.setString('email', email!);
                          _prefs.setString('first_name', first_name);
                          _prefs.setString('last_name', last_name);

                          print(acc_type.toString());
                          Navigator.of(context).pop('dialog');

                          final loginMap = {
                            "username": user,
                            "email": email,
                            "account": acc_type,

                          };

                          widget.update!(false);
                          //user shared preference to save data
                        }else{
                          error = "Error connecting.";
                          Navigator.of(context).pop('dialog');
                        }
                      }
                    }else{
                      setState(() {
                        error = "wtf?";
                        Navigator.of(context).pop('dialog');

                      });
                    }



                    //TODO: Add funtionality to the student register button
                  }
                 //widget.update!(false);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child:Text(
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
                      side: BorderSide(
                        color: ColorsB.yellow500,
                      ),
                    )
                ),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _containerHeight = ValueNotifier<double>(0);
    _iconController = AnimateIconController();
    open = false;
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
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Your account has been created!",
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
              "Before you can access it though it must undergo verification by the school staff.",
              style: TextStyle(
                color: ColorsB.yellow500,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),

            SizedBox(
              height: device.size.height * 0.1,
            ),

            StyledDropdown(containerHeight: _containerHeight, device: device, sopen: open, title: 'We require teacher accounts to be verified',
            description: 'To keep third-parties from making fake accounts of various teachers, we require this type of account to be verified.',
              controller: _iconController,
            ),


          ],
        ),
      ),
    );
  }
}






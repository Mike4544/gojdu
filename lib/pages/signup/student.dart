import 'package:flutter/material.dart';
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

class StudentSignUp extends StatefulWidget {
  const StudentSignUp({Key? key}) : super(key: key);

  @override
  _StudentSignUpState createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {

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

    var height = device.size.height < 675 ? MediaQuery.of(context).size.height * .125 : MediaQuery.of(context).size.height * .1;

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
                  'Student account',
                  style: TextStyle(
                    color: ColorsB.yellow500,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(width: 10,),

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

                  InputField(fieldName: 'Email Address', isPassword: false, controller: _mail, label: 'example@example.com', errorMessage: error, isEmail: true),

                  const SizedBox(height: 50,),

                  InputField(fieldName: 'First Name', isPassword: false, controller: _username, errorMessage: error, isEmail: false, label: 'Ex: Mihai',),

                  const SizedBox(height: 50,),

                  InputField(fieldName: 'Last Name', isPassword: false, controller: _lastname, errorMessage: error, isEmail: false, label: 'Ex: Popescu',),

                  const SizedBox(height: 50,),

                  InputField(fieldName: 'Password', isPassword: true, controller: _password, errorMessage: error, isEmail: false,),

                  const SizedBox(height: 50,),

                  InputField(fieldName: 'Repeat Password', isPassword: true, controller:  _repPassword, errorMessage: error, isEmail: false,),

                  const SizedBox(height: 50,),

                  InputField(fieldName: 'School Code', isPassword: false, controller: _schoolCode, errorMessage: error, isEmail: false, label: 'Ex: A1B2C3',),

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

                        var url = Uri.parse('https://cnegojdu.ro/GojduApp/register_student.php');
                        final response = await http.post(url, body: {
                          "first_name": _username.value.text,
                          "last_name": _lastname.value.text,
                          "password_1": _password.value.text,
                          "password_2": _repPassword.value.text,
                          "email": _mail.value.text,
                          "code": _schoolCode.text,
                          "token": token,
                        });
                        if(response.statusCode == 200){
                          var jsondata = await json.decode(response.body);
                          print(jsondata);
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
                              String? email =  _mail.value.text;
                              String first_name = _username.value.text;
                              String last_name = _lastname.value.text;
                              String? acc_type = jsondata["account"];

                              _prefs.setString('email', email);
                              _prefs.setString('first_name', first_name);
                              _prefs.setString('password', _password.value.text);
                              _prefs.setString('last_name', last_name);
                              _prefs.setString('type', acc_type!);

                              Navigator.of(context).pop('dialog');


                              final loginMap = {
                                'first_name': _username.value.text,
                                'last_name': _lastname.value.text,
                                'email': email,
                                'account': acc_type,
                                'verification': jsondata['verification'],
                                'id': jsondata['id'],
                              };

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {

                                  TextEditingController _code = TextEditingController();
                                  GlobalKey _formKey1 = GlobalKey<FormState>();


                                  return  AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      backgroundColor: ColorsB.gray900,
                                      title: Column(
                                        children: const [
                                          Text(
                                            'Verify your email',
                                            style: TextStyle(
                                                color: ColorsB.yellow500,
                                                fontSize: 15
                                            ),
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
                                                  color: ColorsB.yellow500,
                                                  fontSize: 15
                                              ),
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
                                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7.5),
                                                    fillColor: ColorsB.gray200,
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(50),
                                                        borderSide: BorderSide.none
                                                    )
                                                ),
                                                validator: (pwrd){
                                                  if(pwrd!.isEmpty) {
                                                    return "This field cannot be empty.";
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            InkWell(
                                              onTap: () async {

                                                if(_formKey.currentState!.validate()) {

                                                  var url = Uri.parse(
                                                      'https://cnegojdu.ro/GojduApp/verify_accounts.php');
                                                  final response = await http.post(url, body: {
                                                    'email': email,
                                                    'code': _code.text
                                                  });
                                                  print(response.statusCode);
                                                  if(response.statusCode == 200){
                                                    var jsondata = json.decode(response.body);

                                                    if(jsondata['success']){


                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                        backgroundColor: ColorsB.yellow500,
                                                        content: Text(
                                                          'Account verified!',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: 'Nunito'
                                                          ),
                                                        ),
                                                      ));

                                                      await Future.delayed(const Duration(milliseconds: 500));
                                                      await _firebaseMessaging.subscribeToTopic('Students');
                                                      await _firebaseMessaging.subscribeToTopic('all');

                                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                                          builder: (context) => NewsPage(data: loginMap, newlyCreated: true,)
                                                      ));


                                                    }
                                                    if(jsondata['error']){
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                        backgroundColor: Colors.red,
                                                        content: Text(
                                                          'The code might be incorrect!',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: 'Nunito'
                                                          ),
                                                        ),
                                                      ));

                                                    }
                                                  }
                                                  else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                      backgroundColor: Colors.red,
                                                      content: Text(
                                                        'Something went wrong!',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'Nunito'
                                                        ),
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
                                                  Icons.check, color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                  );
                                }
                              );
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



                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child:Text(
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
                            borderRadius: BorderRadius.circular(360)
                        )
                    ),
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
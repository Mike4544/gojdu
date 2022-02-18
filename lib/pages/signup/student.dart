import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/others/rounded_triangle.dart';

class StudentSignUp extends StatefulWidget {
  const StudentSignUp({Key? key}) : super(key: key);

  @override
  _StudentSignUpState createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {

  //Text controllers

  var _mail = TextEditingController();
  var _username = TextEditingController();
  var _password = TextEditingController();
  var _repPassword = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mail = TextEditingController();
    _username = TextEditingController();
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
                  'Student account',
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
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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

                InputField(fieldName: 'Email Address', isPassword: false, controller: _mail, label: 'example@gojdu.com',),

                const SizedBox(height: 50,),

                InputField(fieldName: 'Username', isPassword: false, controller: _username,),

                const SizedBox(height: 50,),

                InputField(fieldName: 'Password', isPassword: true, controller: _password,),

                const SizedBox(height: 50,),

                InputField(fieldName: 'Repeat Password', isPassword: true, controller:  _repPassword,),

                const SizedBox(height: 100,),

                TextButton(
                    onPressed: () {},
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
    );
    //TODO: M: Make the student page.
  }
}

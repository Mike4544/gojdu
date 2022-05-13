import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/pages/login.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the HTPP libraries
import 'dart:convert';
import 'package:http/http.dart' as http;




// Global Variables
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;



class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final GlobalKey _formKey = GlobalKey();

  String errorMessage ='';

  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorsB.gray900,
        bottomNavigationBar: BackNavbar(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(35, 50, 0, 0),
            child: Row(
              children: const [
                Icon(Icons.password_rounded, color: ColorsB.yellow500,),
                SizedBox(width: 20,),
                Text(
                  'Forgotten Password',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(35),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const Text(
                  'Have you forgotten your password? Worry not! Just enter your email address and we will send you a link to reset your password in no time.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 50),

                InputField(fieldName: 'Enter your email below', isPassword: false, isEmail: true, isStudent: false, controller: emailController, errorMessage: errorMessage,),

                const SizedBox(height: 25),

                clicked == false
                    ? TextButton(
                    onPressed: () async {

                      try {
                        setState(() {
                          clicked = true;
                        });
                        var url = Uri.parse(
                            'https://automemeapp.com/gojdu/changePassword.php');
                        final response = await http.post(url, body: {
                          'action': "FORGOT",
                          "email": emailController.text,
                        });
                        if(response.statusCode == 200){
                          var jsondata = json.decode(response.body);

                          if(jsondata['success']){

                            setState(() {
                              clicked = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              backgroundColor: ColorsB.yellow500,
                              content: Text(
                                'The email is on the way!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Nunito'
                                ),
                              ),
                            ));
                          }
                          if(jsondata['error']){
                            setState(() {
                              errorMessage = jsondata['message'];
                            });
                          }
                        }
                        else {
                          setState(() {
                            errorMessage = 'Something went wrong';
                            clicked = false;
                          });
                        }

                      } catch (e) {
                        setState(() {
                          errorMessage = 'Something went wrong';
                          clicked = false;
                        });
                      }



                    },
                    child: const Text('Send', style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.normal, fontSize: 20),),
                    style: TextButton.styleFrom(

                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      backgroundColor: ColorsB.yellow500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    )
                )
                    : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),
                ),


                Flexible(
                  child: SizedBox(
                    child: SvgPicture.asset(
                      'assets/svgs/forgot_password.svg',
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

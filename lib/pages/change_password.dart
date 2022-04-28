import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/pages/login.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the libraries needed for HTTP requests
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;



class ChangePassword extends StatefulWidget {
  final String? email;
  const ChangePassword({Key? key, required this.email}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String errorMessage1 ='';
  String errorMessage2 = '';

  // The 3 password controllers: Current, New and Confirm
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsB.gray900,
      bottomNavigationBar: const BackNavbar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(35, 50, 0, 0),
          child: Row(
            children: const [
              Icon(Icons.password, color: ColorsB.yellow500,),
              SizedBox(width: 20,),
              Text(
                'Change your password',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                children: [
                  InputField(fieldName: 'Current Password', isPassword: true, errorMessage: errorMessage1, isEmail: false, controller: _currentPasswordController,),
                  const SizedBox(height: 25),
                  InputField(fieldName: 'New Password', isPassword: true, errorMessage: errorMessage2, isEmail: false, controller: _newPasswordController,),
                  const SizedBox(height: 25),
                  InputField(fieldName: 'Confirm Password', isPassword: true, errorMessage: errorMessage2, isEmail: false, controller: _confirmPasswordController,),
                  const SizedBox(height: 100),
                  clicked == false
                      ? TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: ColorsB.yellow500,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text(
                        'Change password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5
                        ),
                      ),
                      onPressed: () async {
                        //TODO: Make the logic for changing password
                        setState(() {
                          errorMessage1 = '';
                          errorMessage2 = '';
                          clicked = true;
                        });
                        try {
                          if(_formKey.currentState!.validate()) {
                            if (_newPasswordController.text !=
                                _confirmPasswordController.text) {
                              setState(() {
                                errorMessage2 = 'Passwords do not match';
                              });
                              return;
                            }
                            var url = Uri.parse(
                                'https://automemeapp.com/gojdu/changePassword.php');
                            final response = await http.post(url, body: {
                              'action': "RESET",
                              "npass": _newPasswordController.text,
                              "email": widget.email,
                              "cpass": _currentPasswordController.text,
                            });
                            if (response.statusCode == 200) {
                              var jsondata = json.decode(response.body);
                              print(jsondata);
                              if(jsondata['success']){
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text(
                                    'Password changed successfully',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Nunito'
                                    ),
                                  ),
                                ));
                              }
                              if(jsondata['error']){
                                setState(() {
                                  errorMessage2 = jsondata['message'];
                                  errorMessage1 = jsondata['message'];
                                  clicked = false;
                                });
                              }


                            }
                          }
                        }
                        catch (e) {
                          setState(() {
                            errorMessage2 = 'Something went wrong';
                            errorMessage1 = 'Something went wrong';
                            clicked = false;
                          });
                        }

                      }
                  )
                      : const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}

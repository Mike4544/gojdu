import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/pages/login.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final GlobalKey _formKey = GlobalKey();

  String errorMessage1 ='';
  String errorMessage2 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                InputField(fieldName: 'New Password', isPassword: true, errorMessage: errorMessage1, isEmail: false,),
                const SizedBox(height: 25),
                InputField(fieldName: 'Confirm Password', isPassword: true, errorMessage: errorMessage2, isEmail: false,),
                const SizedBox(height: 100),
                TextButton.icon(
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
                  onPressed: () {
                    //TODO: Make the logic for changing password
                  }
                  ),
              ],
            )
        ),
      ),
    );
  }
}

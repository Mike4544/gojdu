import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/pages/login.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gojdu/pages/change_password.dart';
import 'package:animations/animations.dart';

// Firebase thingys
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

FirebaseMessaging messaging = FirebaseMessaging.instance;


class SettingsPage extends StatefulWidget {
  final String type;
  final BuildContext context;

  const SettingsPage({Key? key, required this.type, required this.context}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {


  late String? fn, ln, email, pass;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<int> _getData() async {
    final prefs = await _prefs;
    fn = prefs.getString('first_name');
    ln = prefs.getString('last_name');
    email = prefs.getString('email');
    pass = prefs.getString('password');

    return 0;
  }

  @override
  Widget build(BuildContext context) {

    //  <------------ For size  ---------------->
    final device = MediaQuery.of(context).size;

    return SizedBox(
      height: device.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
              future: _getData(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),
                  );
                }
                else {
                  return Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: FittedBox(

                      child: DataTable(
                        dataRowHeight: MediaQuery.of(context).size.height * .1,
                        columns: const [
                          DataColumn(label: Text('')),
                          DataColumn(label: Text(''))
                        ],
                        rows: [
                          DataRow(cells: [
                            const DataCell(Text(
                              'Email Address:',
                              style: TextStyle(
                                  color: ColorsB.yellow500,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20
                              ),
                            )),
                            DataCell(Padding(
                              padding: EdgeInsets.symmetric(vertical: device.height * .02),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey[900]!.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: Colors.grey[900]!)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8.5),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          email!,
                                          style: TextStyle(
                                            color: Colors.white24.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 100,
                                    maxWidth: device.width * 0.45,
                                  ),
                                ),
                              ),
                            ))
                          ]),
                          DataRow(cells: [
                            const DataCell(Text(
                              'Full Name:',
                              style: TextStyle(
                                  color: ColorsB.yellow500,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20
                              ),
                            )),
                            DataCell(Center(
                              child: Text(
                                ln! + ' ' + fn!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ))
                          ]),
                          DataRow(cells: [
                            const DataCell(Text(
                              'Password:',
                              style: TextStyle(
                                  color: ColorsB.yellow500,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20
                              ),
                            )),
                            DataCell(Padding(
                              padding: EdgeInsets.symmetric(vertical: device.height * .02),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 500),
                                      reverseTransitionDuration: const Duration(milliseconds: 500),
                                      pageBuilder: (context, a1, a2) => ChangePassword(email: email,),
                                      transitionsBuilder: (context, a1, a2, child) =>
                                          SharedAxisTransition(animation: a1, secondaryAnimation: a2, transitionType: SharedAxisTransitionType.vertical, child: child, fillColor: ColorsB.gray900,),
                                    ));
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    child: Center(
                                      child: Text(
                                        'Change your password',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal
                                        ),
                                      ),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor: ColorsB.gray800,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      )
                                  ),
                                ),
                              ),
                            ))
                          ]),
                          DataRow(cells: [
                            const DataCell(Text(
                              'Type: ',
                              style: TextStyle(
                                  color: ColorsB.yellow500,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20
                              ),
                            )),
                            DataCell(Center(
                              child: Text(
                                widget.type + ' account',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ))
                          ]),
                        ],
                      ),
                    ),
                  );
                }
              }
          ),
          SizedBox(
            height: device.height * 0.1,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) =>
                      AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: ColorsB.gray900,
                          title: Column(
                            children: const [
                              Text(
                                'Are you sure you want to log-off?',
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
                            height: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'You will be redirected to the login page after this. Are you sure you want to log-off?',
                                  style: TextStyle(
                                      color: ColorsB.yellow500,
                                      fontSize: 15
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () async {

                                        logoff(widget.context);
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: ColorsB.yellow500,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        height: 50,
                                        width: 75,
                                        child: Icon(
                                          Icons.check, color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: ColorsB.gray800,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        height: 50,
                                        width: 75,
                                        child: Icon(
                                          Icons.close, color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                      )
              );
            },
            child: Container(
              child: SvgPicture.asset('assets/svgs/logOff.svg'),
              //SvgPicture.asset('assets/svgs/logout_button.svg', colorBlendMode: BlendMode.dstATop,),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent.withOpacity(0.25), blurRadius: 50),
                    BoxShadow(color: Colors.redAccent[400]!.withOpacity(0.05), blurRadius: 25,),
                    BoxShadow(color: Colors.redAccent[200]!.withOpacity(0.1), blurRadius: 25,),
                  ]
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton.icon(
            onPressed: () {
              print(pass);
              print(email);

              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {

                    var password2 = TextEditingController();
                    final _formKey = GlobalKey<FormState>();

                    return  AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: ColorsB.gray900,
                        title: Column(
                          children: const [
                            Text(
                              'Are you sure you want to delete your account?',
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
                                'Your account will be deleted forever (a really REALLY long time). Are you sure you want to proceed?',
                                style: TextStyle(
                                    color: ColorsB.yellow500,
                                    fontSize: 15
                                ),
                              ),
                              const SizedBox(height: 10),
                              Form(
                                key: _formKey,
                                child: TextFormField(
                                  obscureText: true,
                                  cursorColor: ColorsB.yellow500,
                                  controller: password2,
                                  decoration: InputDecoration(
                                      filled: true,
                                      labelText: "Confirm password",
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
                                    } else if(pwrd != pass) {
                                      return "Passwords do not match, your account will NOT be deleted.";
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () async {

                                      if(_formKey.currentState!.validate()) {
                                        deleteAccount(widget.context, email!);
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
                                      child: Icon(
                                        Icons.check, color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: ColorsB.gray800,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      height: 50,
                                      width: 75,
                                      child: Icon(
                                        Icons.close, color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                    );
                  }
              );


            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Delete Account',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.normal
              ),
            ),
          )

        ],
      ),
    );
  }
}


Future<void> logoff(BuildContext context) async {
  
  final prefs = await SharedPreferences.getInstance();

  String type = prefs.getString('type')!;

  await messaging.unsubscribeFromTopic(type + 's');

  await prefs.remove('name');
  await prefs.remove('email');
  await prefs.remove('password');

  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

Future<void> deleteAccount(BuildContext context, String email) async {

  try{
    var url = Uri.parse('https://cnegojdu.ro/GojduApp/deleteAccount.php');
    final response = await http.post(url, body: {
      "email": email,
    });

    showDialog(
      context: context,
      builder: (context) =>
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500)
          )
    );

    print(response.statusCode);

    if(response.statusCode == 200){
      var jsondata = json.decode(response.body);
      print(jsondata);

      Navigator.of(context).pop();

      if(jsondata["error"]){
        print(jsondata["message"]);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 20,),
              Text(
                'Uh-oh! Something went wrong!',
                style: TextStyle(
                    color: Colors.white
                ),
              )
            ],
          ),
        ));

      }else{

        await logoff(context);

      }
    } else {
      print("Upload failed");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Row(
          children: const [
            Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Colors.white),
            SizedBox(width: 20,),
            Text(
              'Uh-oh! Trouble connecting!',
              style: TextStyle(
                  color: Colors.white
              ),
            )
          ],
        ),
      ));

      //  Navigator.of(context).pop();
    }

  }
  catch(e){
    //print("Error during converting to Base64");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 20,),
          Text(
            'Uh-oh! Something went wrong! $e',
            style: const TextStyle(
                color: Colors.white
            ),
          )
        ],
      ),
    ));
  }

}


//  For the logoff button




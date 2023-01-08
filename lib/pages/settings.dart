import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gojdu/others/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gojdu/pages/news.dart';
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

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';

import 'package:shimmer/shimmer.dart';
import 'package:http_parser/http_parser.dart';

import 'package:gojdu/others/options.dart';

import '../others/api.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

class SettingsPage extends StatefulWidget {
  final String type;
  final BuildContext context;

  const SettingsPage({Key? key, required this.type, required this.context})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String? fn, ln, email, pass, profileImage;
  late bool? notifActive;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late var loadInitData = _getData();

  var _lastFile;

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
    notifActive = prefs.getBool('notifActive');

    var _response = await http.get(Uri.parse(
        '${Misc.link}/${Misc.appName}/profiles/${globalMap['id']}.jpg'));
    m_debugPrint(
        "${Misc.link}/${Misc.appName}/profiles/${globalMap['id']}.jpg");

    _lastFile = _response.bodyBytes;

    return 0;
  }

  Future uploadFile(CroppedFile _file) async {
    m_debugPrint('Trying...');

    File file = File(_file.path);

    var imageBytes = file.readAsBytesSync();
    String baseimage = base64Encode(imageBytes);

    var url = Uri.parse('${Misc.link}/${Misc.appName}/profile_upload.php');
    final response = await http.post(url, body: {
      "image": baseimage,
      "name": '${globalMap['id']}',
      "format": 'jpg'
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"]) {
        //m_debugPrint(jsondata["msg"]);
      } else {
        m_debugPrint("Upload successful");
      }
    } else {
      //m_debugPrint("Upload failed");
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    //  <------------ For size  ---------------->
    final device = MediaQuery.of(context).size;

    const textStyle = TextStyle(
        color: ColorsB.yellow500, fontWeight: FontWeight.w700, fontSize: 25);

    return SizedBox(
      height: device.height * 1.25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
              future: loadInitData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ColorsB.yellow500),
                  );
                } else {
                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: FittedBox(
                          child: DataTable(
                            dataRowHeight:
                                MediaQuery.of(context).size.height * .2,
                            columns: const [
                              DataColumn(label: Text('')),
                              DataColumn(label: Text(''))
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$fn $ln",
                                        style: textStyle,
                                      ),

                                      //  Chips
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Chip(
                                              label: Text(
                                                widget.type,
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: Colors.white),
                                              ),
                                              avatar: const Icon(
                                                Icons
                                                    .admin_panel_settings_rounded,
                                                color: Colors.white,
                                              ),
                                              backgroundColor: ColorsB.gray800,
                                              elevation: 0,
                                            ),
                                            Chip(
                                              label: Text(
                                                email!,
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: Colors.white),
                                              ),
                                              avatar: const Icon(
                                                Icons.email,
                                                color: Colors.white,
                                              ),
                                              backgroundColor: ColorsB.gray800,
                                              elevation: 0,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: screenHeight * .15,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: const BoxDecoration(
                                              color: ColorsB.gray800,
                                              shape: BoxShape.circle),
                                          child: isLoading
                                              ? SizedBox(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: Shimmer.fromColors(
                                                    baseColor: ColorsB.gray800,
                                                    highlightColor:
                                                        ColorsB.gray700,
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Image.memory(_lastFile,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Center(
                                                        child: Icon(
                                                          Icons.upload_rounded,
                                                          color: Colors.white,
                                                          size: 40,
                                                        ),
                                                      )),
                                        ),
                                        Material(
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () async {
                                              final ImagePicker _picker =
                                                  ImagePicker();

                                              final _image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                      imageQuality: 50);

                                              if (_image == null) return;

                                              CroppedFile? croppedFile =
                                                  await ImageCropper().cropImage(
                                                      sourcePath: _image.path,
                                                      aspectRatio:
                                                          const CropAspectRatio(
                                                              ratioX: 1,
                                                              ratioY: 1),
                                                      maxHeight: 1080,
                                                      maxWidth: 1080);

                                              if (croppedFile == null) return;

                                              await uploadFile(croppedFile);

                                              setState(() {
                                                isLoading = true;
                                              });

                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));

                                              _lastFile =
                                                  await File(croppedFile.path)
                                                      .readAsBytes();

                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ))),
                              ]),
                              DataRow(cells: [
                                DataCell(Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: device.height * .02),
                                  child: Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 500),
                                              reverseTransitionDuration:
                                                  const Duration(
                                                      milliseconds: 500),
                                              pageBuilder: (context, a1, a2) =>
                                                  ChangePassword(
                                                email: email,
                                              ),
                                              transitionsBuilder:
                                                  (context, a1, a2, child) =>
                                                      SharedAxisTransition(
                                                animation: a1,
                                                secondaryAnimation: a2,
                                                transitionType:
                                                    SharedAxisTransitionType
                                                        .vertical,
                                                child: child,
                                                fillColor: ColorsB.gray900,
                                              ),
                                            ));
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        child: Center(
                                          child: Text(
                                            'Change your password',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                          maximumSize:
                                              Size(double.infinity, 50),
                                          backgroundColor: ColorsB.gray800,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          )),
                                    ),
                                  ),
                                )),
                                DataCell.empty
                              ]),
                              DataRow(cells: [
                                DataCell(Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const [
                                    Icon(Icons.notifications,
                                        color: ColorsB.yellow500),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Notifications:',
                                      style: TextStyle(
                                          color: ColorsB.yellow500,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20),
                                    )
                                  ],
                                )),
                                DataCell(Center(
                                  child: CupertinoSwitch(
                                    value: notifActive ?? true,
                                    onChanged: (value) async {
                                      notifActive = value;

                                      if (!value) {
                                        await messaging.unsubscribeFromTopic(
                                            widget.type + 's');
                                        await messaging
                                            .unsubscribeFromTopic('all');
                                        final prefs = await _prefs;

                                        await prefs.setBool(
                                            'notifActive', false);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: const Text(
                                                  'Dully noted! You won\'t be receiving notifications from us anymore.',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor:
                                                    ColorsB.gray800,
                                                action: SnackBarAction(
                                                  label: 'Revert',
                                                  onPressed: () async {
                                                    notifActive = true;

                                                    setState(() {});

                                                    await messaging
                                                        .subscribeToTopic(
                                                            widget.type + 's');
                                                    final prefs = await _prefs;

                                                    await prefs.setBool(
                                                        'notifActive', true);

                                                    //  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                  },
                                                )));
                                      } else {
                                        await messaging.subscribeToTopic(
                                            widget.type + 's');
                                        await messaging.subscribeToTopic('all');
                                        final prefs = await _prefs;

                                        await prefs.setBool(
                                            'notifActive', true);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            'Welcome back! Glad to be able to annoy you again!',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: ColorsB.gray800,
                                        ));
                                      }

                                      setState(() {});
                                    },
                                  ),
                                ))
                              ])
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
          SizedBox(
            height: device.height * 0.075,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: ColorsB.gray900,
                      title: Column(
                        children: const [
                          Text(
                            'Are you sure you want to log-off?',
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
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'You will be redirected to the login page after this. Are you sure you want to log-off?',
                              style: TextStyle(
                                  color: ColorsB.yellow500, fontSize: 15),
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
                                      Icons.check,
                                      color: Colors.white,
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
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )));
            },
            child: Container(
              child: SvgPicture.asset('assets/svgs/logOff.svg'),
              //SvgPicture.asset('assets/svgs/logout_button.svg', colorBlendMode: BlendMode.dstATop,),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.redAccent.withOpacity(0.25),
                        blurRadius: 50),
                    BoxShadow(
                      color: Colors.redAccent[400]!.withOpacity(0.05),
                      blurRadius: 25,
                    ),
                    BoxShadow(
                      color: Colors.redAccent[200]!.withOpacity(0.1),
                      blurRadius: 25,
                    ),
                  ]),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton.icon(
            onPressed: () {
              m_debugPrint(pass);
              m_debugPrint(email);

              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    var password2 = TextEditingController();
                    final _formKey = GlobalKey<FormState>();

                    return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: ColorsB.gray900,
                        title: Column(
                          children: const [
                            Text(
                              'Are you sure you want to delete your account?',
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
                                'Your account will be deleted forever (a really REALLY long time). Are you sure you want to proceed?',
                                style: TextStyle(
                                    color: ColorsB.yellow500, fontSize: 15),
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
                                    } else if (pwrd != pass) {
                                      return "Passwords do not match, your account will NOT be deleted.";
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (_formKey.currentState!.validate()) {
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
                                        Icons.check,
                                        color: Colors.white,
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
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ));
                  });
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Delete Account',
              style:
                  TextStyle(color: Colors.red, fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> logoff(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  String type = prefs.getString('type')!;

  await messaging.unsubscribeFromTopic(type.replaceAll(' ', ''));
  await messaging.unsubscribeFromTopic('all');

  await prefs.remove('name');
  await prefs.remove('email');
  await prefs.remove('password');

  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

Future<void> deleteAccount(BuildContext context, String email) async {
  try {
    var url = Uri.parse('${Misc.link}/${Misc.appName}/deleteAccount.php');
    final response = await http.post(url, body: {
      "email": email,
    });

    showDialog(
        context: context,
        builder: (context) => const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500)));

    m_debugPrint(response.statusCode.toString());

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      //m_debugPrint(jsondata.toString());

      Navigator.of(context).pop();

      if (jsondata["error"]) {
        //m_debugPrint(jsondata["message"]);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(
                width: 20,
              ),
              Text(
                'Uh-oh! Something went wrong!',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ));
      } else {
        await logoff(context);
      }
    } else {
      m_debugPrint("Upload failed");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Row(
          children: const [
            Icon(Icons.signal_cellular_connected_no_internet_4_bar,
                color: Colors.white),
            SizedBox(
              width: 20,
            ),
            Text(
              'Uh-oh! Trouble connecting!',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ));

      //  Navigator.of(context).pop();
    }
  } catch (e) {
    //m_debugPrint("Error during converting to Base64");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(
            width: 20,
          ),
          Text(
            'Uh-oh! Something went wrong! $e',
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    ));
  }
}


//  For the logoff button




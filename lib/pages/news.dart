import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
//import 'package:gojdu/widgets/class_selector.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:rive/rive.dart';
//import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/floor_selector.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';
//import 'package:gojdu/others/event.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

//  Connectivity
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as con;

// SVG
import 'package:flutter_svg/flutter_svg.dart';

// Firebase for messaging
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

import 'package:gojdu/widgets/post.dart';

import 'package:gojdu/pages/editTables.dart';
import 'package:gojdu/others/floor.dart';




class NewsPage extends StatefulWidget {

  final Map data;
  final bool? newlyCreated;

  const NewsPage({Key? key, required this.data, this.newlyCreated}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

// //Globals
// SMIInput<bool>? _mapInput, _announcementsInput, _reserveInput;
late bool loaded;

late Map globalMap;

List<Floor> floors = [
  // Floor(floor: 'parter', file: 'parter.png'),
  // Floor(floor: 'parter', file: 'parter.png'),
  // Floor(floor: 'parter', file: 'parter.png'),
];


List<String> titles = [];
List<String> sizes = [];



Future<int> getFloors() async {
  try{
    var url = Uri.parse('https://cnegojdu.ro/GojduApp/getfloors.php');


    //  TODO: FIX THIS SOMEHOWWWW


    final response = await http.post(url, body: {
    });

    print(response.statusCode);

    if(response.statusCode == 200){
      var jsondata = json.decode(response.body);
      print(jsondata);
      if(jsondata['0']["error"]){
        print(jsondata["message"]);

      }else{
        print("Upload successful");

        for(int i = 1; i <= 3; i++){
          print(jsondata['$i']);
          floors.add(Floor(floor:jsondata['$i']["floor"], file: jsondata['$i']['file']));
        }


      }
    } else {
      print("Upload failed");

    }

  }
  catch(e){
    //print("Error during converting to Base64");


  }

  return 1;




}


// <---------- Height and width outside of context -------------->
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

//  TODO: Make variables for the name, password, mail etc

ConnectivityResult? _connectionStatus;

class _NewsPageState extends State<NewsPage>{

  bool pressed = false; //????????????? Ii folosit undeva?????

  int _currentIndex = 1;




  late final accType;



  ConnectivityResult? connectionStatus, lastConnectionStatus;
  late StreamSubscription subscription;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  final PageController _pageController = PageController(
    initialPage: 1,
  );

  void checkConnectivity() {
    if(connectionStatus == ConnectivityResult.none){

      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            child: Row(
              children: const [
                Icon(Icons.error, color: Colors.white, size: 17,),
                SizedBox(width: 10),
                Text("No internet connection", style: TextStyle(fontFamily: 'Nunito', fontSize: 10),),
              ],
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        duration: const Duration(days: 1),
        backgroundColor: Colors.red,
      ));

    } else if(lastConnectionStatus == ConnectivityResult.none && connectionStatus != ConnectivityResult.none){
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Container(
          child: Row(
            children: const [
              Icon(Icons.check, color: Colors.white, size: 17,),
              SizedBox(width: 10),
              Text("Internet connection restored", style: TextStyle(fontFamily: 'Nunito', fontSize: 10),),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        backgroundColor: Colors.green,
      ));
    }
  }

  bool opened = false;

  void _forNewUsers(BuildContext context) async {
    if(widget.newlyCreated != null && widget.newlyCreated == true){
      opened = true;
      await Future.delayed(const Duration(milliseconds: 100));
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) =>
            AlertDialog(
              backgroundColor: ColorsB.gray900,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    _scaffoldKey.currentState!.showSnackBar(SnackBar(
                      content: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: const Text("Unverified account. Some features might be unavailable to you.", style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: Colors.white),)),
                      duration: const Duration(days: 1),
                      backgroundColor: ColorsB.gray800,
                      behavior: SnackBarBehavior.floating,
                      dismissDirection: DismissDirection.none,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text("Okay", style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: Colors.white),),
                ),
              ],
              content: SizedBox(
                height: screenHeight * 0.5,
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: SvgPicture.asset(
                        'assets/svgs/screen_new.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Text(
                      'Welcome! One more thing before you can start using the app.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17.5,
                        color: ColorsB.yellow500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Currently you are unverified, meaning that you won\'t be able to login after you close the app until you verify yourself by clicking on the verification mail, or you get verified by an admin.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
      );
    }
  }


  @override
  void deactivate() {
    super.deactivate();
    //print(1);
  }

  //  Testing smthing
  late final Future? gFloors = getFloors();

  @override
  void initState() {


    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        connectionStatus = result;
        _connectionStatus = result;
      });
      //print(result);
      //print(lastConnectionStatus);
      checkConnectivity();
      lastConnectionStatus = connectionStatus;
    });

    FirebaseMessaging.onMessage.listen((message) async {

      if(_scaffoldKey.currentState != null){

        _scaffoldKey.currentState?.hideCurrentSnackBar();

        if(message.data['type'] == 'Post'){
          _scaffoldKey.currentState!.showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(Icons.notifications, color: Colors.white, size: 17,),
                SizedBox(width: 10),
                Text('New posts available!', style: TextStyle(fontFamily: 'Nunito'),),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorsB.yellow500,
          ));
        }

        if(message.data['type'] == 'Verify'){
          //_scaffoldKey.currentState!.hideCurrentSnackBar();
          setState(() {
            globalMap['verification'] = 'Verified';
          });
          _scaffoldKey.currentState!.showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check, color: Colors.white, size: 17,),
                SizedBox(width: 10),
                Text('Account verified!', style: TextStyle(fontFamily: 'Nunito'),),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));
        }
      }



    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if(message.data['type'] == 'Post') {
        if(_announcementsKey.currentState != null){
          _announcementsKey.currentState!._refresh();
        }
      }
    });


    super.initState();

    // Listening for the notifications








    // <---------- Load the acc type -------------->
    accType = widget.data['account'];
    globalMap = widget.data;

    //  <-----------  Loaded  ------------------>
    loaded = false;
    //Initialising the navbar icons -






  }

  @override
  void dispose() {
    _pageController.dispose();
    globalMap.clear();
    lastConnectionStatus = null;
    connectionStatus = null;
    subscription.cancel();

    _names.clear();
    _emails.clear();
    _types.clear();
    _tokens.clear();
    floors.clear();
    super.dispose();


  }

  // Lists for the pending users
  List<String> _names = [];
  List<String> _emails = [];
  List<String> _types = [];
  List<String> _tokens = [];




  // <----------  Load the pending users -------------->
  Future<int> _loadUsers() async {

    try {




      var url = Uri.parse('https://cnegojdu.ro/GojduApp/select_users.php');
      final response = await http.post(url, body: {
        'state': 'Pending',
      });
      //print(response.statusCode);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //  print(jsondata);

        if (jsondata[0]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata[0]["success"]) {

            _names.clear();
            _emails.clear();
            _types.clear();
            _tokens.clear();

            for(int i = 1; i <= jsondata.length; i++)
            {
              String name = jsondata[i]["user"].toString();
              String email = jsondata[i]["email"].toString();
              String acc_type = jsondata[i]["type"].toString();
              String token = jsondata[i]["token"].toString();


              if(name != "null" && email != "null"){
                _names.add(name);
                _emails.add(email);
                _types.add(acc_type);
                _tokens.add(token);
              }

              /* if(post != "null")
              {
                //print(post+ " this is the post");
                //print(title+" this is the title");
                //print(owner+ " this is the owner");
              } */

            }
          }
          else
          {
            //print(jsondata["1"]["message"]);
          }
        }
      }
    } catch (e) {
      //print(e);
    }

    return 0;

  }

  // The notification
  Future<void> _notifyUser(String? token) async {
    try {
      var ulr2 = Uri.parse('https://cnegojdu.ro/GojduApp/notifications.php');
      final response2 = await http.post(ulr2, body: {
        "action": "Verify",
        "token": token,
      });

      if(response2.statusCode == 200){
        var jsondata2 = json.decode(response2.body);
        //print(jsondata2);

      }


    } catch (e) {
      //print(e);
    }
  }

  Future<void> _verifyUser(String? token, String? email, String status, int index) async {
    try {
      var ulr2 = Uri.parse('https://cnegojdu.ro/GojduApp/verify_accounts.php');
      final response2 = await http.post(ulr2, body: {
        "email": email,
        "status": status,
      });

      if (response2.statusCode == 200) {
        var jsondata2 = json.decode(response2.body);
        //print(jsondata2);
        if(jsondata2['error'] == false){
          _notifyUser(token);

          _names.removeAt(index);
        }
      }
      else {
        //print(response2.statusCode);
      }
    } catch (e) {
      //print(e);
    }
  }



  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    if(!opened){
      _forNewUsers(context);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorsB.gray900,
      extendBody: true,
      bottomNavigationBar: _bottomNavBar(),
      body: FutureBuilder(
        future: gFloors,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return const SizedBox();
          }
          else {
            return PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                MapPage(),
                Announcements( key: _announcementsKey,),
                Calendar()
              ],
            );
          }

        }
      ),
    );
  }


  Widget _bottomNavBar() {
    if(globalMap['account'] == 'Admin') {

      return Container(
        width: screenWidth,
        height: 75,
        decoration: BoxDecoration(
            color: ColorsB.gray800,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 10,
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ]
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    child: GestureDetector(
                      child: const Icon(Icons.verified_user_outlined, color: Colors.white),
                      onTap: () {

                        // Verification page for the admin
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            final ScrollController _scrollController = ScrollController();

                            return StatefulBuilder(
                                builder: (_, StateSetter setState1) =>
                                    AlertDialog(

                                      title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children : [
                                            Row(
                                              children: const [
                                                Icon(Icons.verified_user_outlined, color: Colors.white, size: 30,),
                                                SizedBox(width: 10,),
                                                Text('Verify Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                                              ],
                                            ),
                                            const Divider(color: Colors.white, thickness: 0.5, height: 20,),
                                          ]
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      backgroundColor: ColorsB.gray900,
                                      content: SizedBox(
                                        height: screenHeight * 0.75,
                                        width: screenWidth * 0.8,
                                        child: FutureBuilder(
                                          future: _loadUsers(),
                                          builder: (c, sn) {
                                            if(sn.hasData && (_names.isNotEmpty || _emails.isNotEmpty || _types.isNotEmpty)) {
                                              return Scrollbar(
                                                controller: _scrollController,
                                                child: ListView.builder(
                                                  controller: _scrollController,
                                                  physics: const BouncingScrollPhysics(),
                                                  itemCount: _names.length > 0 ? _names.length : 1,
                                                  itemBuilder: (context, index) {
                                                    if(_names.length > 0){
                                                      return Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Row(
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,

                                                              children: [
                                                                Text(
                                                                  _names[index],
                                                                  style: const TextStyle(fontSize: 15, color: Colors.white),
                                                                ),
                                                                const SizedBox(height: 5,),
                                                                Text(
                                                                  'Type: ${_types[index]}',
                                                                  style: const TextStyle(fontSize: 10, color: ColorsB.yellow500),
                                                                ),
                                                                Text(
                                                                  'Email: ${_emails[index]}',
                                                                  style: const TextStyle(fontSize: 10, color: ColorsB.yellow500),
                                                                ),
                                                              ],
                                                            ),
                                                            const Spacer(),
                                                            GestureDetector(
                                                              child: const Icon(Icons.check_circle_outlined, color: Colors.green, size: 30,),
                                                              onTap: () async {
                                                                //print('Checked');
                                                                await _verifyUser(_tokens[index], _emails[index], 'Verified', index);
                                                                setState1(() {

                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(width: 10,),
                                                            GestureDetector(
                                                              child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 30,),
                                                              onTap: () {
                                                                //print('Canceled');




                                                                // TODO: Cancel feature + Check feature
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    else {
                                                      return const Center(
                                                        child: Text('No accounts pending approval. Nice!', style: TextStyle(fontSize: 20, color: ColorsB.gray700),),
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            }
                                            else if(sn.hasData && (_names.isEmpty || _emails.isEmpty || _types.isEmpty)){
                                              return const Center(
                                                child: Text('No accounts pending approval. Nice!', style: TextStyle(fontSize: 20, color: ColorsB.gray700),),
                                              );
                                            }
                                            else {
                                              return const Center(
                                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),)
                                              );
                                            }
                                          }
                                        )
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _names.clear();
                                            _emails.clear();
                                            _types.clear();
                                            _tokens.clear();


                                            Navigator.pop(context);
                                          },
                                          child: const Text('Close', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    )
                            );
                          }

                        );

                      },
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Icon(Icons.map, color: _currentIndex == 0 ? ColorsB.yellow500 : Colors.white, size: 40),
                  onTap: () {
                    //  _mapExpandAnim(_mapInput);
                    setState(() {
                      _currentIndex = 0;
                      //  changeColors(_currentIndex);
                    });
                    _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                  },
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                    child: Icon(Icons.announcement, color: _currentIndex == 1 ? ColorsB.yellow500 : Colors.white, size: 40),
                    onTap: () {
                      //  _mapExpandAnim(_announcementsInput);
                      setState(() {
                        _currentIndex = 1;
                        //  changeColors(_currentIndex);
                      });
                      _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                    }
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Icon(Icons.calendar_today, color: _currentIndex == 2 ? ColorsB.yellow500 : Colors.white, size: 30),
                  onTap: () {
                    //  _mapExpandAnim(_reserveInput);
                    setState(() {
                      _currentIndex = 2;
                      //  changeColors(_currentIndex);
                    });
                    _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Icon(Icons.apps, color: _currentIndex == 3 ? ColorsB.yellow500 : Colors.white, size: 40),
                  onTap: () {
                    setState(() {
                      _currentIndex = 3;
                      //  changeColors(_currentIndex);
                    });

                  }
                ),
              )
            ]
        ),
      );
    }
    else {
      return Container(
        width: screenWidth,
        height: 75,
        decoration: BoxDecoration(
            color: ColorsB.gray800,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 10,
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ]
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Icon(Icons.map, color: _currentIndex == 0 ? ColorsB.yellow500 : Colors.white, size: 40),
                  onTap: () {
                    //  _mapExpandAnim(_mapInput);
                    setState(() {
                      _currentIndex = 0;
                      //  changeColors(_currentIndex);
                    });
                    _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                  },
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                    child: Icon(Icons.announcement, color: _currentIndex == 1 ? ColorsB.yellow500 : Colors.white, size: 40),
                    onTap: () {
                      //  _mapExpandAnim(_announcementsInput);
                      setState(() {
                        _currentIndex = 1;
                        //  changeColors(_currentIndex);
                      });
                      _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                    }
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Icon(Icons.calendar_today, color: _currentIndex == 2 ? ColorsB.yellow500 : Colors.white, size: 30),
                  onTap: () {
                    //  _mapExpandAnim(_reserveInput);
                    setState(() {
                      _currentIndex = 2;
                      //  changeColors(_currentIndex);
                    });
                    _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                ),
              ),

              SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                    child: Icon(Icons.apps, color: _currentIndex == 3 ? ColorsB.yellow500 : Colors.white, size: 40),
                    onTap: () {
                      setState(() {
                        _currentIndex = 3;
                        //  changeColors(_currentIndex);
                      });

                    }
                ),
              )
            ]
        ),
      );
    }
  }

}




// Global key
final GlobalKey<_AnnouncementsState> _announcementsKey = GlobalKey<_AnnouncementsState>();





class Announcements extends StatefulWidget {

  const Announcements({Key? key}) : super(key: key);

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}


// Test

//var currentChannel = "";

int maximumCount = 0;

class _AnnouncementsState extends State<Announcements> with SingleTickerProviderStateMixin {


  var selectedColorS = Colors.white;
  var selectedColorT = ColorsB.yellow500;
  var selectedColorP = Colors.white;

  late double rectX;



  late final _announcementsController;

  var _currentAnnouncement = 1;

//  <----------------- Shimmer animation controller ----------->
  late AnimationController _shimmerController;


  //  <-------------- Loading bool for shimmer loading -------------------->
  late bool isLoading;

  //  <-------------- Error bool  -------------------->
  late bool isError;

  //  <---------------  Scrollcontroller  ------------------------->

  late ScrollController  _scrollController;
  int maxScrollCount = 5;


  //  <-----------------  Text Keys ----------------------------->
  final GlobalKey _textKeyStudent = GlobalKey();
  final GlobalKey _textKeyTeacher = GlobalKey();
  final GlobalKey _textKeyParent = GlobalKey();




  late var currentChannel = "";



  List<Post> posts = [];




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //  <-------------- Lists ------------->
    posts = [];

    maximumCount = 0;
    isError = false;




    int _getCurrentIndex() {
      switch(globalMap['account']) {
        case 'Student':
          _currentAnnouncement = 0;
          currentChannel = 'Students';
          return 0;
        case 'Teacher':
          _currentAnnouncement = 1;
          currentChannel = 'Teachers';
          return 1;
        case 'Parent':
          _currentAnnouncement = 2;
          currentChannel = 'Parents';
          return 2;
          case 'Admin':
            _currentAnnouncement = 1;
            currentChannel = 'Teachers';
            return 1;
        default:
          return 0;
      }
    }

    _announcementsController = PageController(
      initialPage:  _getCurrentIndex(),

    );
    _currentAnnouncement = 1;
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    if(posts.isEmpty) {
      isLoading = true;
      load(currentChannel);
    }
    else {
      isLoading = false;
    }

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.95){
        _getMoreData();
      }
    });

    //print(globalMap['account']);

  }

  @override
  void dispose() {
    _announcementsController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();

    posts.clear();

    isAlive = false;
    super.dispose();


  }

  void _getMoreData() {

    //  TODO: Maybe make it async
    maxScrollCount += 5;
    setState(() {

    });

  }

  void _refresh() async {
    ////print(likesBool);
    isError = false;
    loaded = false;

    ////print(posts.length);

    posts.clear();

    maximumCount = 0;
    setState(() {
      maxScrollCount = 5; //  Reset to the original scroll count
      isLoading = true;
      load(currentChannel);
    });
  }


  void _showWritable() {

     Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, a1, a2) =>
      SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
        child: const PostItPage(),
      )
    ));

  }


  // ---------- Placeholder title ------------
  String title = '';
  String description = '';

  var device = window.physicalSize;

  late var currentWidth;

  bool isAlive = true;

  // Max max max posts


  //  <----------------- Alignment for the bar -------------->
  Alignment _alignment = Alignment.center;


  List<String> labels = [
    'Students',
    'Teachers',
    'Parents'
  ];

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  final style = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold
  );


  @override
  Widget build(BuildContext context) {

    currentWidth = _textSize(labels[_currentAnnouncement], style).width;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Announcements', accType: globalMap['account'] + ' account', position: 1,),

        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Latest news',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontSize: 25,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Visibility(
                        visible: globalMap['account'] == 'Teacher' || globalMap['account'] == 'Admin' ? true : false, // cHANGE IT,
                        child: GestureDetector(
                          onTap: _showWritable,
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 40,
                            color: ColorsB.gray800,

                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: ColorsB.gray800,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25,),

                  teachersBar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: SizedBox(
                      height: 450,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) =>
                        const material.LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            0, 0.25
                          ],
                          colors: [Colors.transparent, ColorsB.gray900]
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: PageView(
                          clipBehavior: Clip.hardEdge,
                          controller: _announcementsController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildLists(ColorsB.gray800),
                            _buildLists(Colors.amber),
                            _buildLists(Colors.indigoAccent),


                          ],
                        ),
                      )
                    ),
                  )

                ],
              ),
            )
        )

      ],
    );
  }

  Widget teachersBar() {
    if(globalMap['account'] == 'Teacher' || globalMap['account'] == 'Admin') {



      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 75,
          width: device.width * 0.90,
          decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(50)
          ),
          child: LayoutBuilder(
            builder: (context, constraints){
              var barWidth = constraints.maxWidth / 3;


              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Text(
                          'Students',
                          key: _textKeyStudent,
                          style: TextStyle(
                              color: selectedColorS,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedColorS = ColorsB.yellow500;
                            selectedColorT = Colors.white;
                            selectedColorP = Colors.white;
                            _alignment = Alignment.centerLeft;
                            _currentAnnouncement = 0;
                            currentWidth = _textSize(labels[_currentAnnouncement], style).width;
                            currentChannel = 'Students';
                            _refresh();
                            //print(currentWidth);
                          });
                          _announcementsController.animateToPage(
                              _currentAnnouncement,
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeInOut);
                        },
                      ),
                      GestureDetector(
                        child: Text(
                          'Teachers',
                          key: _textKeyTeacher,
                          style: TextStyle(
                              color: selectedColorT,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            selectedColorS = Colors.white;
                            selectedColorT = ColorsB.yellow500;
                            selectedColorP = Colors.white;
                            _alignment = Alignment.center;
                            _currentAnnouncement = 1;
                            currentWidth = _textSize(labels[_currentAnnouncement], style).width;
                            currentChannel = 'Teachers';
                            _refresh();
                            //print(currentWidth);
                          });
                          _announcementsController.animateToPage(
                              _currentAnnouncement,
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeInOut);
                        },
                      ),
                      GestureDetector(
                          child: Text(
                            'Parents',
                            key: _textKeyParent,
                            style: TextStyle(
                                color: selectedColorP,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onTap: () {

                            setState(() {
                              selectedColorS = Colors.white;
                              selectedColorT = Colors.white;
                              selectedColorP = ColorsB.yellow500;
                              _alignment = Alignment.centerRight;
                              _currentAnnouncement = 2;
                              currentWidth = _textSize(labels[_currentAnnouncement], style).width;
                              currentChannel = 'Parents';
                              _refresh();
                              //print(currentWidth);
                            });

                            _announcementsController.animateToPage(
                                _currentAnnouncement,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut);
                          }
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedAlign(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 250),
                      alignment: _alignment,
                      child: SizedBox(
                        width: barWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: 2,
                            color: ColorsB.yellow500,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              );
            }
          ),
        ),
      );
    }
    else {
      return const SizedBox(width: 0, height: 0,);
    }
  }



  Widget _buildLists(Color _color) {


    if(!isError) {
      if(isLoading) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: maxScrollCount,
          itemBuilder: (_, index) =>
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Shimmer.fromColors(
                  baseColor: ColorsB.gray800,
                  highlightColor: ColorsB.gray700,
                  child: Container(                         // Student containers. Maybe get rid of the hero
                    width: screenWidth * 0.75,
                    height: 200,
                    decoration: BoxDecoration(
                      color: ColorsB.gray800,
                      borderRadius: BorderRadius.circular(
                          50),
                    ),
                  ),
                ),
              ),
        );
      }
      else {
        if(posts.isNotEmpty){
          return RefreshIndicator(
            backgroundColor: ColorsB.gray900,
            color: _color,
            onRefresh: () async {
              _refresh();
            },
            child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: maxScrollCount < posts.length ? maxScrollCount + 1 : posts.length,
                itemBuilder: (_, index) {

                  // title = titles[index];
                  // description = descriptions[index];
                  // var owner = owners[index];

                  if(index != maxScrollCount){
                    return posts[index];
                  }
                  else{
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Shimmer.fromColors(
                        baseColor: ColorsB.gray800,
                        highlightColor: ColorsB.gray700,
                        child: Container(                         // Student containers. Maybe get rid of the hero
                          width: screenWidth * 0.75,
                          height: 200,
                          decoration: BoxDecoration(
                            color: ColorsB.gray800,
                            borderRadius: BorderRadius.circular(
                                50),
                          ),
                        ),
                      ),
                    );
                  }
                }

            ),
          );
        }
        else {
          return Center(
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: SvgPicture.asset('assets/svgs/no_posts.svg')
                  ),
                  const Text(
                    'Wow! Such empty. So class.',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  Text(
                    "It seems the only thing here is a lonely Doge. Pet it or begone!",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextButton.icon(
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        _refresh();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: ColorsB.yellow500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              50),
                        ),
                      )
                  ),
                ],
              )
          );
        }
      }
    }
    else {
      return Center(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.3,
              child: SvgPicture.asset('assets/svgs/404.svg'),
            ),
            const Text(
              'Zap! Something went wrong!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            Text(
              "Please retry.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
            const SizedBox(height: 20,),
            TextButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                'Refresh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                _refresh();
              },
              style: TextButton.styleFrom(
                backgroundColor: ColorsB.yellow500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      50),
                ),
              )
            ),
          ],
        )
      );
    }

  }

  //  <------------------- Hardcoded loader ------------------>






Future<void> deletePost(int Id, int index) async {

    try {
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/deletepost.php');
      final response = await http.post(url, body: {
        "id": Id.toString()
      });

      print(response.statusCode);

      if(response.statusCode == 200){

        var jsondata = json.decode(response.body);
        print(jsondata);

        if(jsondata['error']){

          print('Errored');

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
              )
          );

        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                content: Row(
                  children: const [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 20,),
                    Text(
                      'Hooray! The post was deleted.',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              )
          );

          posts.removeAt(index);


        }



      }
      else {
        print("Deletion failed.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
            )
        );


      }

    } catch(e) {

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
          )
      );

      print(e);

    }


}



  Future<int> load(String channel) async {

    //  Maybe rework this a bit.

      try {
        var url = Uri.parse('https://cnegojdu.ro/GojduApp/selectposts.php');
        final response = await http.post(url, body: {
          "index": "0",
          "channel": channel,
        });
        //print(response.statusCode);
        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);

          if (jsondata["1"]["error"]) {
            setState(() {
              //nameError = jsondata["message"];
            });
          } else {
            if (jsondata["1"]["success"]) {

              for(int i = 2; i <= 52; i++)
              {
                String post = jsondata[i.toString()]["post"].toString();
                String title = jsondata[i.toString()]["title"].toString();
                String owner = jsondata[i.toString()]["owner"].toString();
                String link = jsondata[i.toString()]["link"].toString();


                int? likesCount = jsondata[i.toString()]["likes"];
                String? likedPpl = jsondata[i.toString()]["lppl"].toString();
                String? dislikedPpl = jsondata[i.toString()]["dppl"].toString();
                int? id = jsondata[i.toString()]["id"];

                List<String> liked = likedPpl.split(';');
                List<String> disliked = dislikedPpl.split(';');

                bool likedbool;
                bool dislikedbool;
                Color? color;

                switch(channel){
                  case 'Students':
                    color = ColorsB.gray800;
                    break;
                  case 'Teachers':
                    color = Colors.amber;
                    break;
                  case 'Parents':
                    color = Colors.indigoAccent;
                    break;
                }



                ////print(globalMap['id']);



                if(post != "null" && post != null){


                  if(liked.contains(globalMap['id'].toString())){
                    likedbool = true;
                    //print('a');
                  } else {
                    likedbool = false;
                  }

                  if(disliked.contains(globalMap['id'].toString())){
                    dislikedbool = true;
                  } else {
                    dislikedbool = false;
                  }

                  posts.add(Post(title: title,
                      color: color,
                      likes: likesCount,
                      likesBool: likedbool,
                      dislikes: dislikedbool,
                      ids: id,
                      descriptions: post,
                      owners: owner,
                      link: link,
                      hero: _hero,
                      admin: globalMap['account'],
                      delete: () async {
                        await deletePost(id!, i - 2);
                        setState(() {

                        });
                      },
                      globalMap: globalMap,
                      context: context,)
                  );



                  //(link);

                  // Prechaching the asset



                  ++maximumCount;
                }

                /* if(post != "null")
              {
                //print(post+ " this is the post");
                //print(title+" this is the title");
                //print(owner+ " this is the owner");
              } */

              }
              setState(() {
                isLoading = false;
                loaded = true;
              });
            }
            else
            {
              //print(jsondata["1"]["message"]);
            }
          }
        }
      } catch (e) {
        //print(e);
        if(isAlive){
          setState(() {
            isError = true;
          });
        }
      }

      return 0;

  }

  void update() {
    setState(() {

    });
  }


  // <-------------- Placing the hero container ---------------> //
  void _hero(BuildContext context, String title, String description, String author, Color color, String link, int? likes, int? ids, bool? dislikes, bool? likesBool, StreamController<int?> contrL, StreamController<bool> contrLB, StreamController<bool> contrDB) {
    Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secAnim) =>
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero
                ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.ease)
                ),
                child: BigNewsContainer(title: title, description: description, color: color, author: author, imageLink: link, likes: likes, ids: ids, dislikes: dislikes, likesBool: likesBool, contrL: contrL, contrLB: contrLB, contrDB: contrDB),
              )
        )
    );
  }




}




// <----------------- Making the 'News' container big ------------------>
//ignore: must_be_immutable
class BigNewsContainer extends StatefulWidget {

  final String title;
  final String description;
  final Color color;
  final String author;
  final String? imageLink;
  final File? file;
  int? likes, ids;
  bool? likesBool, dislikes;
  StreamController<int?>? contrL;
  StreamController<bool?>? contrLB;
  StreamController<bool?>? contrDB;


  BigNewsContainer({Key? key, required this.title, required this.description, required this.color, required this.author, this.imageLink, this.file, this.likes, this.likesBool, this.dislikes, this.ids, this.contrL, this.contrDB, this.contrLB}) : super(key: key);

  @override
  State<BigNewsContainer> createState() => _BigNewsContainerState();
}

class _BigNewsContainerState extends State<BigNewsContainer> {

  // <------------------- Like, Unlike, Dislike, Undislike functions ------------------>
  Future<void> like(int id, int uid) async{
    ////print(ids);

    if(widget.dislikes == true){
      undislike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes! + 1;
      widget.likesBool = true;

      widget.dislikes = false;

      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.likesBool);
      widget.contrDB!.add(widget.dislikes);
      //widget.update();
    });

    try{

      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          //print(jsondata['message']);
        }

        if(jsondata['success']){
          //print(jsondata);
        }
      }

    } catch(e){
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> unlike(int id, int uid) async{
    ////print(ids);

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;


      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.likesBool);

      //widget.update();

    });

    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          //print(jsondata['message']);
        }

        if(jsondata['success']){
          //print(jsondata);
        }
      }

    } catch(e){
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> dislike(int id, int uid) async{
    ////print(ids);

    if(widget.likesBool == true){
      unlike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;

      widget.dislikes = true;

      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.likesBool);
      widget.contrDB!.add(widget.dislikes);

      //widget.update();
    });

    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'DISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          //print(jsondata['message']);
        }

        if(jsondata['success']){
          //print(jsondata);
        }
      }

    } catch(e){
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> undislike(int id, int uid) async{
    ////print(ids);

    setState(() {
      widget.likes = widget.likes! + 1;

      widget.dislikes = false;

      widget.contrL!.add(widget.likes);
      widget.contrDB!.add(widget.dislikes);

      //widget.update();
    });

    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNDISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          //print(jsondata['message']);
        }

        if(jsondata['success']){
          //print(jsondata);
        }
      }

    } catch(e){
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }



  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    return Scaffold(
      bottomNavigationBar: const BackNavbar(),
      backgroundColor: ColorsB.gray900,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topPage(),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Linkify(
                linkStyle: const TextStyle(color: ColorsB.yellow500),
                text: widget.description,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.5,
                    fontWeight: FontWeight.normal
                ),
                onOpen: (link) async {
                  if (await canLaunch(link.url)) {
                    await launch(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
              )
            ),
          )

        ],
      ),
    ) ;
  }

  Widget topPage() {
    //print(widget.imageLink);
    if(widget.file == null){
      if(widget.imageLink == null || widget.imageLink == ''){
        return Hero(
          tag: 'title-rectangle',
          child: Container(
            width: screenWidth,
            height: screenHeight * 0.5,
            color: widget.color,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                            "by " + widget.author,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            )
                        )
                      ],
                    ),
                    globalMap['verification'] != 'Pending' && widget.likes != null
                        ? Row(
                          children: [
                          //   Like and dislike
                          IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              Icons.thumb_up,
                              color: widget.likesBool == true ? Colors.white : Colors.white.withOpacity(0.5),
                              size: 25,
                            ),
                            onPressed: () {
                              widget.likesBool == true ?
                              unlike(widget.ids!, globalMap['id'])
                                  : like(widget.ids!, globalMap['id']);
                            },
                          ),
                          Text(
                            widget.likes.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              Icons.thumb_down,
                              color: widget.dislikes == true ? Colors.white : Colors.white.withOpacity(0.5),
                              size: 25,
                            ),
                            onPressed: () {

                              widget.dislikes == true ?
                              undislike(widget.ids!, globalMap['id'])
                                  : dislike(widget.ids!, globalMap['id']);
                              //
                            },
                          ),
                        ]
                    )
                        : const SizedBox(),
                  ],
                )
              ),
            ),
          ),
        );
      }
      else {
        return Hero(
            tag: 'title-rectangle',
            child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              Material(
                                  color: Colors.transparent,
                                  child: Stack(
                                      children: [
                                        Center(
                                          child: InteractiveViewer(
                                              clipBehavior: Clip.none,
                                              child: Image(image: NetworkImage(widget.imageLink!))
                                          ),
                                        ),
                                        Positioned(
                                            top: 10,
                                            right: 10,
                                            child: IconButton(
                                                tooltip: 'Close',
                                                splashRadius: 25,
                                                icon: const Icon(Icons.close, color: Colors.white),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                }
                                            )
                                        )
                                      ]
                                  )
                              )
                      );
                    },
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(widget.imageLink!),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                          gradient: material.LinearGradient(
                              colors: [
                                Colors.black,
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [
                                0,
                                0.9
                              ]
                          )
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: screenWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                    "by " + widget.author,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    )
                                )
                              ],
                            ),

                            globalMap['verification'] != 'Pending' && widget.likes != null
                                ? Row(
                                  children: [
                                  //   Like and dislike
                                  IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      Icons.thumb_up,
                                      color: widget.likesBool == true ? Colors.white : Colors.white.withOpacity(0.5),
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      widget.likesBool == true ?
                                      unlike(widget.ids!, globalMap['id'])
                                          : like(widget.ids!, globalMap['id']);
                                    },
                                  ),
                                  Text(
                                    widget.likes.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      Icons.thumb_down,
                                      color: widget.dislikes == true ? Colors.white : Colors.white.withOpacity(0.5),
                                      size: 25,
                                    ),
                                    onPressed: () {

                                      widget.dislikes == true ?
                                      undislike(widget.ids!, globalMap['id'])
                                          : dislike(widget.ids!, globalMap['id']);
                                      //
                                    },
                                  ),
                                ]
                            )
                                : const SizedBox(),
                          ]
                        )
                      ),
                    ),
                  ),
                ]
            )
        );
      }
    }
    else {
      return Hero(
          tag: 'title-rectangle',
          child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            Material(
                                color: Colors.transparent,
                                child: Stack(
                                    children: [
                                      Center(
                                        child: InteractiveViewer(
                                            clipBehavior: Clip.none,
                                            child: Image(image: FileImage(widget.file!))
                                        ),
                                      ),
                                      Positioned(
                                          top: 10,
                                          right: 10,
                                          child: IconButton(
                                              tooltip: 'Close',
                                              splashRadius: 25,
                                              icon: const Icon(Icons.close, color: Colors.white),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }
                                          )
                                      )
                                    ]
                                )
                            )
                    );
                  },
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(widget.file!),
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                        gradient: material.LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [
                              0,
                              0.9
                            ]
                        )
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Text(
                            "by " + widget.author,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ]
          )
      );
    }
  }
}





class MapPage extends StatefulWidget {


  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  int floorNo = 0;

  // <---------- Function to switch the floor (placeholder) -------------------->
  void _mapUpdate(int newFloor) {
    setState(() {
      floorNo = newFloor;
    });
  }

  void updateThis(List<Floor> newFloors) {
    setState(() {
      floors = newFloors.toList();
      placeMaps();
    });
  }

  final height = ValueNotifier<double>(0);
  bool open = false;

  @override
  void initState() {

    placeMaps();
    super.initState();


    open = false;
  }

  @override
  void dispose() {
    height.dispose();
    super.dispose();
  }

  // <---------- Height and width outside of context -------------->
  var screenHeight = window.physicalSize.height / window.devicePixelRatio;
  var screenWidth = window.physicalSize.width / window.devicePixelRatio;


  //  Maps List
  List<Widget> maps = [];


  void placeMaps() {

    maps.clear();

    for(int i = 0; i < floors.length; i++){
      maps.add(GestureDetector(
        key: Key('$i'),
        child: Image.network(
          "https://cnegojdu.ro/GojduApp/floors/${floors[i].file}",
          key: Key('$i'),
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: screenHeight * 0.5,
              child: Center(
                  child: Shimmer.fromColors(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: ColorsB.gray800,
                    ),
                  ), baseColor: ColorsB.gray800, highlightColor: ColorsB.gray700)
              ),
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.3,
                  child: SvgPicture.asset('assets/svgs/404.svg'),
                ),
                const Text(
                  'Zap! Something went wrong!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
                Text(
                  "Please forgive us.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                const SizedBox(height: 20,),
              ],
            );
          },
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) =>
                  Material(
                      color: Colors.transparent,
                      child: Stack(
                          children: [
                            Center(
                              child: InteractiveViewer(
                                  clipBehavior: Clip.none,
                                  child: Image.network(
                                    "https://cnegojdu.ro/GojduApp/floors/${floors[i].file}",
                                    key: Key('$i'),
                                  )
                              ),
                            ),
                            Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                    tooltip: 'Close',
                                    splashRadius: 25,
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }
                                )
                            )
                          ]
                      )
                  )
          );
        },
      ));
    }
  }


  // <---------- Animated switcher children aka the maps ---------->
  Widget? _mapChildren() {


    if(floors.isEmpty){
      return SizedBox();
    }
    else {
      print(floorNo);
      print(floors[floorNo].file);
      print(floors);
      return maps[floorNo];
    }

  }


  @override
  Widget build(BuildContext context) {



    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Map', position: 0, accType: globalMap['account'] + ' account'),

        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Select floor',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontSize: 25,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          color: ColorsB.gray800,
                          height: 2,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 50,),

                  //Widgetul pt select floor

                  floors.isNotEmpty
                      ? Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 100),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                            child: _mapChildren(),
                            transitionBuilder: (child, animation) =>
                                SlideTransition(
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                  position: Tween<Offset>(
                                      begin: Offset(1, 0),
                                      end: Offset.zero
                                  ).animate(animation),
                                ),
                          ),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownSelector(update: _mapUpdate, floors: floors),
                            globalMap['account'] == "Admin"
                                ? TextButton.icon(
                                onPressed: () {
                                  Navigator.push(context, PageRouteBuilder(
                                      pageBuilder: (context, a1, a2) =>
                                          SlideTransition(
                                            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
                                            child: EditFloors(floors: floors, update: updateThis,),
                                          )
                                  )
                                  );
                                },
                                icon: Icon(Icons.edit, size: 20, color: Colors.white),
                                label: const Text(
                                  "Edit floors",
                                  style: TextStyle(
                                      color: Colors.white
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: ColorsB.gray800,
                                )
                            )
                                : const SizedBox(width: 0, height: 0),
                          ]
                      ),
                      //TODO: Add the images (at least a placeholder one and do the thingy)

                    ],
                  )
                      : Center(
                          child: Column(
                            children: [
                              const Text(
                                'No maps to display :(',
                                style: TextStyle(color: ColorsB.gray800, fontSize: 30),
                              ),
                              const SizedBox(height: 20),
                              TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, PageRouteBuilder(
                                        pageBuilder: (context, a1, a2) =>
                                            SlideTransition(
                                              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
                                              child: EditFloors(floors: floors, update: updateThis),
                                            )
                                    )
                                    );
                                  },
                                  icon: Icon(Icons.edit, size: 20, color: Colors.white),
                                  label: const Text(
                                    "Add floors",
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: ColorsB.gray800,
                                  )
                              )
                            ],
                          )
                   ),

                  // DropdownSelector(update: _mapUpdate,),
                  // //TODO: Add the images (at least a placeholder one and do the thingy)





                ],
              ),
            )
        )

      ],
    );



  }
}


class Calendar extends StatefulWidget {


  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}


class _CalendarState extends State<Calendar>{


  int maxStep = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = 0;

    maxStep = 0;
    


  }

  @override
  void dispose() {

    super.dispose();
  }

  Widget buildSteps(int no) {

    List<Widget> steps = [];

    for(int i = 1; i <= no; ++i){
      steps.add(AnimatedPadding(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 250),
        padding: currentPage == i - 1 ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
        child: AnimatedContainer(duration: const Duration(milliseconds: 250),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: currentPage == i - 1 ? ColorsB.yellow500 : ColorsB.gray800,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              '$i',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.normal
              ),
            ),
          ),
        ),
      ));
    }

    return SizedBox(
        height: screenHeight *.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: steps
        )
    );


  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Hall Manager', position: 2, accType: '${globalMap['account']} account'),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 0, 70),
            child: Row(
              children: [
                buildSteps(4),
                const SizedBox(width: 25),
                Expanded(
                  child: _calendarBuild(),

                  )
              ],
            ),
          ),
        )

      ],
    );
  }


  List<Widget> stepsText = [
    const Text(
      'Select your hall.',
      style:  TextStyle(
        color: Colors.white,
        fontSize: 20,
      )
    ),
    const Text(
      'Select the day of interest.',
      style:  TextStyle(
        color: Colors.white,
        fontSize: 20,
      )
    ),
    const Text(
      'Select the time interval.',
      style:  TextStyle(
        color: Colors.white,
        fontSize: 20,
      )
    ),
    const Text(
      'Profit!',
      style:  TextStyle(
        color: Colors.white,
        fontSize: 20,
      )
    ),
  ];


  Widget _stepsText(){
    return SizedBox(
      key: Key("$currentPage"),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          stepsText[currentPage]
        ]
      ),
    );

  }


  Widget _calendarBuild() {
    if(_connectionStatus == ConnectivityResult.none){
      return  Center(
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                child: SvgPicture.asset('assets/svgs/calendar.svg'),
              ),
              const Text(
                'Aww! Something went wrong!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                "To be able to use our hall booking feature, please connect to the Internet.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
            ],
          )
      );
    }
    return Stack(
      children: [
        SizedBox(
          child: Column(
            children: [

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if(currentPage != 0){

                        _changePage(0);

                      }
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: currentPage != 0 ? Colors.white : Colors.white.withOpacity(0.5)
                      , size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 500),
                      //  switchOutCurve: Curves.easeInOut,
                      child: _stepsText(),
                      transitionBuilder: (child, animation, secondaryAnimation) =>
                          SharedAxisTransition(animation: animation, secondaryAnimation: secondaryAnimation, transitionType: SharedAxisTransitionType.vertical, child: child, fillColor: Colors.transparent,)
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: screenHeight * .75,
                child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 750),
                    reverse: true,
                    transitionBuilder: (child, animation, anim2) {
                      return SharedAxisTransition(
                        fillColor: ColorsB.gray900,
                        animation: animation,
                        secondaryAnimation: anim2,
                        child: child,
                        transitionType: SharedAxisTransitionType.vertical,
                      );
                    },
                    child: currentPage == 0 ? CalPag1(changePage: _changePage,) : CalPag2(changePage: _changePage,)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  //  TODO: Implement the page changing logic

  //  <------------  Building the widgets for the animated switcher  ------------>
  int currentPage = 1;

  void _changePage(int page) {

    setState(() {
      if(page > currentPage){
        maxStep = page;
      }
      currentPage = page;
    });
  }


}

//  <-----------------  Calendar page 1 ------------------>
class CalPag1 extends StatefulWidget {

  final Function(int) changePage;

  const CalPag1({Key? key, required this.changePage}) : super(key: key);

  @override
  State<CalPag1> createState() => _CalPag1State();
}

class _CalPag1State extends State<CalPag1> {

  late Function(int) changePage;
  bool ok = false;

  @override
  void initState() {
    changePage = widget.changePage;
    ok = false;
    _loadHalls();
    super.initState();
  }

  @override
  void dispose() {
    halls.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          if (ok == false) ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) =>
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 125,
                    child: Shimmer.fromColors(
                      highlightColor: ColorsB.gray700,
                      baseColor: ColorsB.gray800,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: ColorsB.gray800,
                        ),
                      ),
                    )
                  ),
                )
          ) else ListView.builder(
            clipBehavior: Clip.hardEdge,         //  Find a way to do it better
            physics: const BouncingScrollPhysics(),
            itemCount: halls.isNotEmpty ? halls.length : 1,
            itemBuilder: (context, index) {
              if(halls.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: halls[index],
                );
              }
              else {
                // Return a nice No halls found message followed by the no_posts svg
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Wow, such empty!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        'No halls found',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      SvgPicture.asset(
                        'assets/svgs/no_posts.svg',
                        height: 200,
                      ),
                    ],
                  ),
                );



              }
            },
          ),

          Visibility(
            visible: globalMap['account'] == 'Admin' ? true : false,
            child: Positioned(
              bottom: screenHeight * .1,
              right: screenWidth * .05,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: () {

                    // Title controller
                    final TextEditingController titleController = TextEditingController();

                    //  Form key
                    final formKey = GlobalKey<FormState>();
                    var size, errorText;
                    bool clicked = false;

                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (_) =>
                          StatefulBuilder(
                            builder: (_, setState){
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: ColorsB.gray900,
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextButton(
                                        onPressed: () {
                                          //  titleController.dispose();
                                          errorText = size = null;
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                  content: SizedBox(
                                    height: 250,
                                    child: Center(
                                      child: Form(
                                        key: formKey,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        child: Column(
                                          children: [
                                            // Title form text field and a dropdown with 3 options: Small, Medium, Large
                                            TextFormField(
                                              cursorColor: ColorsB.yellow500,
                                              controller: titleController,
                                              decoration: const InputDecoration(
                                                labelText: 'Title',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorsB.yellow500,
                                                  ),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter a title';
                                                }
                                                return null;
                                              },
                                            ),

                                            // Drowpdown with 3 options: Small, Medium, Large
                                            DropdownButtonFormField(
                                              decoration: InputDecoration(
                                                labelText: 'Size',
                                                errorText: errorText,
                                                labelStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                                enabledBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                focusedBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorsB.yellow500,
                                                  ),
                                                ),
                                              ),
                                              dropdownColor: ColorsB.gray800,
                                              value: size,
                                              items: const [
                                                DropdownMenuItem(
                                                  child: Text(
                                                      'Small',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  value: 'Small',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text('Medium', style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),),
                                                  value: 'Medium',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text('Large', style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),),
                                                  value: 'Large',
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  size = value;
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select a size';
                                                }
                                                return null;
                                              },
                                            ),

                                            // Button to send the data
                                            const SizedBox(height: 20),

                                            clicked == false
                                                ? TextButton.icon(
                                                icon: const Icon(
                                                Icons.send,
                                                color: Colors.white,
                                              ),
                                                label: const Text(
                                                'Send',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                                onPressed: () async {

                                                if (formKey.currentState!.validate()) {
                                                  if(size == null){
                                                    setState(() {
                                                      errorText = 'Please select a size';
                                                    });
                                                    return;



                                                  }
                                                  setState(() {
                                                    clicked = true;
                                                  });

                                                  try {
                                                    var url = Uri.parse('https://cnegojdu.ro/GojduApp/halls.php');
                                                    final response = await http.post(url, body: {
                                                      "action": 'INSERT', // Or IMPORT
                                                      "title": titleController.text,
                                                      "size": size,
                                                    });
                                                    if(response.statusCode == 200){
                                                      var jsondata = json.decode(response.body);
                                                      if (jsondata["1"]["error"]) {
                                                        setState(() {
                                                          errorText = jsondata["1"]["message"];
                                                        });
                                                      }
                                                      else if(jsondata['1']['success']){
                                                        setState(() {
                                                          clicked = false;
                                                          // Pop the screen
                                                          Navigator.of(context).pop();
                                                        });

                                                      }
                                                    }


                                                  }
                                                  catch (e) {
                                                    ////print(e);
                                                    setState(() {
                                                      errorText = 'Error connecting to server';
                                                      clicked = false;
                                                    });
                                                  }



                                                }
                                              },
                                            )
                                                : const CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            )


                                          ],
                                        ),

                                      ),
                                    ),
                                  )
                              );
                            }
                          )

                    );

                  },
                  child: const Icon(Icons.add),
                  backgroundColor: ColorsB.yellow500,
                  mini: true,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Future<int> _loadHalls() async {
    //await Future.delayed(const Duration(seconds: 1));
    //titles.isNotEmpty && sizes.isNotEmpty ? hasLoaded = true : hasLoaded = false;

    try {
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/halls.php');
      final response = await http.post(url, body: {
        "action": 'IMPORT', // Or INSERT
      });
      //print('Gojdu: ${response.statusCode}');
      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        //print(jsondata);
        if(jsondata['1']['success']){


          for(int i = 2; i < jsondata.length; i++) {

            var title = jsondata[i.toString()]['title'];
            var size = jsondata[i.toString()]['size'];

            if (title != null && size != null) {

              Hall hall = Hall(index: i-2, title: title, size: size, changePage: changePage, Id: jsondata[i.toString()]['id']);

              halls.add(hall);
              //print(halls);

            }
            else {
              break;
            }
          }

        }
        else{
          //return 0;
        }
      }
      else{

      }
    } catch (e) {
      ////print(e);
      //return 0;
    }
    setState(() {
      ok = true;
    });

    // This is where the halls are loaded.
    return 1;
  }

}


List<Hall> halls = [];




// <------------------ Current Hall ------------------------>

int? _currentHall;



// Class for the container
class Hall extends StatelessWidget {
  final int index;
  final String title;
  final String size;
  final int Id;
  final Function(int) changePage;
  const Hall({Key? key, required this.index, required this.title, required this.size, required this.changePage, required this.Id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: ColorsB.gray800,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            _currentHall = Id;
            changePage(1);
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const material.LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0, 1],
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Icon(
                    Icons.account_balance_sharp,
                    color: ColorsB.gray700.withOpacity(0.25),
                    size: 75,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          color: ColorsB.yellow500,
                          size: 20,
                        ),
                        const SizedBox(width: 10,),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              title,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      thickness: 1,
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      'Type: ${size}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



//  <-----------------  Statefull cal page 2 ----------------->
class CalPag2 extends StatefulWidget {
  final Function(int) changePage;
  const CalPag2({Key? key, required this.changePage}) : super(key: key);

  @override
  State<CalPag2> createState() => _CalPag2State();
}



class _CalPag2State extends State<CalPag2> with TickerProviderStateMixin {

  //  <---------------- Animations for the calendar --------------------->


  var _focusedDay;
  var _selectedDay;
  var _calendarFormat;

  late double width;

  @override
  void initState() {
    // TODO: implement
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
    _events = {};
    _selectedEvents = [];
    width = 175;

    super.initState();
  }



  @override
  void dispose() {
    super.dispose();
  }

  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;

  List<dynamic> _getEventsFromDay(DateTime date) {

    return _events[date] ?? [];
  }

  Future<int> _getList(DateTime date) async {
    try {
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/selectbookings.php');
      final response = await http.post(url, body: {
        "hall": _currentHall.toString(),
        "day": DateFormat('yyyy-MM-dd').format(date).toString(),
      });
      //print(response.statusCode);
      //print("im heree");
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //print(jsondata);

        if (jsondata["1"]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata["1"]["success"]) {
            if(_events[_selectedDay] != null && _events[_selectedDay]!.contains(['Error! Please try again!'])){
              _events[_selectedDay]!.clear();
            }

              for(int i = 2; i < 10; i++){
                if(jsondata[i.toString()] != null){
                  String begin = jsondata[i.toString()]["begin"].toString();
                  String? end = jsondata[i.toString()]["end"].toString();
                  String? owner = jsondata[i.toString()]["owner"].toString();
                  ////print(begin);
                  ////print(end);
                  ////print(owner);

                  if(begin != 'null' && end != 'null' && owner != 'null'){
                    if(_events[date] != null && !(_events[date]!.contains('${begin.substring(0, begin.length - 3)}  -  ${end.substring(0, end.length - 3)}  -  ${owner}')) ){
                      _events[_selectedDay]!.add('${begin.substring(0, begin.length - 3)}  -  ${end.substring(0, end.length - 3)}  -  ${owner}');
                    }
                    else {
                      _events[_selectedDay] = ['${begin.substring(0, begin.length - 3)}  -  ${end.substring(0, end.length - 3)}  -  ${owner}'];
                    }
                  }
                }
            }



            /* if(post != "null")
              {
                //print(post+ " this is the post");
                //print(title+" this is the title");
                //print(owner+ " this is the owner");
              } */

          }
        }
      }
    } catch (e) {
      _events[_selectedDay] = ['Error! Please try again!'];

    }
    return 0;
  }

  void _getWeekEvents(DateTime date) {

    for(int i = 0; i < 7; i++){
      _getList(date);
      date = date.add(const Duration(days: 1));
    }
  }


  bool overlap(String _selectedBegin, String _selectedEnd) {
    
    var _selectedBeginTime = DateTime.parse('20120227 $_selectedBegin:00');
    var _selectedEndTime = DateTime.parse('20120227 $_selectedEnd:00');
    
    for(int i = 0; i < _events[_selectedDay]!.length; i++){
      String begin = _events[_selectedDay]![i].split("  -  ")[0];
      String end = _events[_selectedDay]![i].split("  -  ")[1];
    
      var _beginTime = DateTime.parse('20120227 $begin');
      var _endTime = DateTime.parse('20120227 $end');
      
      if(_selectedBeginTime.isBefore(_beginTime) && _selectedEndTime.isBefore(_beginTime) ||
        _selectedBeginTime.isAfter(_endTime) && _selectedEndTime.isAfter(_endTime)){
        return true;
      }

    }
    return false;


  }


  // <-----------------  Time Pickers ----------------->
  late String _time1;
  late String _time2;


  // TODO: Get the data from the server and shit.

  String convertTo24(String time){
    var splitTime = time.split(' ');
    var period = splitTime.last;
    var hour = splitTime.first.split(':').first;
    var minutes = splitTime.first.split(':').last;
    if(period == 'PM'){
      hour = (int.parse(hour) + 12).toString();
    }
    return '$hour:$minutes';

  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 500),
                height: width,
                decoration: BoxDecoration(
                  color: ColorsB.gray800,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        eventLoader: _getEventsFromDay,

                        daysOfWeekHeight: 30,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          decoration: BoxDecoration(
                            color: ColorsB.yellow500.withOpacity(1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          titleTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          formatButtonShowsNext: false,
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        shouldFillViewport: false,
                        calendarStyle: CalendarStyle(
                          markerDecoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          disabledTextStyle: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 12,
                          ),
                          weekendTextStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.25),
                            fontSize: 12,
                          ),

                          selectedDecoration: BoxDecoration(
                              color: ColorsB.yellow500,
                              shape: BoxShape.circle
                          ),
                          isTodayHighlighted: false,
                        ),
                        firstDay: DateTime.now().toUtc(),
                        lastDay: DateTime.utc(2040, 4, 12),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {

                            widget.changePage(2);
                            _selectedDay = selectedDay;
                            //print(_selectedDay);
                            _focusedDay = focusedDay;
                            width = 300;
                          });
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Occupied Hours',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextButton(
                                        onPressed: () {
                                          if(globalMap['verification'] != "Pending"){
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  var timeText = TextEditingController();
                                                  var timeText2 = TextEditingController();

                                                  TimeOfDay? parsedTime1;
                                                  TimeOfDay? parsedTime2;

                                                  var _formKey = GlobalKey<FormState>();
                                                  var errorText1, errorText2;

                                                  bool clicked = false;



                                                  return StatefulBuilder(
                                                      builder: (_, StateSetter setState) =>
                                                          AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(30),
                                                              ),
                                                              backgroundColor: ColorsB.gray900,
                                                              content: SizedBox(
                                                                height: 200,
                                                                child: Center(
                                                                  child: Form(
                                                                    key: _formKey,
                                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            const Text(
                                                                              'From: ',
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 200,
                                                                              height: 50,
                                                                              child: TextFormField(
                                                                                controller: timeText,
                                                                                style: const TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                ),

                                                                                readOnly: true,
                                                                                decoration: InputDecoration(
                                                                                  errorText: errorText1,
                                                                                  icon: Icon(Icons.timer, color: Colors.white.withOpacity(0.5),), //icon of text field
                                                                                  labelText: "Enter Time", //label text of field
                                                                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), //style of label text
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                                                                                  ),
                                                                                  enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5))), //border of text field
                                                                                ),

                                                                                onTap: () async {
                                                                                  TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                                  //print(pickedTime.toString());
                                                                                  if(pickedTime != null){
                                                                                    parsedTime1 = pickedTime;
                                                                                    //DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                                                                    String formattedTime = convertTo24(pickedTime.format(context));
                                                                                    //  //print(formattedTime);
                                                                                    setState(() {
                                                                                      timeText.text = formattedTime;
                                                                                      _time1 = formattedTime;
                                                                                      //print(formattedTime);

                                                                                    });
                                                                                  }

                                                                                },

                                                                                validator: (value) {
                                                                                  if(value == null || value.isEmpty){
                                                                                    return "Please enter time";
                                                                                  }
                                                                                  else if(parsedTime1 != null && parsedTime2 != null){
                                                                                    if(parsedTime1!.hour > parsedTime2!.hour || ((parsedTime1!.hour == parsedTime2!.hour) && (parsedTime1!.minute >= parsedTime2!.minute))){
                                                                                      return "Please enter valid time";
                                                                                    }
                                                                                  }
                                                                                  return null;
                                                                                },

                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            const Text(
                                                                              'To: ',
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 200,
                                                                              height: 50,
                                                                              child: TextFormField(
                                                                                controller: timeText2,
                                                                                style: const TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                ),

                                                                                readOnly: true,
                                                                                decoration: InputDecoration(
                                                                                  errorText: errorText2,
                                                                                  icon: Icon(Icons.timer, color: Colors.white.withOpacity(0.5),), //icon of text field
                                                                                  labelText: "Enter Time", //label text of field
                                                                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), //style of label text
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                                                                                  ),
                                                                                  enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5))), //border of text field
                                                                                ),

                                                                                onTap: () async {
                                                                                  TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                                  parsedTime2 = pickedTime;
                                                                                  if(pickedTime != null){

                                                                                    String formattedTime = convertTo24(pickedTime.format(context));
                                                                                    //  //print(formattedTime);
                                                                                    setState(() {
                                                                                      timeText2.text = formattedTime;
                                                                                      _time2 = formattedTime;
                                                                                    });
                                                                                  }
                                                                                },
                                                                                validator: (value) {
                                                                                  if(value == null || value.isEmpty){
                                                                                    return "Please enter time";
                                                                                  }
                                                                                  else if(parsedTime1 != null && parsedTime2 != null){
                                                                                    if(parsedTime1!.hour > parsedTime2!.hour || ((parsedTime1!.hour == parsedTime2!.hour) && (parsedTime1!.minute >= parsedTime2!.minute))){
                                                                                      return "Please enter valid time";
                                                                                    }
                                                                                  }
                                                                                  return null;
                                                                                },

                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TextButton.icon(
                                                                          onPressed: () async {
                                                                            if(_events[_selectedDay] != null){
                                                                              if(!overlap(_time1, _time2)){
                                                                                setState(() {
                                                                                  errorText1 = errorText2 = 'Overlapping!';
                                                                                });
                                                                                return;
                                                                              }
                                                                            }

                                                                            if(_formKey.currentState!.validate()){
                                                                              try {
                                                                                setState(() {
                                                                                  clicked = true;
                                                                                });
                                                                                var url = Uri.parse('https://cnegojdu.ro/GojduApp/insertbookings.php');
                                                                                final response = await http.post(url, body: {
                                                                                  "day": _selectedDay.toString().split(' ').first,
                                                                                  "start": _time1+":00",
                                                                                  "end": _time2+":00",
                                                                                  "hall": _currentHall.toString(),
                                                                                  "owner": globalMap["first_name"] + " " + globalMap["last_name"],
                                                                                });
                                                                                //print(response.statusCode);
                                                                                //print("does work");
                                                                                if (response.statusCode == 200) {
                                                                                  var jsondata = json.decode(response.body);
                                                                                  //print(jsondata);
                                                                                  if (jsondata["error"]) {
                                                                                  } else {
                                                                                    if (jsondata["success"]){
                                                                                      Navigator.pop(context);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                      //print(jsondata["message"]);
                                                                                    }
                                                                                  }
                                                                                }
                                                                                //print(_events);

                                                                                widget.changePage(3);
                                                                                setState(() {

                                                                                });
                                                                              } catch (e){
                                                                                _events[_selectedDay] = ['Error! Please try again!'];
                                                                              }
                                                                            }
                                                                          },
                                                                          icon: !clicked ? const Icon(
                                                                            Icons.add_circle,
                                                                            color: Colors.white,
                                                                          ) : const SizedBox(),
                                                                          label: !clicked ? const Text(
                                                                            'Reserve',
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                            ),
                                                                          ) : const CircularProgressIndicator(
                                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                          ),
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                          )
                                                  );
                                                }

                                            );
                                          }
                                          else {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (_) =>
                                                AlertDialog(
                                                  backgroundColor: ColorsB.gray900,
                                                  clipBehavior: Clip.hardEdge,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Okay", style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: Colors.white),),
                                                    ),
                                                  ],
                                                  content: SizedBox(
                                                    height: screenHeight * 0.5,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 200,
                                                          child: SvgPicture.asset(
                                                            'assets/svgs/locked.svg',
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'Oops! You can\'t do that!',
                                                          style: TextStyle(
                                                            fontFamily: 'Nunito',
                                                            fontSize: 17.5,
                                                            color: ColorsB.yellow500,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 25),
                                                        Text(
                                                          'Currently you are unverified, meaning that you won\'t be able to use all the features withing the app. \n\nIf you are actually verified, please restart the app.',
                                                          style: TextStyle(
                                                            fontFamily: 'Nunito',
                                                            fontSize: 13,
                                                            color: Colors.white.withOpacity(0.5),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            );
                                          }
                                        },
                                        child: globalMap['verification'] != "Pending"
                                        ? const Text(
                                          'Reserve',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.lock_outline,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                        style: ButtonStyle(
                                          elevation: MaterialStateProperty.all(0),
                                          backgroundColor: globalMap["verification"] != "Pending" ? MaterialStateProperty.all<Color>(ColorsB.yellow500) : MaterialStateProperty.all<Color>(ColorsB.gray700),
                                          shape: MaterialStateProperty.all<OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                          ),
                                        )
                                    ),
                                  )
                                ],
                              ),
                              FutureBuilder(
                                  future: _getList(_selectedDay),
                                  builder: (context, snpshot) {
                                    if(snpshot.hasData) {
                                      return SizedBox(
                                          height: 100,
                                          child: _events[_selectedDay] != null
                                              ? ListView.builder(
                                            physics: const BouncingScrollPhysics(),
                                            padding: EdgeInsets.zero,
                                            itemCount: _events[_selectedDay]!.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Padding(
                                                padding: const EdgeInsets.all(2.5),
                                                child: Container(
                                                  child: Text(
                                                    _events[_selectedDay]![index],
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                              : Center(
                                            child: FadeTransition(
                                              opacity: Tween<double>(begin: 0, end: 1).animate(AnimationController(
                                                vsync: this,
                                                duration: const Duration(milliseconds: 500),
                                              )..forward()),
                                              child: Text(
                                                'No events for this day. Yay!',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.white.withOpacity(0.25),
                                                ),
                                              ),
                                            ),
                                          )
                                      );
                                    }
                                    else {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),
                                        ),
                                      );
                                    }
                                  }
                              ),


                            ],
                          )
                      )

                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }


}



DateTime join(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}




class PostItPage extends StatefulWidget {
  const PostItPage({Key? key}) : super(key: key);

  @override
  State<PostItPage> createState() => _PostItPageState();
}

class _PostItPageState extends State<PostItPage> {

  //  <---------------  Post controller ---------------->
  late TextEditingController _postController;
  late TextEditingController _postTitleController;

  // <---------------  Colors for the preview -------------->
  late Color? _postColor;
  late String? _className;


  // <---------------  Form key -------------->
  late final GlobalKey<FormState> _formKey;



  // Firebase stuff




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postController = TextEditingController();
    _postTitleController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _postColor = null;
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  List<bool?> classes = [false, false, false];
  List<String> channels = [];
  String errorText = '';

  //  Image text
  String _imageText = 'Add Image';
  final ImagePicker _picker = ImagePicker();
  late XFile? image;
  File? _file;

  String? format;



  String generateString(){
    String generated = '';

    DateTime now = DateTime.now();
    String formatedDate = DateFormat('yyyyMMddkkmm').format(now);

    String selectedChannels = '';
    for(int i = 0; i < channels.length; i++){
      selectedChannels += channels[i][0];
    }

    generated = selectedChannels + formatedDate;

    return generated;


  }

  Future<void> uploadImage(File? file, String name) async {
    try{
      if(image == null || file == null){
        return;
      }
      var imageBytes = file.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);



      var url = Uri.parse('https://cnegojdu.ro/GojduApp/image_upload.php');
      final response = await http.post(url, body: {
        "image": baseimage,
        "name": name,
        "format": format
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata["error"]){
          //print(jsondata["msg"]);
        }else{
          //print("Upload successful");
        }
      } else {
        //print("Upload failed");
      }




    }
    catch(e){
      //print("Error during converting to Base64");
    }
  }





  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorsB.gray900,
        bottomNavigationBar: const BackNavbar(variation: 1,),
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: AppBar(
            backgroundColor: ColorsB.gray900,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(35, 50, 0, 0),
              child: Row(
                children: const [
                  Icon(Icons.book, color: ColorsB.yellow500, size: 40,),
                  SizedBox(width: 20,),
                  Text(
                    'Make a new post',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(fieldName: 'Choose a title', isPassword: false, errorMessage: '', controller: _postTitleController, isEmail: false,),
                  const SizedBox(height: 50,),
                  const Text(
                    'Post contents',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _postController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    cursorColor: ColorsB.yellow500,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.red,
                        )
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field cannot be empty.';
                      }
                    },
                  ),
                  const SizedBox(height: 50,),
                  const Text(
                    'Select channel',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  //ClassSelect(update: _updatePreview,),
                  // Make 3 checkboxes for the 3 channels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: ColorsB.yellow500,
                            shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 1)),
                            side: const BorderSide(color: Colors.white, width: 1),
                            value: classes[0],
                            onChanged: (value) {
                              setState(() {
                                classes[0] = value;
                                if(value!){
                                  channels.add("Students");
                                }
                                else {
                                  channels.remove("Students");
                                }
                                //print(channels);
                              });
                            },
                          ),
                          const Text(
                            'Students',
                            style: TextStyle(
                              color: Colors.white
                            )
                          )
                        ]
                      ),
                      Row(
                          children: [
                            Checkbox(
                              activeColor: ColorsB.yellow500,
                              shape: const CircleBorder(),
                              side: const BorderSide(color: Colors.white, width: 1),
                              value: classes[1],
                              onChanged: (value) {
                                setState(() {
                                  classes[1] = value;

                                  if(value!){
                                    channels.add("Teachers");
                                  }
                                  else {
                                    channels.remove("Teachers");
                                  }
                                  //print(channels);
                                });
                              },
                            ),
                            const Text(
                                'Teachers',
                                style: TextStyle(
                                    color: Colors.white
                                )
                            )
                          ]
                      ),
                      Row(
                          children: [
                            Checkbox(
                              activeColor: ColorsB.yellow500,
                              shape: const CircleBorder(),
                              side: const BorderSide(color: Colors.white, width: 1),
                              value: classes[2],
                              onChanged: (value) {
                                setState(() {
                                  classes[2] = value;

                                  if(value!){
                                    channels.add("Parents");
                                  }
                                  else {
                                    channels.remove("Parents");
                                  }
                                  //print(channels);
                                });
                              },
                            ),
                            const Text(
                                'Parents',
                                style: TextStyle(
                                    color: Colors.white
                                )
                            )
                          ]
                      ),
                    ]
                  ),
                  const SizedBox(height: 10),
                  Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),

                  ),

                  const SizedBox(height: 25),
                  ExpansionTile(

                    collapsedIconColor: ColorsB.gray800,
                    iconColor: ColorsB.yellow500,
                    title: const Text(
                      'Header Image - Optional',
                      style: TextStyle(
                        color: ColorsB.yellow500,
                      ),
                    ),
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          //  Image picker things

                          try{
                            final _image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
                            if(_image == null) return;

                            image = _image;
                            _file = File(image!.path);

                            format = image!.name.split('.').last;

                            setState(() {
                              _imageText = image!.name;
                            });
                          } catch(e) {
                            setState(() {
                              _imageText = 'Error! ${e.toString()}';
                            });
                          }

                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                        ),
                        label: Text(
                          _imageText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.white,

                          ),
                        ),
                      )
                    ],
                  ),


                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {

                          if(_formKey.currentState!.validate()){
                            if(channels.isEmpty){
                              setState(() {
                                errorText = 'Please select at least one class';
                              });
                              return;
                            }
                            showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),),));
                            setState(() {
                              errorText = '';
                            });

                            String name = generateString();

                            bool imgSub = false;

                            for(int i = 0; i < channels.length; i++){
                              try {


                                if(!imgSub && _file != null){
                                  await uploadImage(_file, name);
                                  imgSub = true;
                                }
                                //print(channels[i]);

                                //print(_file);

                                var url = Uri.parse('https://cnegojdu.ro/GojduApp/insertposts.php');
                                final response;
                                if(_file != null){
                                  response = await http.post(url, body: {
                                    "title": _postTitleController.value.text,
                                    "channel": channels[i],
                                    "body": _postController.value.text,
                                    "owner": globalMap["first_name"] + " " + globalMap["last_name"],
                                    "link": "https://cnegojdu.ro/GojduApp/imgs/$name.$format"
                                  });
                                }
                                else {
                                  response = await http.post(url, body: {
                                    "title": _postTitleController.value.text,
                                    "channel": channels[i],
                                    "body": _postController.value.text,
                                    "owner": globalMap["first_name"] + " " + globalMap["last_name"],
                                    "link": ""
                                  });
                                }
                                if (response.statusCode == 200) {
                                  var jsondata = json.decode(response.body);
                                  //print(jsondata);
                                  if (jsondata["error"]) {
                                    Navigator.of(context).pop();
                                  } else {
                                    if (jsondata["success"]){

                                      // Notifications

                                      // --------------------------------------------------


                                      try {
                                        var ulr2 = Uri.parse('https://cnegojdu.ro/GojduApp/notifications.php');
                                        final response2 = await http.post(ulr2, body: {
                                          "channel": channels[i],
                                          "owner": globalMap["first_name"] + " " + globalMap["last_name"],
                                          "action": "Post"
                                        });

                                        if(response2.statusCode == 200){
                                          var jsondata2 = json.decode(response2.body);
                                          //print(jsondata2);
                                          Navigator.of(context).pop();
                                        }

                                      } catch (e) {
                                        //print(e);
                                      }

                                      // -------------------------------------------------
                                    }
                                    else
                                    {
                                      //print(jsondata["message"]);
                                    }
                                  }
                                }
                              } catch (e) {
                                //print(e);
                                //Navigator.of(context).pop();
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                  content: Row(
                                    children: const [
                                      Icon(Icons.check, color: Colors.white),
                                      SizedBox(width: 20,),
                                      Text(
                                        'Hooray! A new post was born.',
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            );

                            Navigator.of(context).pop();

                            //TODO: There is some unhandled exception and I have no fucking idea where. - Mihai
                          }

                        },
                        child: const Text(
                          'Post',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 2.5,
                            fontSize: 20,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          backgroundColor: _postController.text.isEmpty || _postTitleController.text.isEmpty || channels.isEmpty ? ColorsB.gray800 : ColorsB.yellow500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: _postTitleController.text.isEmpty || _postController.text.isEmpty  || channels.isEmpty ? 0.5 : 1,
                        child: TextButton(
                          onPressed: () async {



                            //TODO: Make the upload work


                            if(_formKey.currentState!.validate() && !(classes[0] == false && classes[1] == false && classes[2] == false)) {

                              if(classes[0] == true){
                                _postColor = ColorsB.gray800;
                              } else if(classes[1] == true){
                                _postColor = Colors.amber;
                              } else if(classes[2] == true){
                                _postColor = Colors.indigoAccent;
                              }


                              Navigator.of(context).push(
                                  PageRouteBuilder(
                                      pageBuilder: (context, animation, secAnim) {

                                        return SlideTransition(
                                          position: Tween<Offset>(
                                              begin: const Offset(0, 1),
                                              end: Offset.zero
                                          ).animate(
                                              CurvedAnimation(parent: animation, curve: Curves.ease)
                                          ),
                                          child: BigNewsContainer(title: _postTitleController.value.text, description: _postController.value.text, color: _postColor!, author: 'By Me', file: _file,),
                                        );
                                      }

                                  )
                              );
                            }



                          },
                          child: const Text(
                            'Preview',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 2.5,
                              fontSize: 20,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            backgroundColor: ColorsB.gray800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 100,),
                ],
              ),
            ),
         ),
        ),
      ),
    );
  }
}







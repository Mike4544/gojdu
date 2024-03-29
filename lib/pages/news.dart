import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/api.dart';
import 'package:gojdu/pages/replyNotifPage.dart';
import 'package:gojdu/pages/schoolFiles.dart';
import 'package:gojdu/pages/settings.dart';
import 'package:gojdu/pages/threads.dart';
import 'package:gojdu/widgets/profilePics.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
//import 'package:gojdu/widgets/class_selector.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/widgets/input_fields.dart';
//import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/floor_selector.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';
//import 'package:gojdu/others/event.dart';
import 'package:intl/intl.dart';

//  Connectivity
import 'package:connectivity_plus/connectivity_plus.dart';

// SVG
import 'package:flutter_svg/flutter_svg.dart';

// Firebase for messaging
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gojdu/widgets/post.dart';

import 'package:gojdu/pages/editTables.dart';
import 'package:gojdu/others/floor.dart';

import 'package:gojdu/pages/menus.dart';
import '../widgets/Event.dart';
import '../widgets/course.dart';
import '../widgets/filters.dart';
import '../widgets/lazyBuilder.dart';
import '../widgets/navbarButton.dart';
import '../widgets/textPP.dart';
import './notes.dart';

import './alertPage.dart';

//  import '../databases/alertsdb.dart';

// For vibration

import '../widgets/switchPosts.dart';

import 'EventPage.dart';

import './myTimetable.dart';

import './opportunities.dart';

import './offersPage.dart';

import './sendFeedback.dart';

import 'package:gojdu/others/options.dart';

import 'notifications.dart';

class NewsPage extends StatefulWidget {
  final Map data;
  final bool? newlyCreated;
  ValueNotifier notifs;

  NewsPage(
      {Key? key, required this.data, this.newlyCreated, required this.notifs})
      : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

// //Globals
// SMIInput<bool>? _mapInput, _announcementsInput, _reserveInput;
late bool loaded;

late Map globalMap;

int currSelect = 0;

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// List<Floor> floors = [
//   // Floor(floor: 'parter', file: 'parter.png'),
//   // Floor(floor: 'parter', file: 'parter.png'),
//   // Floor(floor: 'parter', file: 'parter.png'),
// ];

//  bool mapErrored = false;

List<String> titles = [];
List<String> sizes = [];

var bar1Key = GlobalKey();
var bar2Key = GlobalKey();

// <---------- Height and width outside of context -------------->
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

//  TODO: Make variables for the name, password, mail etc

ConnectivityResult? _connectionStatus;

class _NewsPageState extends State<NewsPage> {
  bool pressed = false; //????????????? Ii folosit undeva?????

  int _currentIndex = 0;

  late final accType;

  ConnectivityResult? connectionStatus, lastConnectionStatus;
  late StreamSubscription subscription;

  late final PageController _pageController;

  void checkConnectivity() {
    if (connectionStatus == ConnectivityResult.none) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: const [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 17,
              ),
              SizedBox(width: 10),
              Text(
                "No internet connection",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 10),
              ),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        duration: const Duration(days: 1),
        backgroundColor: Colors.red,
      ));
    } else if (lastConnectionStatus == ConnectivityResult.none &&
        connectionStatus != ConnectivityResult.none) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Container(
          child: Row(
            children: const [
              Icon(
                Icons.check,
                color: Colors.white,
                size: 17,
              ),
              SizedBox(width: 10),
              Text(
                "Internet connection restored",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 10),
              ),
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
    if (widget.newlyCreated != null && widget.newlyCreated == true) {
      opened = true;
      await Future.delayed(const Duration(milliseconds: 100));
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: ColorsB.gray900,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                          .showSnackBar(SnackBar(
                        content: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: const Text(
                              "Unverified account. Some features might be unavailable to you.",
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: Colors.white),
                            )),
                        duration: const Duration(days: 1),
                        backgroundColor: ColorsB.gray800,
                        behavior: SnackBarBehavior.floating,
                        dismissDirection: DismissDirection.none,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Okay",
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          color: Colors.white),
                    ),
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
                      Text(
                        'Welcome! One more thing before you can start using the app.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.5.sp,
                          color: ColorsB.yellow500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Currently you are unverified, meaning that you won\'t be able to login after you close the app until you verify yourself by clicking on the verification mail, or you get verified by an admin.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
    }
  }

  void loadRes(BuildContext context) {
    precacheImage(const AssetImage('assets/images/Alert.png'), context);
    precacheImage(const AssetImage('assets/images/Calendar.png'), context);
    precacheImage(const AssetImage('assets/images/Carnet.png'), context);
    precacheImage(const AssetImage('assets/images/Map.png'), context);
    precacheImage(const AssetImage('assets/images/Settings.png'), context);
    precacheImage(const AssetImage("assets/images/orar.png"), context);
    precacheImage(const AssetImage("assets/images/IT.png"), context);
    precacheImage(const AssetImage("assets/images/Other.png"), context);
    precacheImage(const AssetImage("assets/images/Design.png"), context);
    precacheImage(const AssetImage("assets/images/Fashion.png"), context);
    precacheImage(const AssetImage("assets/images/abstractFire.png"), context);
    precacheImage(const AssetImage('assets/images/3.png'), context);
    precacheImage(const AssetImage('assets/images/Triangle1.png'), context);
    precacheImage(const AssetImage('assets/images/Untitled-1.png'), context);
    precacheImage(const AssetImage('assets/images/Target.png'), context);
    precacheImage(const AssetImage('assets/images/no_posts.png'), context);
  }

  @override
  void deactivate() {
    super.deactivate();
    //m_debugPrint(1);
  }

  //  Testing smthing
  //  late Future? gFloors = getFloors();

  void addAlert() {
    widget.notifs.value++;
  }

  late final Api api;

  @override
  void initState() {
    //  refreshAlerts();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectionStatus = result;
        _connectionStatus = result;
      });
      //m_debugPrint(result);
      //m_debugPrint(lastConnectionStatus);
      checkConnectivity();
      lastConnectionStatus = connectionStatus;
    });

    FirebaseMessaging.onMessage.listen((message) async {
      m_debugPrint(message.data['type']);
      m_debugPrint((message.data['type'] == 'Report').toString());

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      switch (message.data['type']) {
        case 'Post':
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 10),
                Text(
                  'New posts available!',
                  style: TextStyle(fontFamily: 'Nunito'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorsB.yellow500,
          ));
          break;

        case 'Verify':
          setState(() {
            globalMap['verification'] = 'Verified';
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 10),
                Text(
                  'Account verified!',
                  style: TextStyle(fontFamily: 'Nunito'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));
          break;

        case 'Report':
          m_debugPrint('a');
          addAlert();

          HapticFeedback.mediumImpact();

          //  refreshAlerts();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 10),
                Text(
                  'Uh-oh! Somebody used the alert system!',
                  style: TextStyle(fontFamily: 'Nunito'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ));
          break;

        case 'Reply':
          //  Show a snackbar with a button that says "Show Post" and has a dummy function for now
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 10),
                Text(
                  'You have a new reply!',
                  style: TextStyle(fontFamily: 'Nunito'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Show Reply',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SeePostNotif(
                            uid: globalMap['id'],
                            id: int.parse(message.data['postID']))));
              },
            ),
          ));
          break;

        default:
          m_debugPrint('DEFAULT');
          break;
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      switch (message.data['type']) {
        case "Post":
          reassemble();
          break;

        case 'Report':
          //  await setBall(true);
          addAlert();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NotifPage(
                    notifs: widget.notifs,
                    isAdmin: globalMap['account'] == 'Admin',
                  )));

          break;

        default:
          m_debugPrint('Default');
          break;
      }
    });

    api = Api(context: context);

    // <---------- Load the acc type -------------->
    accType = widget.data['account'];
    globalMap = widget.data;

    //  <-----------  Loaded  ------------------>
    loaded = false;

    // curvedAppBarLabels = globalMap['account'] != 'Student'
    //     ? ['News', 'Activities', 'Trends & Offers', 'Menus']
    //     : ['Threads', 'News', 'Activities', 'Trends & Offers', 'Menus'];

    startingIndex = 0;

    // if (globalMap['account'] == 'Student') {
    //   //  pages.insert(0, const Threads());
    //   curvedAppBarDescriptions.insert(
    //       0, const PageDescription(title: 'Threads', description: 'TBA'));
    // }

    //  @PLACEHOLDER STUDENTS

    //  startingIndex = 1;
    _currentIndex = startingIndex;

    _pageController = PageController(
      initialPage: startingIndex,
    );

    _pageController.addListener(() {
      //  Get currrent page after change
      int next = _pageController.page!.round();

      m_debugPrint(next.toString());

      setState(() {
        currPage = next;
      });
    });

    currSelect = 0;

    _eventCtrl = PageController(initialPage: currSelect);

    super.initState();
    //Initialising the navbar icons -
  }

  //  @threads thingys
  final List<PageDescription> curvedAppBarDescriptions = [
    const PageDescription(
        title: 'News',
        description:
            'Aici vei putea vedea ultimele noutati legate de scoala ta!'),
    const PageDescription(
        title: 'Events & Activities',
        description:
            'Aici vei putea vedea atat evenimente locale cat si evenimente din alte scoli!'),
    const PageDescription(
        title: 'Trends & Offers',
        description:
            'Fii primul care afla despre cele mai noi trenduri si oferte!'),
    const PageDescription(
        title: 'Menus',
        description:
            'Navigheaza prin restul lucrurilor pe care le poti face pe aplicatie!'),
  ];

  final List<String> curvedAppBarLabels = [
    'News',
    'Events & Activities',
    'Trends & Offers',
    'Menus'
  ];

  late final PageController _eventCtrl;

  //  late bool _loaded;

  @override
  void didChangeDependencies() {
    loadRes(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _eventCtrl.dispose();
    globalMap.clear();
    lastConnectionStatus = null;
    connectionStatus = null;
    subscription.cancel();

    _names.clear();
    _emails.clear();
    _types.clear();
    _tokens.clear();
    //  floors.clear();
    super.dispose();
  }

  // Lists for the pending users
  final List<String> _names = [];
  final List<String> _emails = [];
  final List<String> _types = [];
  final List<String> _tokens = [];

  // void updateRedButton() async {
  //   setState(() {});
  // }

  //  late List<Widget> pages;

  var currPage = 0;

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    // if(!opened){
    //   _forNewUsers(context);
    // }

    return Scaffold(
        resizeToAvoidBottomInset: currPage != 1 && currPage != 2,
        //  key: _scaffoldKey,
        appBar: CurvedAppbar(
          notifs: widget.notifs,
          descriptions: curvedAppBarDescriptions,
          names: curvedAppBarLabels,
          nameIndex: _currentIndex,
          accType: globalMap['account'] + ' account',
          position: 1,
          map: globalMap,
          key: bar1Key,
        ),
        backgroundColor: ColorsB.gray900,
        extendBody: true,
        bottomNavigationBar: _bottomNavBar(),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            Announcements(
              eventCtrl: _eventCtrl,
              key: _announcementsKey,
            ),
            OpportunitiesList(globalMap: globalMap),
            OffersPage(
              globalMap: globalMap,
            ),
            MenuTabs(
              pages: [
                SettingsPage(
                  type: globalMap['account'],
                  key: const ValueKey(1),
                  context: context,
                ),
                const MapPage(key: ValueKey(2)),
                MyTimetable(
                  globalMap: globalMap,
                ),
                AlertPage(gMap: globalMap),
                SchoolFiles(
                    key: const ValueKey(3),
                    isAdmin: globalMap['account'] == 'Admin' ||
                        globalMap['account'] == 'Teacher' ||
                        globalMap['account'] == 'C. Elevilor'),
                const Calendar(key: ValueKey(4)),
                const FeedbackPage(),
              ],
              map: globalMap,
              update: () {
                setState(() {});
              },
              key2: bar2Key,
            )
          ],
        ));
  }

  late int startingIndex;

  void moveToPage(int index) async {
    setState(() {
      _currentIndex = index;
      //  changeColors(_currentIndex);
    });

    await Future.delayed(const Duration(milliseconds: 150));

    _pageController.jumpToPage(
      _currentIndex,
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.ease
    );
  }

  void adminVerUsers() {
    late var _getUsers = api.loadUsers();
    // Verification page for the admin
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final ScrollController _scrollController = ScrollController();

          return StatefulBuilder(builder: (_, StateSetter setState1) {
            return AlertDialog(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Verify Users',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 0.5,
                      height: 20,
                    ),
                  ]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: ColorsB.gray900,
              content: SizedBox(
                  height: screenHeight * 0.75,
                  width: screenWidth * 0.8,
                  child: FutureBuilder<List<User>>(
                      future: _getUsers,
                      builder: (c, sn) {
                        if (sn.hasData) {
                          return Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  sn.data!.isNotEmpty ? sn.data!.length : 1,
                              itemBuilder: (context, index) {
                                if (sn.data!.isNotEmpty) {
                                  return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sn.data![index].name,
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Type: ${sn.data![index].type}',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: ColorsB.yellow500),
                                                ),
                                                Text(
                                                  'Email: ${sn.data![index].email}',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: ColorsB.yellow500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                GestureDetector(
                                                  child: const Icon(
                                                    Icons.check_circle_outlined,
                                                    color: Colors.green,
                                                    size: 30,
                                                  ),
                                                  onTap: () async {
                                                    m_debugPrint('Checked');
                                                    await api.verifyUser(
                                                        sn.data![index],
                                                        sn.data!,
                                                        index);
                                                    setState1(() {});
                                                  },
                                                ),
                                                GestureDetector(
                                                  child: const Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.red,
                                                    size: 30,
                                                  ),
                                                  onTap: () {
                                                    setState1(() {
                                                      sn.data!.removeAt(index);
                                                    });

                                                    // TODO: Cancel feature + Check feature
                                                  },
                                                ),
                                              ])
                                        ],
                                      ));
                                } else {
                                  return const Center(
                                    child: Text(
                                      'No accounts pending approval. Nice!',
                                      style: TextStyle(
                                          fontSize: 20, color: ColorsB.gray700),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        } else if (sn.hasData &&
                            (_names.isEmpty ||
                                _emails.isEmpty ||
                                _types.isEmpty)) {
                          return const Center(
                            child: Text(
                              'No accounts pending approval. Nice!',
                              style: TextStyle(
                                  fontSize: 20, color: ColorsB.gray700),
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(ColorsB.yellow500),
                          ));
                        }
                      })),
              actions: [
                TextButton(
                  onPressed: () {
                    _names.clear();
                    _emails.clear();
                    _types.clear();
                    _tokens.clear();

                    Navigator.pop(context);
                  },
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
        });
  }

  Widget _bottomNavBar() {
    List<IconData> icons = [
      Icons.announcement,
      Icons.apartment_rounded,
      Icons.local_activity_rounded,
      Icons.apps_rounded,
    ];

    List<String> titles = [
      'Announcements',
      'Events',
      'Trends & Offers',
      'Menu',
    ];

    List<Widget> buttons = icons
        .map((icon) => NavbarButton(
              onTap: () => moveToPage(icons.indexOf(icon)),
              icon: icon,
              currentIndex: _currentIndex,
              index: icons.indexOf(icon),
              text: titles[icons.indexOf(icon)],
            ))
        .toList();

    if (globalMap['account'] == 'Admin') {
      buttons.insert(
          0,
          NavbarButton(
            onTap: adminVerUsers,
            icon: Icons.admin_panel_settings_rounded,
            currentIndex: _currentIndex,
            index: 999,
            text: 'Verify Users',
          ));
    }

    double navHeight = screenHeight * .075 >= 60 ? 60 : screenHeight * .075;

    if (Platform.isIOS) {
      navHeight += 20;
    }

    return Container(
      width: screenWidth,
      height: navHeight,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: ColorsB.gray800,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 10,
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ]),
      child: Padding(
          padding: Platform.isIOS
              ? const EdgeInsets.only(bottom: 20)
              : EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buttons,
          )),
    );
  }
}

// Global key
GlobalKey<_AnnouncementsState> _announcementsKey =
    GlobalKey<_AnnouncementsState>();

class Announcements extends StatefulWidget {
  //  int currSelect;
  PageController eventCtrl;
  Announcements({Key? key, required this.eventCtrl}) : super(key: key);

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

// Test

//var currentChannel = "";

int maximumCount = 0;

class _AnnouncementsState extends State<Announcements>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

  late ScrollController _scrollController;
  int maxScrollCount = 5;

  late var currentChannel = "";

  List<Widget> posts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //  <-------------- Lists ------------->
    posts = [];

    //  widget.currSelect = 0;

    maximumCount = 0;
    isError = false;

    int _getCurrentIndex() {
      switch (globalMap['account']) {
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

    _tabController = TabController(
        length: Misc.categories.length,
        vsync: this,
        initialIndex: _getCurrentIndex(),
        animationDuration: const Duration(milliseconds: 500));

    _tabController.addListener(() async {
      if (!_tabController.indexIsChanging) {
        setState(() {
          currentChannel =
              Misc.categories.entries.elementAt(_tabController.index).key;
        });
      }
      //  await Future.delayed(Duration(milliseconds:150));
    });

    _currentAnnouncement = 1;
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    if (posts.isEmpty) {
      isLoading = true;
    } else {
      isLoading = false;
    }

    // _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels >
    //       _scrollController.position.maxScrollExtent * 0.95) {
    //     _getMoreData();
    //   }
    // });

    //m_debugPrint(globalMap['account']);
    //  widget.eventCtrl = PageController(initialPage: widget.currSelect);
  }

  late Future _loadEvents;

  @override
  void dispose() {
    _tabController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();

    posts.clear();

    isAlive = false;
    super.dispose();
  }

  // void _getMoreData() {
  //   //  TODO: Maybe make it async
  //   maxScrollCount += 5;
  //   setState(() {});
  // }

  void _showWritable() {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, a1, a2) => SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
                  child: const PostItPage(),
                )));
  }

  // ---------- Placeholder title ------------
  String title = '';
  String description = '';

  var device = window.physicalSize;

  late var currentWidth;

  bool isAlive = true;

  // Max max max posts

  final style = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    //  currentWidth = _textSize(labels[_currentAnnouncement], style).width;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PostsSwitcher(
                index: currSelect,
                ctrl: widget.eventCtrl,
                labels: const ['Announcements', 'Courses'],
                icons: const [Icons.announcement, Icons.book_rounded],
                update: (val) {
                  setState(() => currSelect = val);
                }),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: PageView(
                controller: widget.eventCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(children: [
                    Row(
                      children: [
                        const Text(
                          'Latest news',
                          style: TextStyle(
                              color: ColorsB.yellow500,
                              fontSize: 25,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Visibility(
                          visible: globalMap['account'] == 'Teacher' ||
                              globalMap['account'] == 'Admin' ||
                              globalMap['account'] ==
                                  'C. Elevilor', // cHANGE IT,
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
                    const SizedBox(
                      height: 25,
                    ),
                    teachersBar(),
                    SizedBox(
                        height: screenHeight * .5,
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          // controller: _announcementsController,
                          // physics: const NeverScrollableScrollPhysics(),
                          children: Misc.categories.entries
                              .map((e) =>
                                  PostsList(color: e.value, channel: e.key))
                              .toList(),
                        )),
                    const SizedBox(height: 200)
                  ]),
                  CoursesPage(globalMap: globalMap),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  late TabController _tabController;

  // Future eventsReload() async {
  //   events.clear();

  //   lastEventsMax = -1;
  //   maxScrollCountEvents = 10;
  //   lastIDEvents = Misc.INT_MAX;

  //   _loadEvents = loadEvents();

  //   setState(() {});
  // }
  final ScrollController _eventsScrollController = ScrollController();

  // void lazyLoadCallback() {}

  Widget teachersBar() {
    if (globalMap['account'] == 'Teacher' ||
        globalMap['account'] == 'Admin' ||
        globalMap['account'] == 'C. Elevilor') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
            height: device.height * .075 > 75 ? 75 : device.height * .075,
            width: device.width * 0.90,
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(50)),
            child: Theme(
              data: Theme.of(context).copyWith(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent),
              child: TabBar(
                  labelColor: ColorsB.yellow500,
                  unselectedLabelColor: Colors.white,
                  controller: _tabController,
                  indicator: UnderlineTabIndicator(
                      borderSide:
                          const BorderSide(color: ColorsB.yellow500, width: 3),
                      insets: EdgeInsets.fromLTRB(
                          screenWidth * .1, 0, screenWidth * .1, 10)),
                  tabs: Misc.categories.entries
                      .map((e) => material.Tab(
                            child: SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  e.key,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp),
                                ),
                              ),
                            ),
                          ))
                      .toList()),
            )),
      );
    } else {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
  }

  //  <------------------- Hardcoded loader ------------------>

  void update() {
    setState(() {});
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  @override
  void initState() {
    events = [];

    lazyController.addListener(lazyLoadCallback);
    _loadEvents = loadEvents();

    super.initState();
  }

  int lastMaxEvents = -1; //  INT MAX
  int maxScrollCountEvents = 10;
  int turnsEvents = 10;
  int lastIDEvents = Misc.INT_MAX;

  ScrollController lazyController = ScrollController();
  late Future _loadEvents;

  late List<Widget> events;

  void _showWritableEvent() {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, a1, a2) => SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
                  child: PostEvent(gMap: globalMap),
                )));
  }

  void update1({int? lastMax, int? newMax, int? newID, Future? func}) async {
    maxScrollCountEvents = newMax!;
    lastMaxEvents = lastMax!;
    lastIDEvents = newID!;

    //  _loadEvents = func!;

    setState(() {});
  }

  Future<void> refresh() async {
    events.clear();

    setState(() {
      maxScrollCountEvents = turnsEvents;
      lastMaxEvents = -1;

      lastIDEvents = Misc.INT_MAX;

      _loadEvents = loadEvents();
      setState(() {});
      //  widget.future = widget.futureFunction;
    });
  }

  void lazyLoadCallback() async {
    if (lazyController.position.extentAfter == 0 &&
        lastMaxEvents < maxScrollCountEvents) {
      m_debugPrint('Haveth reached the end');

      await loadEvents();

      setState(() {});
    }
  }

  Future<void> deleteEvent(int Id, int index) async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/deleteEvent.php');
      final response = await http.post(url, body: {"id": Id.toString()});

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //  //m_debugPrint(jsondata.toString());

        if (jsondata['error']) {
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Hooray! The post was deleted.',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ));

          events.removeAt(index);
        }
      } else {
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
      }
    } catch (e) {
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
    }
  }

  Future<int> loadEvents() async {
    //  events.clear();

    //  Maybe rework this a bit.
    m_debugPrint('events');
    lastMaxEvents = maxScrollCountEvents;

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/getEvents.php');
      final response = await http.post(url, body: {
        'lastID': '$lastIDEvents',
        'turns': '$turnsEvents',
      });
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //m_debugPrint(jsondata.toString());
        if (jsondata[0]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata[0]["success"]) {
            for (int i = 1; i < jsondata.length; i++) {
              String post = jsondata[i]["post"].toString();
              String title = jsondata[i]["title"].toString();
              String owner = jsondata[i]["owner"].toString();
              int? ownerid = jsondata[i]["oid"];
              String location = jsondata[i]["location"].toString();
              DateTime date = DateTime.parse(jsondata[i]["timeDate"]);
              String link = jsondata[i]["link"].toString();
              String mapsLink = jsondata[i]["glink"].toString();

              int? id = jsondata[i]["id"];

              if (post != "null" && post != null && ownerid != null) {
                events.add(Event(
                    title: title,
                    id: id,
                    body: post,
                    owner: owner,
                    ownerID: ownerid,
                    link: link,
                    date: date,
                    location: location,
                    gMap: globalMap,
                    maps_link: mapsLink,
                    Context: context,
                    delete: () async {
                      await deleteEvent(id!, i - 1);
                      setState(() {});
                    }));
              }
            }
            lastIDEvents = jsondata[jsondata.length - 1]['id'];
            maxScrollCountEvents += turnsEvents;
            //  m_debugPrint(events);
          } else {
            ////m_debugPrint(jsondata["1"]["message"]);
          }
          //  events.add(SizedBox(height: screenHeight * .25));
        }
      }
    } catch (e, stack) {
      m_debugPrint(e.toString());
      m_debugPrint(stack.toString());
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      Row(
        children: [
          const Text(
            'Events',
            style: TextStyle(
                color: ColorsB.yellow500,
                fontSize: 25,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            width: 10,
          ),
          Visibility(
            visible: globalMap['account'] == 'Teacher' ||
                globalMap['account'] == 'Admin',
            child: GestureDetector(
              onTap: _showWritableEvent,
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
      const SizedBox(
        height: 25,
      ),
      SizedBox(
          height: screenHeight * .6,
          child: LazyBuilder(
              future: _loadEvents,
              refresh: refresh,
              scrollController: lazyController,
              //  futureFunction: loadEvents(),
              widgetList: events,
              lastMax: lastMaxEvents,
              maxScrollCount: maxScrollCountEvents,
              lastID: lastIDEvents,
              turns: turnsEvents))
    ]);
  }
}

class PostsList extends StatefulWidget {
  final Color color;
  final String channel;
  const PostsList({Key? key, required this.color, required this.channel})
      : super(key: key);

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  List posts = [];

  Future<int> load(String channel) async {
    //  Maybe rework this a bit.

    lastMax = maxScrollCount;

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/selectposts.php');
      final response = await http.post(url, body: {
        "lastID": lastID.toString(),
        "userID": globalMap['id'].toString(),
        "maxTurns": turns.toString(),
        "channel": widget.channel,
      });
      m_debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata.toString());
        //m_debugPrint(jsondata.toString());
        if (jsondata[0]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata[0]["success"]) {
            for (int i = 1; i < jsondata.length; i++) {
              String post = jsondata[i]["post"].toString();
              String title = jsondata[i]["title"].toString();
              String? owner = jsondata[i]["owner"];
              int? ownerID = jsondata[i]["oid"];
              String link = jsondata[i]["link"].toString();

              int? likesCount = jsondata[i]["likes"];
              //  String? likedPpl = jsondata[i]["lppl"].toString();
              //  String? dislikedPpl = jsondata[i]["dppl"].toString();
              int? id = jsondata[i]["id"];

              // List<String> liked = likedPpl.split(';');
              // List<String> disliked = dislikedPpl.split(';');

              bool likedbool = jsondata[i]['userLikes'] >= 1;
              bool dislikedbool = jsondata[i]['userDislikes'] >= 1;
              Color? color;

              if (post != "null" && post != null && ownerID != null) {
                // if (liked.contains(globalMap['id'].toString())) {
                //   likedbool = true;
                //   //m_debugPrint('a');
                // } else {
                //   likedbool = false;
                // }

                // if (disliked.contains(globalMap['id'].toString())) {
                //   dislikedbool = true;
                // } else {
                //   dislikedbool = false;
                // }

                m_debugPrint('da');
                posts.add(Post(
                  id: id!,
                  title: title,
                  color: widget.color,
                  likes: likesCount,
                  likesBool: likedbool,
                  dislikes: dislikedbool,
                  ids: id,
                  descriptions: post,
                  owners: owner ?? 'Unknown',
                  ownerID: ownerID,
                  link: link,
                  hero: _hero,
                  admin: globalMap['account'],
                  delete: () async {
                    await deletePost(id, i - 1);
                    setState(() {});
                  },
                  globalMap: globalMap,
                  context: context,
                ));

                ++maximumCount;
              }
            }
            lastID = jsondata[jsondata.length - 1]['id'];
            maxScrollCount += 10;
            m_debugPrint(posts.length.toString());
          } else {
            ////m_debugPrint(jsondata["1"]["message"]);
          }
        }
      }
    } catch (e, stack) {
      m_debugPrint(e.toString());
      m_debugPrint(stack.toString());
      throw Future.error(e.toString());
    }

    return 0;
  }

  Future<void> deletePost(int Id, int index) async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/deletepost.php');
      final response = await http.post(url, body: {"id": Id.toString()});

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);

        if (jsondata['error']) {
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Hooray! The post was deleted.',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ));

          posts.removeAt(index);
        }
      } else {
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
      }
    } catch (e) {
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
    }
  }

  void _hero(
      BuildContext context,
      String title,
      int id,
      String description,
      String author,
      int oid,
      Color color,
      String link,
      int? likes,
      int? ids,
      bool? dislikes,
      bool? likesBool,
      StreamController<int?> contrL,
      StreamController<bool> contrLB,
      StreamController<bool> contrDB) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secAnim) => SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 1), end: Offset.zero)
                  .animate(
                      CurvedAnimation(parent: animation, curve: Curves.ease)),
              child: BigNewsContainer(
                  id: id,
                  title: title,
                  description: description,
                  color: color,
                  author: id < 0 ? 'Anonymous' : author,
                  ownerID: oid,
                  imageLink: link,
                  likes: likes,
                  ids: ids,
                  dislikes: dislikes,
                  likesBool: likesBool,
                  contrL: contrL,
                  contrLB: contrLB,
                  contrDB: contrDB),
            )));
  }

  Future _refresh() async {
    ////m_debugPrint(posts.length);

    posts.clear();

    maximumCount = 0;

    setState(() {
      maxScrollCount = 10; //  Reset to the original scroll count
      lastID = Misc.INT_MAX;
      lastMax = -1;
      _postsLoader = load(widget.channel);
    });
  }

  late ScrollController _scrollController;
  int lastMax = -1; //  INT MAX
  int maxScrollCount = 10;
  int turns = 10;
  int lastID = Misc.INT_MAX;

  Future _getMoreData() async {
    //  TODO: Maybe make it async
    //  maxScrollCount += 10;
    await load(widget.channel);
    setState(() {});
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      //  m_debugPrint(_scrollController.position.extentAfter);
      //m_debugPrint(lastMax);
      //  m_debugPrint(lastID);
      if (_scrollController.position.extentAfter == 0 &&
          lastMax < maxScrollCount) {
        _getMoreData();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    posts.clear();
    _scrollController.dispose();
    super.dispose();
  }

  late Future _postsLoader = load(widget.channel);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _postsLoader,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: maxScrollCount,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(10.0),
                child: Shimmer.fromColors(
                  baseColor: ColorsB.gray800,
                  highlightColor: ColorsB.gray700,
                  child: Container(
                    // Student containers. Maybe get rid of the hero
                    width: screenWidth * 0.75,
                    height: 200,
                    decoration: BoxDecoration(
                      color: ColorsB.gray800,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
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
                          color: Colors.white),
                    ),
                    Text(
                      "Please retry.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        label: const Text(
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
                            borderRadius: BorderRadius.circular(50),
                          ),
                        )),
                  ],
                )),
                const SizedBox(height: 200),
              ],
            );
          } else {
            if (posts.isNotEmpty) {
              return RefreshIndicator(
                backgroundColor: ColorsB.gray900,
                color: widget.color,
                onRefresh: () async {
                  _refresh();
                },
                child: Scrollbar(
                  child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      shrinkWrap: false,
                      itemCount: posts.length < maxScrollCount
                          ? posts.length
                          : maxScrollCount + 1,
                      itemBuilder: (_, index) {
                        // title = titles[index];
                        // description = descriptions[index];
                        // var owner = owners[index];

                        if (index != maxScrollCount) {
                          return Center(child: posts[index]);
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Shimmer.fromColors(
                                baseColor: ColorsB.gray800,
                                highlightColor: ColorsB.gray700,
                                child: Container(
                                  // Student containers. Maybe get rid of the hero
                                  width: screenWidth * 0.75,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: ColorsB.gray800,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                ),
              );
            } else {
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                      child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.25,
                        child: Image.asset('assets/images/no_posts.png'),
                      ),
                      const Text(
                        'Wow! Such empty. So class.',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        "It seems the only thing here is a lonely Doge. Pet it or begone!",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton.icon(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                          label: const Text(
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
                              borderRadius: BorderRadius.circular(50),
                            ),
                          )),
                    ],
                  )),
                  const SizedBox(height: 200),
                ],
              );
            }
          }
        });
  }
}

// <----------------- Making the 'News' container big ------------------>
//ignore: must_be_immutable
class BigNewsContainer extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final Color color;
  final String author;
  final int ownerID;
  final String? imageLink;
  final File? file;
  bool? shouldShowComments;
  int? likes, ids;
  bool? likesBool, dislikes;
  StreamController<int?>? contrL;
  StreamController<bool?>? contrLB;
  StreamController<bool?>? contrDB;

  BigNewsContainer(
      {Key? key,
      required this.title,
      required this.description,
      required this.color,
      required this.author,
      required this.ownerID,
      this.shouldShowComments,
      this.imageLink,
      this.file,
      this.likes,
      this.likesBool,
      this.dislikes,
      this.ids,
      this.contrL,
      this.contrDB,
      this.contrLB,
      required this.id})
      : super(key: key);

  @override
  State<BigNewsContainer> createState() => _BigNewsContainerState();
}

class _BigNewsContainerState extends State<BigNewsContainer> {
  // <------------------- Like, Unlike, Dislike, Undislike functions ------------------>
  Future<void> like(int id, int uid) async {
    ////m_debugPrint(ids);

    if (widget.dislikes == true) {
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

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          ////m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          ////m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      //m_debugPrint(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> unlike(int id, int uid) async {
    ////m_debugPrint(ids);

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;

      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.likesBool);

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          ////m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          ////m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      //m_debugPrint(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> dislike(int id, int uid) async {
    ////m_debugPrint(ids);

    if (widget.likesBool == true) {
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

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'DISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          ////m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          ////m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      //m_debugPrint(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> undislike(int id, int uid) async {
    ////m_debugPrint(ids);

    setState(() {
      widget.likes = widget.likes! + 1;

      widget.dislikes = false;

      widget.contrL!.add(widget.likes);
      widget.contrDB!.add(widget.dislikes);

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNDISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          ////m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          ////m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      //m_debugPrint(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  bool get _isCollapsed {
    return _controller.position.pixels >= screenHeight * .65 &&
        _controller.hasClients;
  }

  Future<bool> _is404() async {
    var response = await http.get(Uri.parse(avatarImg));

    return response.statusCode != 200;
  }

  final ScrollController _controller = ScrollController();

  bool visible = false;
  var avatarImg;

  final ScrollController _commentScrollController = ScrollController();
  int _commentMaxIndex = 20;
  //  StreamController _commentsStream = StreamController.broadcast();

  final Future? _loadedComments = null;
  List<Comment> comments = [];
  //  bool isLoading = false;
  final StreamController _commentsStream = StreamController.broadcast();
  //  GlobalKey _builderKey = GlobalKey();
  int lastLoaded = Misc.INT_MAX;
  int lastMax = -1;
  final int _turnsToLoad = 20;

  int gotFirstComment = 0;

  Future<int> getComments() async {
    lastMax = _commentMaxIndex;

    try {
      //  setState(() => isLoading = true);

      var url = Uri.parse('${Misc.link}/${Misc.appName}/loadComments.php');
      final response = await http.post(url, body: {
        "post_id": widget.id.toString(),
        "lastID": lastLoaded.toString(),
        "gotFirstComment": gotFirstComment.toString(),
        'userID': globalMap['id'].toString(),
        "maxLoaded": _turnsToLoad.toString()
      });

      m_debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        Map jsondata = json.decode(response.body);
        //m_debugPrint(jsondata.length.toString());
        m_debugPrint(widget.id.toString());
        //m_debugPrint(jsondata.toString());

        if (jsondata['success']) {
          for (int i = 2; i < jsondata.length; i++) {
            //  //m_debugPrint(jsondata['${i - 1}']);
            ////m_debugPrint(jsondata['${i - 1}']['lby'].split(';'));
            //  m_debugPrint(DateTime.parse(jsondata['${i - 1}']['time']));
            comments.add(
                Comment.fromJson(jsondata['${i - 1}'], globalMap, () async {
              await Comment.deleteComment(context, jsondata['${i - 1}']['id'],
                      comments.length - 1, comments)
                  .then((value) => _commentsStream.add(1));
            }));
          }

          lastLoaded = jsondata['${jsondata.length - 2}']['id'];

          _commentMaxIndex += 5;

          setState(() {
            gotFirstComment = 1;
          });
        }
      }
    } catch (e, stack) {
      m_debugPrint(e.toString());
      m_debugPrint(stack.toString());
    }

    //  _builderKey.currentState?.setState(() {}.toString());

    //  _commentsStream.add(1);
    return 1;
  }

  @override
  void initState() {
    avatarImg = '${Misc.link}/${Misc.appName}/profiles/${widget.ownerID}.jpg';

    _controller.addListener(() {
      _isCollapsed ? visible = true : visible = false;

      //  m_debugPrint(_controller.position.pixels);

      setState(() {});
    });

    _commentScrollController.addListener(() async {
      //  m_debugPrint(_commentScrollController.position.extentAfter);
      if (_commentScrollController.position.extentAfter == 0 &&
          _commentMaxIndex != lastMax) {
        try {
          m_debugPrint('More data...');
          //  _commentsStream.add(1);
          await getComments().then((value) => _commentsStream.add(1));

          m_debugPrint(lastMax.toString());
          m_debugPrint(_commentMaxIndex.toString());
        } catch (e) {
          m_debugPrint(e.toString());
        }
      }
    });

    super.initState();

    // Await widget to be build then if shouldShowComments is not null, scroll to comments
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.shouldShowComments != null) {
        await Future.delayed(const Duration(milliseconds: 500));

        showComments();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _likeBar() {
    if (globalMap['verification'] != 'Pending' && widget.likes != null) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
                  child: Container(
                    height: 200,
                    width: 50,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                height: 200,
                width: 50,
                decoration: BoxDecoration(
                    color: ColorsB.gray800.withOpacity(.5),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          blurStyle: BlurStyle.outer,
                          offset: Offset(4, 4))
                    ]),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            Icons.thumb_up,
                            color: widget.likesBool == true
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 25,
                          ),
                          onPressed: () {
                            widget.likesBool == true
                                ? unlike(widget.ids!, globalMap['id'])
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
                            color: widget.dislikes == true
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 25,
                          ),
                          onPressed: () {
                            widget.dislikes == true
                                ? undislike(widget.ids!, globalMap['id'])
                                : dislike(widget.ids!, globalMap['id']);
                            //
                          },
                        ),
                      ]),
                      IconButton(
                        splashRadius: 20,
                        icon: Icon(
                          Icons.comment,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () async {
                          //  _loadedComments ??= await getComments();

                          showComments();
                        },
                      ),
                    ]),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  void showComments() async {
    if (comments.isEmpty) {
      await getComments().then((value) => _commentsStream.add(1));
    }

    final FocusNode _commentFocus = FocusNode();
    FocusScope.of(context).unfocus();

    m_debugPrint("Context: ${FocusScope.of(context).hasFocus}");
    m_debugPrint("Comment: ${_commentFocus.hasFocus}");

    int touches = 0;

    showModalBottomSheet(
        backgroundColor: ColorsB.gray800,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        barrierColor: Colors.black26,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          //  GlobalKey _commentKey = GlobalKey<FormState>();

          return SizedBox(
            height: MediaQuery.of(context).copyWith().size.height * .75,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();

                if (touches == 0) {
                  ++touches;
                }
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    15, 10, 15, MediaQuery.of(context).viewInsets.bottom + 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(children: [
                        Container(
                            height: 5,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(360))),
                        const SizedBox(height: 10),
                        Text('Comments',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white))
                      ]),
                      const SizedBox(height: 10),
                      Expanded(
                          child: Scrollbar(
                              child: StreamBuilder(
                                  stream: _commentsStream.stream,
                                  builder: (context, snapshot) {
                                    return ListView.builder(
                                        controller: _commentScrollController,
                                        itemCount: comments.isEmpty
                                            ? 1
                                            : comments.length < _commentMaxIndex
                                                ? comments.length
                                                : _commentMaxIndex,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          if (comments.isEmpty) {
                                            return const Text(
                                                'No comments to show.',
                                                style: TextStyle(
                                                    color: Colors.white24));
                                          } else if (index !=
                                              _commentMaxIndex) {
                                            return comments[index];
                                          } else {
                                            return const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        ColorsB.yellow500));
                                          }
                                        });
                                  }))),
                      const SizedBox(height: 10),
                      Visibility(
                        visible: // Make visible only when the focus isn't on the reply bar
                            !_commentFocus.hasFocus &&
                                    FocusScope.of(context).hasFocus &&
                                    touches != 0
                                ? false
                                : true,
                        child: CommentBar(
                          postID: widget.id,
                          commentNode: _commentFocus,
                          gMap: globalMap,
                          commentStream: _commentsStream,
                          comments: comments,
                        ),
                      )
                      // Row(
                      //   children: [
                      //     Form(
                      //       key: _commentKey,
                      //       child: TextFormField(),
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    return Scaffold(
        extendBody: false,
        bottomNavigationBar: const BackNavbar(),
        backgroundColor: ColorsB.gray900,
        body: Stack(
          children: [
            Scrollbar(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: ClampingScrollPhysics()),
                controller: _controller,
                slivers: [
                  SliverAppBar(
                    backgroundColor: widget.color,
                    automaticallyImplyLeading: false,
                    expandedHeight: screenHeight * .75,
                    pinned: true,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: [
                        StretchMode.blurBackground,
                      ],
                      background: topPage(),
                    ),
                    title: AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Row(
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                widget.title.length > 20
                                    ? widget.title.substring(0, 20) + '...'
                                    : widget.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            Chip(
                              backgroundColor: ColorsB.gray200,
                              avatar: ProfilePicture(
                                url: avatarImg,
                                userName: widget.author,
                              ),
                              label: Text(
                                  '${widget.author.split(' ').first} ${widget.author.split(' ').last[0]}.'),
                            )
                          ],
                        )),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextPP(
                            string: widget.description,
                          )),
                    ),
                  )
                ],
              ),
            ),
            _likeBar()
          ],
        ));
  }

  Widget topPage() {
    //m_debugPrint(imageLink);

    BoxDecoration woImage = BoxDecoration(color: widget.color);

    BoxDecoration wImage = BoxDecoration(
      image: DecorationImage(
          image: CachedNetworkImageProvider(widget.imageLink!),
          fit: BoxFit.cover),
    );

    return GestureDetector(
      onTap: (widget.imageLink == 'null' || widget.imageLink == '')
          ? null
          : () {
              showDialog(
                  context: context,
                  builder: (context) => Material(
                      color: Colors.transparent,
                      child: Stack(children: [
                        Center(
                          child: InteractiveViewer(
                            clipBehavior: Clip.none,
                            child:
                                CachedNetworkImage(imageUrl: widget.imageLink!),
                          ),
                        ),
                        Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                                tooltip: 'Close',
                                splashRadius: 25,
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }))
                      ])));
            },
      child: Container(
        //  color: widget.color,
        decoration: (widget.imageLink == 'null' || widget.imageLink == '')
            ? woImage
            : wImage,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                  height: screenHeight * .3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints:
                            BoxConstraints(maxHeight: screenHeight * .2),
                        decoration: BoxDecoration(
                            color: ColorsB.gray900,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(4, 4),
                                  blurRadius: 10)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.title.length > 30
                                  ? widget.title.substring(0, 30) + '...'
                                  : widget.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Chip(
                        shadowColor: Colors.black12,
                        elevation: 40,
                        backgroundColor: ColorsB.gray200,
                        avatar: ProfilePicture(
                          url: avatarImg,
                          userName: widget.author,
                        ),
                        label: Text(
                            '${widget.author.split(' ').first} ${widget.author.split(' ').last[0]}.'),
                      )
                    ],
                  ))),
        ),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int floorNo = 0;

  List<Floor> floors = [];
  bool mapErrored = false;

  Future getFloors() async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/getfloors.php');

      //  TODO: FIX THIS SOMEHOWWWW

      final response =
          await http.post(url, body: {}).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //m_debugPrint(jsondata.toString());
        if (jsondata['0']["error"]) {
        } else {
          for (int i = 1; i <= jsondata.length; i++) {
            //  //m_debugPrint(jsondata['$i']);
            floors.add(Floor(
                floor: jsondata['$i']["floor"],
                file: jsondata['$i']['file'],
                image: jsondata['$i']['image']));
          }
        }
      } else {
        mapErrored = true;
        return throw Exception("Couldn't connect");
      }
    } on TimeoutException catch (e) {
      //m_debugPrint("Error during converting to Base64");
      mapErrored = true;

      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content:
                  Text('Request has timed out. Some features might be missing.',
                      style: TextStyle(
                        color: Colors.white,
                      ))));

      return throw Exception("Timeout");
    } finally {
      return 1;
    }
  }

  late final Future _getFloors = getFloors().then((value) => placeMaps());

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
    //  placeMaps();
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

    for (int i = 0; i < floors.length; i++) {
      maps.add(GestureDetector(
        key: Key('$i'),
        child: Image.network(
          "${Misc.link}/${Misc.appName}/floors/${floors[i].file}",
          key: Key('$i'),
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: screenHeight * 0.5,
              child: Center(
                  child: Shimmer.fromColors(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: ColorsB.gray800,
                        ),
                      ),
                      baseColor: ColorsB.gray800,
                      highlightColor: ColorsB.gray700)),
            );
          },
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
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
                      color: Colors.white),
                ),
                Text(
                  "Please forgive us.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            );
          },
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => Material(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Center(
                      child: InteractiveViewer(
                          clipBehavior: Clip.none,
                          child: Image.network(
                            "${Misc.link}/${Misc.appName}/floors/${floors[i].file}",
                            key: Key('$i'),
                          )),
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
                            }))
                  ])));
        },
      ));
    }
  }

  // <---------- Animated switcher children aka the maps ---------->
  Widget? _mapChildren() {
    if (floors.isEmpty) {
      return const SizedBox();
    } else {
      try {
        return maps[floorNo];
      } catch (e) {
        return maps[0];
      }
    }
  }

  bool isLoading = false;

  Widget mapBody() {
    if (!isLoading) {
      if (!mapErrored) {
        if (floors.isNotEmpty) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _mapChildren(),
                    transitionBuilder: (child, animation) => SlideTransition(
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero)
                          .animate(animation),
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
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (context, a1, a2) =>
                                          SlideTransition(
                                            position: Tween<Offset>(
                                                    begin: const Offset(0, 1),
                                                    end: Offset.zero)
                                                .animate(CurvedAnimation(
                                                    parent: a1,
                                                    curve: Curves.ease)),
                                            child: EditFloors(
                                              floors: floors,
                                              update: updateThis,
                                            ),
                                          )));
                            },
                            icon: const Icon(Icons.edit,
                                size: 20, color: Colors.white),
                            label: const Text(
                              "Edit floors",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: ColorsB.gray800,
                            ))
                        : const SizedBox(width: 0, height: 0),
                  ]),
              //TODO: Add the images (at least a placeholder one and do the thingy)
            ],
          );
        }

        return Center(
            child: Column(
          children: [
            const Text(
              'No maps to display :(',
              style: TextStyle(color: ColorsB.gray800, fontSize: 30),
            ),
            const SizedBox(height: 20),
            Visibility(
                visible: globalMap['account'] == "Admin" ||
                    globalMap['account'] == "Teacher" ||
                    globalMap['account'] == 'C. Elevilor',
                child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => SlideTransition(
                                    position: Tween<Offset>(
                                            begin: const Offset(0, 1),
                                            end: Offset.zero)
                                        .animate(CurvedAnimation(
                                            parent: a1, curve: Curves.ease)),
                                    child: EditFloors(
                                        floors: floors, update: updateThis),
                                  )));
                    },
                    icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                    label: const Text(
                      "Add floors",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: ColorsB.gray800,
                    )))
          ],
        ));
      }

      return Center(
          child: Column(
        children: [
          const Text(
            'Request has timed out. Please try again.',
            style: TextStyle(color: ColorsB.gray800, fontSize: 30),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label:
                  const Text('Refresh', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                floors.clear();

                setState(() {
                  isLoading = true;
                  mapErrored = false;
                });

                await getFloors();

                setState(() {
                  isLoading = false;
                });
              })
        ],
      ));
    }

    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ColorsB.yellow500)),
          SizedBox(height: 15),
          Text('Getting data...',
              style: TextStyle(color: Colors.white, fontSize: 12.5))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getFloors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(ColorsB.yellow500)));
          } else if (snapshot.hasError) {
            return const Text('Awe! There has been an error!',
                style: TextStyle(color: Colors.white));
          } else {
            return Padding(
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
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          color: ColorsB.gray800,
                          height: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  //Widgetul pt select floor
                  mapBody(),

                  // DropdownSelector(update: _mapUpdate,),
                  // //TODO: Add the images (at least a placeholder one and do the thingy)
                ],
              ),
            );
          }
        });
  }
}

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
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

    for (int i = 1; i <= no; ++i) {
      steps.add(AnimatedPadding(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 250),
        padding: currentPage == i - 1
            ? const EdgeInsets.only(bottom: 10)
            : EdgeInsets.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
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
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ));
    }

    return SizedBox(
        height: screenHeight * .6,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: steps));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (currentPage != 0) {
                    _changePage(0);
                  }
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: currentPage != 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  size: 30,
                ),
              ),
              Text('Back',
                  style: TextStyle(
                      color: currentPage != 0
                          ? Colors.white
                          : Colors.white.withOpacity(0.5))),
              const SizedBox(width: 20),
              Flexible(
                child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 500),
                    //  switchOutCurve: Curves.easeInOut,
                    child: _stepsText(),
                    transitionBuilder: (child, animation, secondaryAnimation) =>
                        SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.vertical,
                          child: child,
                          fillColor: Colors.transparent,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSteps(4),
              const SizedBox(width: 25),
              Expanded(
                child: _calendarBuild(),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> stepsText = [
    const Text('Select your hall.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        )),
    const Text('Select the day of interest.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        )),
    const Text('Select the time interval.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        )),
    const Text('Profit!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        )),
  ];

  Widget _stepsText() {
    return SizedBox(
      key: Key("$currentPage"),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [stepsText[currentPage]]),
    );
  }

  Widget _calendarBuild() {
    if (_connectionStatus == ConnectivityResult.none) {
      return Center(
          child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.3,
            child: SvgPicture.asset('assets/svgs/calendar.svg'),
          ),
          const Text(
            'Aww! Something went wrong!',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "To be able to use our hall booking feature, please connect to the Internet.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ));
    }
    return Column(
      children: [
        SizedBox(
          height: screenHeight * .65,
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
              child: currentPage == 0
                  ? CalPag1(
                      changePage: _changePage,
                    )
                  : CalPag2(
                      changePage: _changePage,
                    )),
        ),
      ],
    );
  }

  //  TODO: Implement the page changing logic

  //  <------------  Building the widgets for the animated switcher  ------------>
  int currentPage = 1;

  void _changePage(int page) {
    setState(() {
      if (page > currentPage) {
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

  late Future loadHalls = _loadHalls();

  @override
  void initState() {
    changePage = widget.changePage;
    ok = false;
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
            FutureBuilder(
                future: loadHalls,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
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
                                  )),
                            ));
                  } else {
                    return ListView.builder(
                      clipBehavior:
                          Clip.hardEdge, //  Find a way to do it better
                      physics: const BouncingScrollPhysics(),
                      itemCount: halls.isNotEmpty ? halls.length : 1,
                      itemBuilder: (context, index) {
                        if (halls.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: halls[index],
                          );
                        } else {
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'No halls found',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Image.asset(
                                  'assets/images/no_posts.png',
                                  height: 200,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }
                }),
            Visibility(
              visible: globalMap['account'] == 'Admin' ? true : false,
              child: Positioned(
                bottom: screenHeight * .1,
                right: screenWidth * .025,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      // Title controller
                      final TextEditingController titleController =
                          TextEditingController();

                      //  Form key
                      var formKey = GlobalKey<FormState>();
                      var size, errorText;
                      bool clicked = false;

                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (_) =>
                              StatefulBuilder(builder: (_, setState) {
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
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          child: Column(
                                            children: [
                                              // Title form text field and a dropdown with 3 options: Small, Medium, Large
                                              TextFormField(
                                                cursorColor: ColorsB.yellow500,
                                                controller: titleController,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Title',
                                                  labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
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
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
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
                                                    child: Text(
                                                      'Medium',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    value: 'Medium',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Large',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                      ),
                                                    ),
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
                                                        if (formKey
                                                            .currentState!
                                                            .validate()) {
                                                          if (size == null) {
                                                            setState(() {
                                                              errorText =
                                                                  'Please select a size';
                                                            });
                                                            return;
                                                          }
                                                          setState(() {
                                                            clicked = true;
                                                          });

                                                          try {
                                                            var url = Uri.parse(
                                                                '${Misc.link}/${Misc.appName}/halls.php');
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: {
                                                                  "action":
                                                                      'INSERT', // Or IMPORT
                                                                  "title":
                                                                      titleController
                                                                          .text,
                                                                  "size": size,
                                                                });
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              var jsondata =
                                                                  json.decode(
                                                                      response
                                                                          .body);
                                                              if (jsondata["1"]
                                                                  ["error"]) {
                                                                setState(() {
                                                                  errorText =
                                                                      jsondata[
                                                                              "1"]
                                                                          [
                                                                          "message"];
                                                                });
                                                              } else if (jsondata[
                                                                      '1']
                                                                  ['success']) {
                                                                setState(() {
                                                                  clicked =
                                                                      false;
                                                                  // Pop the screen
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
                                                              }
                                                            }
                                                          } catch (e) {
                                                            ////m_debugPrint(e);
                                                            setState(() {
                                                              errorText =
                                                                  'Error connecting to server';
                                                              clicked = false;
                                                            });
                                                          }
                                                        }
                                                      },
                                                    )
                                                  : const CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                              }));
                    },
                    child: const Icon(Icons.add),
                    backgroundColor: ColorsB.yellow500,
                    mini: true,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> deleteEvent(int Id, int index) async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/deleteHall.php');
      final response = await http.post(url, body: {"id": Id.toString()});

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //  //m_debugPrint(jsondata.toString());

        if (jsondata['error']) {
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Hooray! The post was deleted.',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ));

          halls.removeAt(index);
        }
      } else {
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
      }
    } catch (e) {
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
    }
  }

  Future<int> _loadHalls() async {
    //await Future.delayed(const Duration(seconds: 1));
    //titles.isNotEmpty && sizes.isNotEmpty ? hasLoaded = true : hasLoaded = false;

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/halls.php');
      final response = await http.post(url, body: {
        "action": 'IMPORT', // Or INSERT
      });
      //m_debugPrint('Gojdu: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        ////m_debugPrint(jsondata.toString());
        if (jsondata['1']['success']) {
          for (int i = 2; i < jsondata.length; i++) {
            var title = jsondata[i.toString()]['title'];
            var size = jsondata[i.toString()]['size'];

            if (title != null && size != null) {
              Hall hall = Hall(
                index: i - 2,
                title: title,
                size: size,
                changePage: changePage,
                Id: jsondata[i.toString()]['id'],
                delete: () async {
                  await deleteEvent(jsondata[i.toString()]['id'], i - 2);
                  setState(() {});
                },
              );

              halls.add(hall);
              //m_debugPrint(halls);

            } else {
              break;
            }
          }
        } else {
          //return 0;
        }
      } else {}
    } catch (e) {
      ////m_debugPrint(e);
      //return 0;
    }

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
  final Function delete;
  final Function(int) changePage;
  const Hall(
      {Key? key,
      required this.index,
      required this.title,
      required this.size,
      required this.changePage,
      required this.Id,
      required this.delete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: ColorsB.gray800,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(children: [
        Material(
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
                          const SizedBox(
                            width: 10,
                          ),
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
                      const SizedBox(
                        height: 10,
                      ),
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
        Visibility(
          visible: globalMap['account'] == 'Admin',
          child: Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
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
                              'Are you sure you want delete this post?',
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
                          height: 75,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await delete();

                                      Navigator.of(context).pop();

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
                                      child: const Icon(
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
            ),
          ),
        ),
      ]),
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
      var url = Uri.parse('${Misc.link}/${Misc.appName}/selectbookings.php');
      final response = await http.post(url, body: {
        "hall": _currentHall.toString(),
        "day": DateFormat('yyyy-MM-dd').format(date).toString(),
      });
      //m_debugPrint(response.statusCode);
      //m_debugPrint("im heree");
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        ////m_debugPrint(jsondata.toString());

        if (jsondata["1"]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata["1"]["success"]) {
            if (_events[_selectedDay] != null &&
                _events[_selectedDay]!.contains(['Error! Please try again!'])) {
              _events[_selectedDay]!.clear();
            }

            for (int i = 2; i < 10; i++) {
              if (jsondata[i.toString()] != null) {
                String begin = jsondata[i.toString()]["begin"].toString();
                String? end = jsondata[i.toString()]["end"].toString();
                String? owner = jsondata[i.toString()]["owner"].toString();
                ////m_debugPrint(begin);
                ////m_debugPrint(end);
                ////m_debugPrint(owner);

                if (begin != 'null' && end != 'null' && owner != 'null') {
                  if (_events[date] != null &&
                      !(_events[date]!.contains(
                          '${begin.substring(0, begin.length - 3)}  -  ${end.substring(0, end.length - 3)}  -  ${owner}'))) {
                    _events[_selectedDay]!.add(
                        '${begin.substring(0, begin.length - 3)}  -  ${end.substring(0, end.length - 3)}  -  ${owner}');
                  } else {
                    _events[_selectedDay] = [
                      '${begin.substring(0, begin.length - 3)}  -  ${end.substring(0, end.length - 3)}  -  ${owner}'
                    ];
                  }
                }
              }
            }

            /* if(post != "null")
              {
                //m_debugPrint(post+ " this is the post");
                //m_debugPrint(title+" this is the title");
                //m_debugPrint(owner+ " this is the owner");
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
    for (int i = 0; i < 7; i++) {
      _getList(date);
      date = date.add(const Duration(days: 1));
    }
  }

  bool overlap(String _selectedBegin, String _selectedEnd) {
    var _selectedBeginTime = DateTime.parse('20120227 $_selectedBegin:00');
    var _selectedEndTime = DateTime.parse('20120227 $_selectedEnd:00');

    for (int i = 0; i < _events[_selectedDay]!.length; i++) {
      String begin = _events[_selectedDay]![i].split("  -  ")[0];
      String end = _events[_selectedDay]![i].split("  -  ")[1];

      var _beginTime = DateTime.parse('20120227 $begin');
      var _endTime = DateTime.parse('20120227 $end');

      if (_selectedBeginTime.isBefore(_beginTime) &&
              _selectedEndTime.isBefore(_beginTime) ||
          _selectedBeginTime.isAfter(_endTime) &&
              _selectedEndTime.isAfter(_endTime)) {
        return true;
      }
    }
    return false;
  }

  // <-----------------  Time Pickers ----------------->
  late String _time1;
  late String _time2;

  // TODO: Get the data from the server and shit.

  String convertTo24(String time) {
    var splitTime = time.split(' ');
    var period = splitTime.last;
    var hour = splitTime.first.split(':').first;
    var minutes = splitTime.first.split(':').last;
    if (period == 'PM') {
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
                          titleTextStyle: const TextStyle(
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
                          selectedDecoration: const BoxDecoration(
                              color: ColorsB.yellow500, shape: BoxShape.circle),
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
                            //m_debugPrint(_selectedDay);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          if (globalMap['verification'] !=
                                              "Pending") {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  var timeText =
                                                      TextEditingController();
                                                  var timeText2 =
                                                      TextEditingController();

                                                  TimeOfDay? parsedTime1;
                                                  TimeOfDay? parsedTime2;

                                                  var _formKey =
                                                      GlobalKey<FormState>();
                                                  var errorText1, errorText2;

                                                  bool clicked = false;

                                                  return StatefulBuilder(
                                                      builder: (_,
                                                              StateSetter
                                                                  setState) =>
                                                          AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                              ),
                                                              backgroundColor:
                                                                  ColorsB
                                                                      .gray900,
                                                              content: SizedBox(
                                                                height: 200,
                                                                child: Center(
                                                                  child: Form(
                                                                    key:
                                                                        _formKey,
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
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
                                                                                  icon: Icon(
                                                                                    Icons.timer,
                                                                                    color: Colors.white.withOpacity(0.5),
                                                                                  ), //icon of text field
                                                                                  labelText: "Enter Time", //label text of field
                                                                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), //style of label text
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                                                                                  ),
                                                                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))), //border of text field
                                                                                ),
                                                                                onTap: () async {
                                                                                  TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                                  //m_debugPrint(pickedTime.toString());
                                                                                  if (pickedTime != null) {
                                                                                    parsedTime1 = pickedTime;
                                                                                    //DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                                                                    String formattedTime = convertTo24(pickedTime.format(context));
                                                                                    //  //m_debugPrint(formattedTime);
                                                                                    setState(() {
                                                                                      timeText.text = formattedTime;
                                                                                      _time1 = formattedTime;
                                                                                      //m_debugPrint(formattedTime);
                                                                                    });
                                                                                  }
                                                                                },
                                                                                validator: (value) {
                                                                                  if (value == null || value.isEmpty) {
                                                                                    return "Please enter time";
                                                                                  } else if (parsedTime1 != null && parsedTime2 != null) {
                                                                                    if (parsedTime1!.hour > parsedTime2!.hour || ((parsedTime1!.hour == parsedTime2!.hour) && (parsedTime1!.minute >= parsedTime2!.minute))) {
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
                                                                                  icon: Icon(
                                                                                    Icons.timer,
                                                                                    color: Colors.white.withOpacity(0.5),
                                                                                  ), //icon of text field
                                                                                  labelText: "Enter Time", //label text of field
                                                                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), //style of label text
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                                                                                  ),
                                                                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))), //border of text field
                                                                                ),
                                                                                onTap: () async {
                                                                                  TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                                  parsedTime2 = pickedTime;
                                                                                  if (pickedTime != null) {
                                                                                    String formattedTime = convertTo24(pickedTime.format(context));
                                                                                    //  //m_debugPrint(formattedTime);
                                                                                    setState(() {
                                                                                      timeText2.text = formattedTime;
                                                                                      _time2 = formattedTime;
                                                                                    });
                                                                                  }
                                                                                },
                                                                                validator: (value) {
                                                                                  if (value == null || value.isEmpty) {
                                                                                    return "Please enter time";
                                                                                  } else if (parsedTime1 != null && parsedTime2 != null) {
                                                                                    if (parsedTime1!.hour > parsedTime2!.hour || ((parsedTime1!.hour == parsedTime2!.hour) && (parsedTime1!.minute >= parsedTime2!.minute))) {
                                                                                      return "Please enter valid time";
                                                                                    }
                                                                                  }
                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TextButton
                                                                            .icon(
                                                                          onPressed:
                                                                              () async {
                                                                            if (_events[_selectedDay] !=
                                                                                null) {
                                                                              if (!overlap(_time1, _time2)) {
                                                                                setState(() {
                                                                                  errorText1 = errorText2 = 'Overlapping!';
                                                                                });
                                                                                return;
                                                                              }
                                                                            }

                                                                            if (_formKey.currentState!.validate()) {
                                                                              try {
                                                                                setState(() {
                                                                                  clicked = true;
                                                                                });
                                                                                var url = Uri.parse('${Misc.link}/${Misc.appName}/insertbookings.php');
                                                                                final response = await http.post(url, body: {
                                                                                  "day": _selectedDay.toString().split(' ').first,
                                                                                  "start": _time1 + ":00",
                                                                                  "end": _time2 + ":00",
                                                                                  "hall": _currentHall.toString(),
                                                                                  "owner": globalMap["first_name"] + " " + globalMap["last_name"],
                                                                                });
                                                                                //m_debugPrint(response.statusCode);
                                                                                //m_debugPrint("does work");
                                                                                if (response.statusCode == 200) {
                                                                                  var jsondata = json.decode(response.body);
                                                                                  ////m_debugPrint(jsondata.toString());
                                                                                  if (jsondata["error"]) {
                                                                                  } else {
                                                                                    if (jsondata["success"]) {
                                                                                      Navigator.pop(context);
                                                                                    } else {
                                                                                      ////m_debugPrint(jsondata["message"]);
                                                                                    }
                                                                                  }
                                                                                }
                                                                                //m_debugPrint(_events);

                                                                                widget.changePage(3);
                                                                                setState(() {});
                                                                              } catch (e) {
                                                                                _events[_selectedDay] = [
                                                                                  'Error! Please try again!'
                                                                                ];
                                                                              }
                                                                            }
                                                                          },
                                                                          icon: !clicked
                                                                              ? const Icon(
                                                                                  Icons.add_circle,
                                                                                  color: Colors.white,
                                                                                )
                                                                              : const SizedBox(),
                                                                          label: !clicked
                                                                              ? const Text(
                                                                                  'Reserve',
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                )
                                                                              : const CircularProgressIndicator(
                                                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                                ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )));
                                                });
                                          } else {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      backgroundColor:
                                                          ColorsB.gray900,
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                            "Okay",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                      content: SizedBox(
                                                        height:
                                                            screenHeight * 0.5,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 200,
                                                              child: SvgPicture
                                                                  .asset(
                                                                'assets/svgs/locked.svg',
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                            const Text(
                                                              'Oops! You can\'t do that!',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                fontSize: 17.5,
                                                                color: ColorsB
                                                                    .yellow500,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 25),
                                                            Text(
                                                              'Currently you are unverified, meaning that you won\'t be able to use all the features withing the app. \n\nIf you are actually verified, please restart the app.',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.5),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                          }
                                        },
                                        style: ButtonStyle(
                                          elevation:
                                              MaterialStateProperty.all(0),
                                          backgroundColor:
                                              globalMap["verification"] !=
                                                      "Pending"
                                                  ? MaterialStateProperty.all<
                                                      Color>(ColorsB.yellow500)
                                                  : MaterialStateProperty.all<
                                                      Color>(ColorsB.gray700),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                        ),
                                        child: globalMap['verification'] !=
                                                "Pending"
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
                                              )),
                                  )
                                ],
                              ),
                              FutureBuilder(
                                  future: _getList(_selectedDay),
                                  builder: (context, snpshot) {
                                    if (snpshot.hasData) {
                                      return SizedBox(
                                          height: 100,
                                          child: _events[_selectedDay] != null
                                              ? ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  itemCount:
                                                      _events[_selectedDay]!
                                                          .length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.5),
                                                      child: Text(
                                                        globalMap['account'] !=
                                                                'Student'
                                                            ? _events[
                                                                    _selectedDay]![
                                                                index]
                                                            : _events[_selectedDay]![
                                                                            index]
                                                                        .split(
                                                                            '-')[
                                                                    0] +
                                                                "-" +
                                                                _events[_selectedDay]![
                                                                        index]
                                                                    .split(
                                                                        '-')[1],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Center(
                                                  child: FadeTransition(
                                                    opacity: Tween<double>(
                                                            begin: 0, end: 1)
                                                        .animate(
                                                            AnimationController(
                                                      vsync: this,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                    )..forward()),
                                                    child: Text(
                                                      'No events for this day. Yay!',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white
                                                            .withOpacity(0.25),
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  ColorsB.yellow500),
                                        ),
                                      );
                                    }
                                  }),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ],
          )),
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
  late GlobalKey<FormState> _formKey;

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

  List<mFilterChip> schools = [];
  List<mFilterChip> selectedSchools = [];

  Future<int> getSchools() async {
    var link = "${Misc.link}/listaScoli.json";

    http.get(Uri.parse(link)).then((response) {
      var data = json.decode(response.body);
      m_debugPrint(data);
      List<mFilterChip> temp = [];
      for (var i = 0; i < data.length; i++) {
        if (data[i]['app'] == Misc.appName) continue;

        temp.add(mFilterChip(label: data[i]["app"]!, color: ColorsB.gray800));
      }
      //  Remove where the key is equal to the Misc.appName

      setState(() {
        schools = temp;
      });
    });

    return 1;
  }

  late final Future _getSchools = getSchools();

  String? format;

  String generateString() {
    String generated = '';

    DateTime now = DateTime.now();
    String formatedDate = DateFormat('yyyyMMddkkmm').format(now);

    String selectedChannels = '';
    for (int i = 0; i < channels.length; i++) {
      selectedChannels += channels[i][0];
    }

    generated = selectedChannels + formatedDate;

    return generated;
  }

  Future<void> uploadImage(File? file, String name) async {
    try {
      if (image == null || file == null) {
        return;
      }
      var imageBytes = file.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);

      var url = Uri.parse('${Misc.link}/${Misc.appName}/image_upload.php');
      final response = await http.post(url,
          body: {"image": baseimage, "name": name, "format": format});

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["error"]) {
          ////m_debugPrint(jsondata["msg"]);
        } else {
          //m_debugPrint("Upload successful");
        }
      } else {
        //m_debugPrint("Upload failed");
      }
    } catch (e) {
      //m_debugPrint("Error during converting to Base64");
    }
  }

  void delete(mFilterChip filter) {
    selectedSchools.removeWhere((element) => element.label == filter.label);
    setState(() {});
  }

  Widget selectOtherSchools() => Column(children: [
        const Text(
          'Select other schools',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: ColorsB.yellow500,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              flex: 2,
              child: Wrap(
                children: selectedSchools
                    .map((e) =>
                        Padding(padding: const EdgeInsets.all(8), child: e))
                    .toList(),
              )),
          Expanded(
            flex: 1,
            child: schoolsDropDown(),
          )
        ]),
        const SizedBox(
          height: 50,
        ),
      ]);

  Widget schoolsDropDown() => FutureBuilder(
      future: _getSchools,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: ColorsB.gray800,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: DropdownButton<mFilterChip>(
                underline: const SizedBox(),
                menuMaxHeight: screenHeight * .5,
                hint: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Add School',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                dropdownColor: Colors.white10,
                borderRadius: BorderRadius.circular(30),
                isExpanded: true,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                items: schools
                    .map((e) => DropdownMenuItem<mFilterChip>(
                          value: e,
                          child: e,
                        ))
                    .toList(),
                onChanged: (value) {
                  m_debugPrint(selectedSchools);
                  delete(value!);
                  setState(() {
                    selectedSchools.add(value.copyWith(onDelete: () {
                      delete(value);
                    }));
                  });
                },
              ),
            ),
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorsB.gray900,
        bottomNavigationBar: const BackNavbar(
          variation: 1,
        ),
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
                  Icon(
                    Icons.book,
                    color: ColorsB.yellow500,
                    size: 40,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Make a new post',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
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
                  Visibility(
                    visible: globalMap['account'] == 'Admin',
                    child: selectOtherSchools(),
                  ),
                  InputField(
                    fieldName: 'Choose a title',
                    isPassword: false,
                    errorMessage: '',
                    controller: _postTitleController,
                    isEmail: false,
                    lengthLimiter: 30,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
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
                          borderSide: const BorderSide(
                            color: Colors.red,
                          )),
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
                  const SizedBox(
                    height: 50,
                  ),
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
                      children: Misc.categories.entries
                          .map((e) => Row(children: [
                                Checkbox(
                                  activeColor: ColorsB.yellow500,
                                  shape: const CircleBorder(
                                      side: BorderSide(
                                          color: Colors.white, width: 1)),
                                  side: const BorderSide(
                                      color: Colors.white, width: 1),
                                  value: channels.contains(e.key),
                                  onChanged: (value) {
                                    setState(() {
                                      //  classes[0] = value;
                                      if (value!) {
                                        channels.add(e.key);
                                        m_debugPrint('Added ${e.key}');
                                      } else {
                                        channels.remove(e.key);
                                      }
                                      //m_debugPrint(channels);
                                    });
                                  },
                                ),
                                Text(e.key,
                                    style: const TextStyle(color: Colors.white))
                              ]))
                          .toList()),
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

                          try {
                            final _image = await _picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 25);
                            if (_image == null) return;

                            image = _image;
                            _file = File(image!.path);

                            format = image!.name.split('.').last;

                            setState(() {
                              _imageText = image!.name;
                            });
                          } catch (e) {
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

                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (channels.isEmpty) {
                              setState(() {
                                errorText = 'Please select at least one class';
                              });
                              return;
                            }
                            showDialog(
                                context: context,
                                builder: (context) => const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ColorsB.yellow500),
                                      ),
                                    ));
                            setState(() {
                              errorText = '';
                            });

                            List<String> schoolsList =
                                selectedSchools.map((e) => e.label).toList();

                            // Insert current name at index 0
                            schoolsList.insert(0, Misc.appName);

                            m_debugPrint(schoolsList);

                            String name = generateString();

                            bool imgSub = false;

                            String imgLink = _file != null
                                ? "${Misc.link}/${Misc.appName}/imgs/$name.$format"
                                : "";

                            for (String channel in channels) {
                              try {
                                if (!imgSub && _file != null) {
                                  await uploadImage(_file, name);
                                  imgSub = true;
                                }
                                //m_debugPrint(channels[i]);

                                //m_debugPrint(_file);

                                var url = Uri.parse(
                                    '${Misc.link}/${Misc.appName}/postsAPI/insertposts.php');
                                final response;

                                response = await http.post(url, body: {
                                  "title": _postTitleController.value.text,
                                  "channel": channel,
                                  "body": _postController.value.text,
                                  "owner": globalMap["first_name"] +
                                      " " +
                                      globalMap["last_name"],
                                  "owid": globalMap['id'].toString(),
                                  "link": imgLink,
                                  "appList": jsonEncode(schoolsList),
                                  "mySchool": Misc.appName,
                                });

                                if (response.statusCode == 200) {
                                  var jsondata = json.decode(response.body);
                                  m_debugPrint(jsondata);
                                  if (jsondata["error"]) {
                                    Navigator.of(context).pop();
                                  } else {
                                    if (jsondata["success"]) {
                                      // Notifications

                                      // --------------------------------------------------

                                      try {
                                        var ulr2 = Uri.parse(
                                            '${Misc.link}/${Misc.appName}/notifications.php');
                                        final response2 =
                                            await http.post(ulr2, body: {
                                          "channel": channel,
                                          "owner": globalMap["first_name"] +
                                              " " +
                                              globalMap["last_name"],
                                          "action": "Post"
                                        });

                                        if (response2.statusCode == 200) {
                                          var jsondata2 =
                                              json.decode(response2.body);
                                          //  //m_debugPrint(jsondata2);
                                          Navigator.of(context).pop();
                                        }
                                      } catch (e) {
                                        //m_debugPrint(e);
                                      }

                                      // -------------------------------------------------
                                    } else {
                                      ////m_debugPrint(jsondata["message"]);
                                    }
                                  }
                                }
                              } catch (e) {
                                //Navigator.of(context).pop();
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              content: Row(
                                children: const [
                                  Icon(Icons.check, color: Colors.white),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Hooray! A new post was born.',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ));

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          backgroundColor: _postController.text.isEmpty ||
                                  _postTitleController.text.isEmpty ||
                                  channels.isEmpty
                              ? ColorsB.gray800
                              : ColorsB.yellow500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

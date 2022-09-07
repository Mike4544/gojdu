import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/colors.dart';
import '../databases/alertsdb.dart';
import '../widgets/back_navbar.dart';
import '../widgets/Alert.dart';
import 'package:intl/intl.dart';

class NotifPage extends StatefulWidget {
  final VoidCallback? updateFP;


  const NotifPage({Key? key, this.updateFP}) : super(key: key);

  @override
  State<NotifPage> createState() => _NotifPageState();
}



class _NotifPageState extends State<NotifPage> {

  List<Alert>? alerts;
  late bool isLoading = false;

  late Future loadAlerts = refreshAlerts();


  Future checkAndDelete() async {
    for(var a in alerts!){
      DateTime timeOffsetted = DateTime(a.createdTime.day, a.createdTime.month + 1, a.createdTime.year);


      if(timeOffsetted.month == DateTime.now().month){
        await AlertDatabase.instance.delete(a.id!);
      }
    }

  }

  Future setBall(bool state) async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setBool('activeBall', state);

  }

  Future<int> refreshAlerts() async {
    setState(() {
      isLoading = true;
    });


    alerts = await AlertDatabase.instance.readAllAlerts();


    await checkAndDelete();


    print(alerts!.length);

    setState(() {
      isLoading = false;
    });

    return 1;


  }

  void update(Alert al) async{
    setState(() {
      al.read = true;
    });

    bool toReadLeft = false;
    for(var a in alerts!){
      if(a.read == false){
        toReadLeft = true;
        break;
      }
    }

    if(!toReadLeft){
      await setBall(toReadLeft);
    }

  }

  @override
  void initState() {
     refreshAlerts();


    super.initState();
  }

  @override
  void dispose() {
    alerts!.clear();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsB.gray900,
      bottomNavigationBar: BackNavbar(variation: 1, update: widget.updateFP,),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications, color: ColorsB.yellow500, size: 40,),
                    SizedBox(width: 20,),
                    Text(
                      'Notifications',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      await AlertDatabase.instance.truncate();
                      await setBall(false);

                      refreshAlerts();
                    },
                    child: const Text(
                      "Clear notifications",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )
          ),
        ),
      ),
      body: isLoading == false
          ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scrollbar(
              child: ListView.builder(
              itemCount: alerts!.isNotEmpty ? alerts!.length : 1,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if(alerts!.isNotEmpty){
                  return AlertContainer(alert: alerts![index],
                      callback: () async {
                          update(alerts![index]);

                          final temp = alerts![index].copy(
                            read: true,
                          );

                          await AlertDatabase.instance.update(temp);

                      }
                    );
                }
                else {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/svgs/404.svg'),
                        const Text(
                          'Seems there are no reports!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.5,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  );
                }
              }
      ),
            ),
          )
          : const SizedBox()

    );
  }
}

class AlertContainer extends StatelessWidget {
  final Alert alert;
  final VoidCallback callback;

  const AlertContainer({Key? key, required this.alert, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var title = alert.title;
    var owner = alert.owner;
    var desc = alert.description;
    var time = alert.createdTime;
    var stringImage = alert.imageString;
    var read = alert.read;


    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Container(
              height: 125,
              decoration: read
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: ColorsB.gray800, width: 3),
              )
              : BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: ColorsB.gray800, width: 3),
                gradient: LinearGradient(
                  colors: [ColorsB.gray800.withOpacity(.25), ColorsB.gray700],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: const [.25, 1]
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 15,
                    //  offset: Offset(10, 5),
                    color: Colors.black26,
                    spreadRadius: 5
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title.length < 45 ? title : '$title...',
                          style: TextStyle(
                              color: !read ? Colors.white : Colors.white30,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.5
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Text(
                          DateFormat.yMMMd().format(time),
                          style: TextStyle(
                              color: read ? Colors.white30 : Colors.white,
                              fontSize: 12.5
                          ),
                        )
                      ],

                    ),
                    Text(
                      'Alerted by $owner',
                      style: TextStyle(
                          color: read ? Colors.white30 : ColorsB.yellow500,
                          fontSize: 15
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 125,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {

                    callback();

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
                                  child: BigNewsContainer(title: title, description: desc, color: ColorsB.gray800, author: owner, imageString: stringImage,),
                                )
                        )
                    );

                  },
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// <---------- Height and width outside of context -------------->
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class BigNewsContainer extends StatelessWidget {

  final String title;
  final String description;
  final Color color;
  final String author;
  final String? imageString;


  const BigNewsContainer({Key? key, required this.title, required this.description, required this.color, required this.author, this.imageString}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    Widget topPage() {
      //print(imageLink);


      if(imageString == 'null'){
        return Hero(
          tag: 'title-rectangle',
          child: Container(
            width: screenWidth,
            height: screenHeight * 0.5,
            color: color,
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
                          SizedBox(
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Text(
                              "Alerted by " + author,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              )
                          )
                        ],
                      ),
                    ],
                  )
              ),
            ),
          ),
        );
      }
      else {

        // Uint8List imagBytes = base64Decode(imageString!);

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
                                              child: Image.network(imageString!)
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
                            image: Image.network(imageString!).image,
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
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
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
                          Text(
                            title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                              "by " + author,
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
                  text: description,
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
}


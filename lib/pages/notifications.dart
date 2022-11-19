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
import '../local_notif_service.dart';

import 'package:http/http.dart' as http;

import 'package:gojdu/others/options.dart';

class NotifPage extends StatefulWidget {
  final VoidCallback? updateFP;
  final bool isAdmin;

  const NotifPage({Key? key, this.updateFP, required this.isAdmin})
      : super(key: key);

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  List<Alert>? alerts;
  late bool isLoading = false;

  late Future loadAlerts = refreshAlerts();

  //  final LocalNotificationService _notifService = LocalNotificationService();

  Future checkAndDelete() async {
    for (var a in alerts!) {
      DateTime timeOffsetted = DateTime(
          a.createdTime.day, a.createdTime.month + 1, a.createdTime.year);

      if (timeOffsetted.month == DateTime.now().month) {
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

    //  print(alerts!.length);

    setState(() {
      isLoading = false;
    });

    return 1;
  }

  void share(Alert al) async {
    setState(() {
      al.shared = true;
    });
  }

  void update(Alert al) async {
    setState(() {
      al.read = true;
    });

    bool toReadLeft = false;
    for (var a in alerts!) {
      if (a.read == false) {
        toReadLeft = true;
        break;
      }
    }

    if (!toReadLeft) {
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
        bottomNavigationBar: BackNavbar(
          variation: 1,
          update: widget.updateFP,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.notifications,
                          color: ColorsB.yellow500,
                          size: 40,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Notifications',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    /*
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      // await AlertDatabase.instance.truncate();
                      // await setBall(false);
                      //
                      // refreshAlerts();

                      //  _notifService.showNotification(id: 1, title: 'Test', body: 'Test');
                    },
                    child: const Text(
                      "Clear notifications",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )*/
                  ],
                )),
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
                        if (alerts!.isNotEmpty) {
                          return AlertContainer(
                            isAdmin: widget.isAdmin,
                            alert: alerts![index],
                            callback: () async {
                              update(alerts![index]);

                              final temp = alerts![index].copy(
                                read: true,
                              );

                              await AlertDatabase.instance.update(temp);
                            },
                            share: () async {
                              share(alerts![index]);

                              final temp = alerts![index].copy(
                                shared: true,
                              );

                              await AlertDatabase.instance.update(temp);
                            },
                          );
                        } else {
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
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          );
                        }
                      }),
                ),
              )
            : const SizedBox());
  }
}

class AlertContainer extends StatelessWidget {
  final Alert alert;
  final VoidCallback callback;
  final VoidCallback share;
  final bool isAdmin;

  const AlertContainer(
      {Key? key,
      required this.alert,
      required this.callback,
      required this.share,
      required this.isAdmin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = alert.title;
    var owner = alert.owner;
    var desc = alert.description;
    var time = alert.createdTime;
    var stringImage = alert.imageString;
    var read = alert.read;
    var shared = alert.shared;

    Future<void> sendReport(String title, String owner, String desc,
        DateTime time, var link) async {
      try {
        var url = Uri.parse('${Misc.link}/${Misc.appName}/notifications.php');
        final response = await http.post(url, body: {
          "action": "Report_teachers",
          "channel": "Teachers",
          "rtitle": title,
          "rdesc": desc,
          "rowner": owner,
          "link": link,
          "time": time.toIso8601String()
        });

        // print(response.statusCode);
        //       // print(response.body);
        //  print(DateTime.now().toIso8601String());
        print(response.statusCode);

        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);

          print(jsondata);

          //  Navigator.of(context).pop();
        } else {
          print('Error!');
        }
      } catch (e) {
        print("Exception! $e");
      }
    }

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
                          colors: [
                            ColorsB.gray800.withOpacity(.25),
                            ColorsB.gray700
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          stops: const [.25, 1]),
                      boxShadow: const [
                          BoxShadow(
                              blurRadius: 15,
                              //  offset: Offset(10, 5),
                              color: Colors.black26,
                              spreadRadius: 5)
                        ]),
            ),
            SizedBox(
              height: 125,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    callback();

                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secAnim) =>
                            SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: animation, curve: Curves.ease)),
                              child: BigNewsContainer(
                                title: title,
                                description: desc,
                                color: ColorsB.gray800,
                                author: owner,
                                imageString: stringImage,
                              ),
                            )));
                  },
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(
              height: 125,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title.length < 15
                                ? title
                                : '${title.substring(0, 15)}...',
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: !read ? Colors.white : Colors.white30,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.fade,
                                fontSize: 17.5),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          DateFormat.yMMMd().format(time),
                          style: TextStyle(
                              color: read ? Colors.white30 : Colors.white,
                              fontSize: 12.5),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              owner.length < 12
                                  ? 'Alerted by $owner'
                                  : 'Alerted by ${owner.substring(0, 15)}...',
                              style: TextStyle(
                                  color:
                                      read ? Colors.white30 : ColorsB.yellow500,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                        if (!shared && isAdmin)
                          FittedBox(
                            child: TextButton.icon(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                share();

                                await sendReport(
                                    title, owner, desc, time, stringImage);
                              },
                              label: const Text("Share with teachers",
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                              style: TextButton.styleFrom(
                                  backgroundColor: ColorsB.yellow500,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                          )
                        else
                          Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: ColorsB.gray800),
                            child: const Center(
                              child: FittedBox(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ],
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

  const BigNewsContainer(
      {Key? key,
      required this.title,
      required this.description,
      required this.color,
      required this.author,
      this.imageString})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget topPage() {
      BoxDecoration woImage = BoxDecoration(color: color);

      BoxDecoration wImage = BoxDecoration(
        image: DecorationImage(
            image: Image.network(
              imageString!,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(ColorsB.yellow500));
              },
            ).image,
            fit: BoxFit.cover),
      );

      //print(imageLink);

      return GestureDetector(
        onTap: imageString == 'null'
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
                                child: Image.network(imageString!)),
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
          width: screenWidth,
          height: screenHeight * 0.5,
          decoration: imageString == 'null' ? woImage : wImage,
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
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Text("Alerted by " + author,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ))
                      ],
                    ),
                  ],
                )),
          ),
        ),
      );
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
                      fontWeight: FontWeight.normal),
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                )),
          )
        ],
      ),
    );
  }
}

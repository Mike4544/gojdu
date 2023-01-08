import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/pages/news.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/api.dart';
import '../others/colors.dart';
//  import '../databases/alertsdb.dart';
import '../widgets/back_navbar.dart';
import '../widgets/Alert.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import 'package:gojdu/others/options.dart';

import '../widgets/lazyBuilder.dart';

class NotifPage extends StatefulWidget {
  final VoidCallback? updateFP;
  final bool isAdmin;
  ValueNotifier notifs;

  NotifPage(
      {Key? key, this.updateFP, required this.isAdmin, required this.notifs})
      : super(key: key);

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  // List<Alert> alerts = [];
  List<AlertContainer> alerts = [];
  late bool isLoading = false;

  // Future setBall(bool state) async {
  //   var prefs = await SharedPreferences.getInstance();

  //   await prefs.setBool('activeBall', state);

  //   setState(() {});
  // }

  int lastMaxAlerts = -1; //  INT MAX
  int maxScrollCountAlerts = 10;
  int turnsAlerts = 10;
  int lastIDAlerts = Misc.INT_MAX;

  late Future _getAlerts = loadAlerts();

  Future<void> deleteAlert(Alert _alert) async {
    String link = '${Misc.link}/${Misc.appName}/reportsAPI/deleteReport.php';

    try {
      final response = await http.post(Uri.parse(link), body: {
        'id': '${_alert.id}',
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata["success"]) {
            m_debugPrint(jsondata["message"]);

            //  Delete the alert from the list
            alerts.removeWhere((element) => element.alert.id == _alert.id);
            setState(() {});

            //  Display a snack bar
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Alert deleted'),
              duration: Duration(seconds: 2),
            ));
          } else {
            m_debugPrint(jsondata["message"]);
          }
        }
      }
    } catch (e, s) {
      m_debugPrint(e.toString());
      m_debugPrint(s.toString());
      throw Future.error(e.toString());
    }
  }

  Future<int> loadAlerts() async {
    //  Alerts.clear();
    widget.notifs.value = 0;
    lastMaxAlerts = maxScrollCountAlerts;

    //  Maybe rework this a bit.

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/getAlerts.php');
      final response = await http.post(url, body: {
        "lastID": '$lastIDAlerts',
        'turns': '$turnsAlerts',
        'persID': '${globalMap['id']}',
        'availability': globalMap['account'] == 'Admin' ? '1' : '2'
      });
      m_debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //m_debugPrint(jsondata.toString());

        if (jsondata[0]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata[0]["success"] && jsondata[1] != null) {
            m_debugPrint(jsondata);
            for (int i = 1; i < jsondata.length; i++) {
              //  alerts.add(Alert.fromJson(jsondata));
              final currAlert = Alert.fromJson(jsondata[i]);

              alerts.add(AlertContainer(
                  delete: deleteAlert,
                  alert: currAlert,
                  callback: view,
                  share: share,
                  isAdmin: globalMap['account'] == 'Admin'));

              if (!currAlert.read) {
                widget.notifs.value++;
              }
            }

            //  Add the search terms
            maxScrollCountAlerts += turnsAlerts;
            lastIDAlerts = alerts.last.alert.id!;
            m_debugPrint(maxScrollCountAlerts.toString());
            m_debugPrint(lastMaxAlerts.toString());

            //  m_debugPrint(events);
          } else {
            ////m_debugPrint(jsondata[0]["message"]);
          }
        }
      }
    } catch (e, s) {
      m_debugPrint(e.toString());
      m_debugPrint(s.toString());
      throw Future.error(e.toString());
    }

    return 0;
  }

  Future<void> refreshAlerts() async {
    alerts.clear();

    setState(() {
      maxScrollCountAlerts = turnsAlerts;
      lastMaxAlerts = -1;

      lastIDAlerts = Misc.INT_MAX;

      _getAlerts = loadAlerts();
    });

    //  return 1;
  }

  void lazyLoadCallback() async {
    if (lazyController.position.extentAfter == 0 &&
        lastMaxAlerts < maxScrollCountAlerts) {
      m_debugPrint('Haveth reached the end');

      await loadAlerts();

      setState(() {});
    }
  }

  late ScrollController lazyController;

  void share(Alert al) async {
    try {
      //  m_debugPrint(Availability.TEACHERS);
      final response = await http.post(
          Uri.parse('${Misc.link}/${Misc.appName}/updateAlerts.php'),
          body: {'id': al.id.toString(), 'nAvail': '2'});

      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);

        setState(() {
          al.shared = true;
        });

        try {
          var url = Uri.parse('${Misc.link}/${Misc.appName}/notifications.php');
          final response = await http.post(url, body: {
            "action": "Report_teachers",
            "channel": "Teachers",
            "rtitle": al.title,
            "rdesc": al.description,
            "rowner": al.owner,
            "link": null.toString(),
            "time": al.createdTime.toIso8601String()
          });

          // m_debugPrint(response.statusCode);
          //       // m_debugPrint(response.body);
          //  m_debugPrint(DateTime.now().toIso8601String());
          m_debugPrint(response.statusCode.toString());

          if (response.statusCode == 200) {
            var jsondata = jsonDecode(response.body);

            //m_debugPrint(jsondata.toString());

            //  Navigator.of(context).pop();
          } else {
            m_debugPrint('Error!');
          }
        } catch (e, stack) {
          m_debugPrint("Exception! $e");
          m_debugPrint(stack.toString());
        }
      }
    } catch (e, stack) {
      m_debugPrint('EXCEPTION: $e');
      m_debugPrint('STACK: $stack');

      SnackBar failed = const SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        content: Text("Couldn't share with other teachers!",
            style: TextStyle(color: Colors.white)),
      );

      ScaffoldMessenger.of(context).showSnackBar(failed);
    }
  }

  void update(Alert al) async {
    setState(() {
      al.read = true;
    });
  }

  Future<void> view(Alert alert) async {
    try {
      final response = await http
          .post(Uri.parse('${Misc.link}/${Misc.appName}/viewAlert.php'), body: {
        'reportID': alert.id.toString(),
        'person': globalMap['id'].toString()
      });

      switch (response.statusCode) {
        case 200:
          m_debugPrint('O mers');
          widget.notifs.value--;
          break;

        default:
          m_debugPrint('N-o mers');
          break;
      }
    } catch (e, stack) {
      m_debugPrint('Error whilst viewing! $e \n $stack');
    }
  }

  @override
  void initState() {
    //  refreshAlerts();
    lazyController = ScrollController()..addListener(lazyLoadCallback);

    super.initState();
  }

  @override
  void dispose() {
    alerts.clear();
    lazyController.dispose();

    //  setBall(finalTest());

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
        body: LazyBuilder(
          future: _getAlerts,
          widgetList: alerts,
          lastID: lastIDAlerts,
          lastMax: lastMaxAlerts,
          turns: turnsAlerts,
          maxScrollCount: maxScrollCountAlerts,
          refresh: refreshAlerts,
          scrollController: lazyController,
        ));
  }
}

class AlertContainer extends StatefulWidget {
  final Alert alert;
  final Function(Alert) callback;
  final Function(Alert) share;
  final Function(Alert) delete;
  final bool isAdmin;

  const AlertContainer({
    Key? key,
    required this.delete,
    required this.alert,
    required this.callback,
    required this.share,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<AlertContainer> createState() => _AlertContainerState();
}

class _AlertContainerState extends State<AlertContainer> {
  late var title = widget.alert.title;
  late var owner = widget.alert.owner;
  late var desc = widget.alert.description;
  late var time = widget.alert.createdTime;
  late var stringImage = widget.alert.imageString;
  late var read = widget.alert.read;
  late var shared = widget.alert.shared;
  late int seenby = widget.alert.seenby;

  Widget _seenByBar() => Visibility(
        visible: seenby - 1 > 0,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 50),
            decoration: BoxDecoration(
                color: ColorsB.gray800,
                borderRadius: BorderRadius.circular(360)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  read
                      ? 'Seen by ${seenby - 1} other(s).'
                      : 'Seen by $seenby other(s).',
                  style: TextStyle(fontSize: 15.sp, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
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
                        if (!read) {
                          widget.callback(widget.alert);
                          seenby++;
                          //  widget.sort();
                        }

                        setState(() {
                          read = true;
                        });

                        m_debugPrint(read.toString());

                        Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (context, animation, secAnim) =>
                                SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.ease)),
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
                                    color:
                                        !read ? Colors.white : Colors.white30,
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
                                      : 'Alerted by ${owner.substring(0, 12)}...',
                                  style: TextStyle(
                                      color: read
                                          ? Colors.white30
                                          : ColorsB.yellow500,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                            if (!shared && widget.isAdmin)
                              FittedBox(
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await widget.share(widget.alert);

                                      setState(() {
                                        shared = true;
                                      });
                                    } catch (e) {
                                      m_debugPrint(e.toString());
                                    }
                                  },
                                  label: const Text("Share with teachers",
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                  style: TextButton.styleFrom(
                                      backgroundColor: ColorsB.yellow500,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                ),
                              )
                            else
                              Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorsB.gray800),
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
                ),
                Positioned(
                  //  Make a delete button on the bottom left
                  left: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.delete(widget.alert);
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            _seenByBar()
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
            image: CachedNetworkImageProvider(imageString!), fit: BoxFit.cover),
      );

      //m_debugPrint(imageLink);

      return GestureDetector(
        onTap: imageString == 'null' || imageString == ''
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
                              child: CachedNetworkImage(
                                imageUrl: imageString!,
                              ),
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
          width: screenWidth,
          height: screenHeight * 0.5,
          decoration:
              imageString == 'null' || imageString == '' ? woImage : wImage,
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

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gojdu/pages/news.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/colors.dart';
import '../widgets/back_navbar.dart';
import '../widgets/lazyBuilder.dart';
import 'addOpportunity.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

import 'package:gojdu/others/options.dart';

class OpportunitiesList extends StatefulWidget {
  final Map globalMap;

  const OpportunitiesList({Key? key, required this.globalMap})
      : super(key: key);

  @override
  State<OpportunitiesList> createState() => _OpportunitiesListState();
}

class _OpportunitiesListState extends State<OpportunitiesList>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  var screenHeight = window.physicalSize.height / window.devicePixelRatio;
  var screenWidth = window.physicalSize.width / window.devicePixelRatio;

  Future<void> deleteEvent(int Id, int index) async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/deleteOpportunity.php');
      final response = await http.post(url, body: {"id": Id.toString()});

      debugPrint(Id.toString());
      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        debugPrint(response.body);

        var jsondata = json.decode(response.body);
        //  debugPrint(jsondata);

        if (jsondata['error']) {
          debugPrint('Errored');

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

          opportunities.removeAt(index);
        }
      } else {
        debugPrint("Deletion failed.");
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

      debugPrint(e.toString());
    }
  }

  int lastMaxOpportunities = -1; //  INT MAX
  int maxScrollCountOpportunities = 10;
  int turnsOpportunities = 10;
  int lastIDOpportunities = Misc.INT_MAX;

  Future<void> refresh() async {
    opportunities.clear();

    setState(() {
      maxScrollCountOpportunities = turnsOpportunities;
      lastMaxOpportunities = -1;

      lastIDOpportunities = Misc.INT_MAX;

      _getOpportunities = loadOpportunities();
      setState(() {});
      //  widget.future = widget.futureFunction;
    });
  }

  void lazyLoadCallback() async {
    if (lazyController.position.extentAfter == 0 &&
        lastMaxOpportunities < maxScrollCountOpportunities) {
      debugPrint('Haveth reached the end');

      await loadOpportunities();

      setState(() {});
    }
  }

  late ScrollController lazyController;

  Future<int> loadOpportunities() async {
    //  opportunities.clear();
    lastMaxOpportunities = maxScrollCountOpportunities;

    //  Maybe rework this a bit.

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/getOpportunities.php');
      final response = await http.post(url, body: {
        "lastID": '$lastIDOpportunities',
        'turns': '$turnsOpportunities'
      });
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        debugPrint(jsondata);

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
              String location = jsondata[i]["location"].toString();
              String date = jsondata[i]["timeDate"].toString();
              String link = jsondata[i]["link"].toString();
              String gmaps = jsondata[i]["mapsLink"].toString();
              String color = jsondata[i]["color"].toString();
              String topic = jsondata[i]["topic"].toString();

              // debugPrint(date);
              // debugPrint('Index $i');

              int? id = jsondata[i]["id"];
              int? oid = jsondata[i]["ownerID"];

              ////debugPrint(globalMap['id']);

              if (id != null) {
                // events.add(Event(title: title,
                //   id: id,
                //   body: post,
                //   owner: owner,
                //   link: link,
                //   date: date,
                //   location: location,
                //   gMap: globalMap,
                //   Context: context,
                //   delete: () async {
                //     await deleteEvent(id!, i - 2);
                //
                //     setState(() {
                //
                //     });
                //
                //   },
                // )
                // );
                opportunities.add(OpportunityCard(
                  owner: owner,
                  id: id,
                  ownerID: oid!,
                  dev_height: screenHeight,
                  dev_width: screenWidth,
                  s_color: color,
                  category: topic,
                  gmaps_link: gmaps,
                  headerImageLink: link,
                  description: post,
                  title: title,
                  city: location.split(',').first,
                  date: DateTime.tryParse(date) ?? DateTime(1970, 1, 1),
                  delete: () async {
                    await deleteEvent(id, i - 1);
                    setState(() {});
                  },
                  globalMap: globalMap,
                ));

                //  debugPrint(opportunities.length);
              }
            }

            //  Add the search terms
            maxScrollCountOpportunities += turnsOpportunities;
            lastIDOpportunities = opportunities.last.id;

            //  debugPrint(events);
          } else {
            //debugPrint(jsondata[0]["message"]);
          }
        }
      }
    } catch (e) {
      throw Future.error(e.toString());
    }

    return 0;
  }

  late List<OpportunityCard> opportunities;

  final searchEditor = TextEditingController();

  @override
  void initState() {
    opportunities = [];
    lazyController = ScrollController();

    lazyController.addListener(lazyLoadCallback);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    opportunities.clear();
    searchEditor.dispose();
    super.dispose();
  }

  late Future _getOpportunities = loadOpportunities();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    //  debugPrint('building');


    Widget opportunityList() {
      List dummyList = [];

      for (var e in opportunities) {
        if (searchEditor.text.isEmpty) {
          dummyList.add(e);
        } else {
          if (e.title!
                  .toLowerCase()
                  .contains(searchEditor.text.toLowerCase()) ||
              e.category
                  .toLowerCase()
                  .contains(searchEditor.text.toLowerCase())) {
            dummyList.add(e);
          }
        }
      }

      return LazyBuilder(
          future: _getOpportunities,
          widgetList: opportunities,
          lastID: lastIDOpportunities,
          lastMax: lastMaxOpportunities,
          maxScrollCount: maxScrollCountOpportunities,
          refresh: refresh,
          scrollController: lazyController,
          turns: turnsOpportunities);
    }

    return GestureDetector(
        onTap: () {
          //  FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            const TriangleBackground(),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SearchButtonBar(
                          isAdmin: widget.globalMap['account'] == 'Admin' ||
                              widget.globalMap['account'] == 'Teacher',
                          searchController: searchEditor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                            visible: widget.globalMap['account'] == 'Admin' ||
                                widget.globalMap['account'] == 'Teacher',
                            child: FloatingActionButton(
                              elevation: 0,
                              backgroundColor: ColorsB.gray800,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AddOpportunity(gMap: globalMap)));
                              },
                              mini: true,
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(child: opportunityList()),
                  ],
                )),
          ],
        ));
  }
}

class TriangleBackground extends StatefulWidget {
  const TriangleBackground({Key? key}) : super(key: key);

  @override
  State<TriangleBackground> createState() => _TriangleBackgroundState();
}

class _TriangleBackgroundState extends State<TriangleBackground> {
  static const double _backConstant = 1.5;
  static const double _midConstant = 3.5;

  late var _acceleration;

  late double _b1, _b2, _b3;
  late Timer _timer;
  double _lb1 = 8, _lb2 = 5, _lb3 = 3;

  void _getNewVals() {
    _lb1 = _b1;
    _lb2 = _b2;
    _lb3 = _b3;

    _b1 = math.Random().nextDouble() * 9;
    _b2 = math.Random().nextDouble() * 6;
    _b3 = math.Random().nextDouble() * 4;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _acceleration = AccelerometerEvent(0, 0, 0);
    _b1 = _b2 = _b3 = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      accelerometerEvents.listen((event) {
        if (mounted) {
          setState(() {
            _acceleration = event;
          });
        }
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _getNewVals();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 4),
          curve: Curves.ease,
          tween: Tween<double>(begin: _lb1, end: _b1),
          builder: (
            _,
            value,
            __,
          ) =>
              AnimatedPositioned(
            child: SizedBox(
                height: screenHeight * .25,
                width: screenHeight * .25,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaY: value, sigmaX: value),
                  child: Image.asset(
                    'assets/images/3.png',
                    frameBuilder: (BuildContext context, Widget child,
                        int? frame, bool wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  ),
                )),
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            top: 25.0 + (_acceleration.y * -_backConstant),
            right: _acceleration.x * -_backConstant,
          ),
        ),
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 4),
          curve: Curves.ease,
          tween: Tween<double>(begin: _lb2, end: _b2),
          builder: (
            _,
            value,
            __,
          ) =>
              ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: value, sigmaY: value),
            child: Stack(
              children: [
                AnimatedPositioned(
                  child: SizedBox(
                    height: screenHeight * .2,
                    width: screenHeight * .2,
                    child: Image.asset(
                      'assets/images/Untitled-1.png',
                      frameBuilder: (BuildContext context, Widget child,
                          int? frame, bool wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) {
                          return child;
                        }
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                    ),
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  top: screenHeight * .15 + (_acceleration.y * -_midConstant),
                  left: _acceleration.x * _midConstant,
                ),
                AnimatedPositioned(
                  child: Transform.rotate(
                    angle: 0,
                    child: SizedBox(
                      height: screenHeight * .27,
                      width: screenHeight * .27,
                      child: Image.asset(
                        'assets/images/Untitled-1.png',
                        frameBuilder: (BuildContext context, Widget child,
                            int? frame, bool wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  bottom:
                      screenHeight * .175 + (_acceleration.y * -_midConstant),
                  right: -75.0 + _acceleration.x * -_midConstant,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .4,
            child: Image.asset(
              'assets/images/Target.png',
              frameBuilder: (BuildContext context, Widget child, int? frame,
                  bool wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BetterChip extends StatelessWidget {
  final double height;
  final double width;
  final Color bgColor;
  final String label;
  final bool isGlass;
  final IconData icon;
  final IconData? secIcon;

  const BetterChip(
      {Key? key,
      this.height = 35.0,
      this.width = 100.0,
      this.bgColor = Colors.grey,
      this.isGlass = false,
      required this.icon,
      required this.label,
      this.secIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var normalDecoration =
        BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(360));

    var glassDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        gradient: LinearGradient(
            colors: [bgColor.withOpacity(.75), bgColor.withOpacity(.1)],
            stops: const [0, .75],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
        border: Border.all(
            color: Color.alphaBlend(bgColor, Colors.white).withOpacity(.25)));

    return Container(
      height: height,
      constraints: BoxConstraints(maxWidth: width),
      decoration: isGlass ? glassDecoration : normalDecoration,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      icon,
                      color: ThemeData.estimateBrightnessForColor(bgColor) ==
                              Brightness.light
                          ? ColorsB.gray900
                          : Colors.white,
                    )),
              ),
            ),
            Expanded(
              flex: 4,
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                            color:
                                ThemeData.estimateBrightnessForColor(bgColor) ==
                                        Brightness.light
                                    ? ColorsB.gray900
                                    : Colors.white,
                            fontSize: 12.5.sp),
                      ),
                    ),
                    if (secIcon != null)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GestureDetector(
                            onTap: () {
                              //  Make the google maps stuff
                              //  TODO:GMAPS
                            },
                            child: Icon(
                              secIcon!,
                              color: ThemeData.estimateBrightnessForColor(
                                          bgColor) ==
                                      Brightness.light
                                  ? ColorsB.gray900
                                  : Colors.white,
                            ),
                          ),
                        ),
                      )
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

class OpportunityCard extends StatelessWidget {
  final int id;
  final Map globalMap;
  final int ownerID;
  final double dev_height;
  final double dev_width;
  final String s_color;
  final String category;
  final String? title;
  final String? description;
  final String? city;
  final String gmaps_link;
  final String? headerImageLink;
  final String owner;
  final DateTime date;
  final delete;

  const OpportunityCard(
      {Key? key,
      required this.globalMap,
      required this.ownerID,
      required this.date,
      required this.owner,
      required this.id,
      required this.dev_height,
      required this.dev_width,
      required this.s_color,
      required this.category,
      this.title,
      this.description,
      this.city,
      required this.gmaps_link,
      this.headerImageLink,
      required this.delete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> _iconsForTags = {
      'IT': Icons.computer,
      'Design': Icons.edit,
      'Fashion': Icons.shopping_bag_rounded,
      'Other': Icons.cases
    };

    final Map<String, List<Color>> _colorsForTags = {
      'IT': [
        Colors.greenAccent[400]!,
        Colors.greenAccent,
      ],
      'Design': [const Color(0xFFe3dc94), const Color(0xfff7f1b0)],
      'Fashion': [Colors.pink, Colors.pinkAccent],
      'Other': [Colors.brown[700]!, Colors.brown[400]!]
    };

    //  Color _color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1);
    var tempcolor = s_color.split('(0x')[1].split(')')[0];
    int value = int.parse(tempcolor, radix: 16);
    Color color = Color(value);

    final titleText = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.sp);

    final subtitleText = TextStyle(
      color: Colors.white,
      fontSize: 12.5.sp,
    );
    // String dummyText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras accumsan blandit ullamcorper. Phasellus porta eu eros eu rutrum. In hac habitasse platea dictumst.                                  Donec interdum ligula purus, id posuere felis ornare ac. Duis id mattis risus. Cras vitae sapien nec mauris semper sodales id ut odio. Nunc elementum, purus                                      vulputate congue tincidunt, elit dolor dignissim sapien';

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: SizedBox(
            height: dev_height * .4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(dev_width * .075),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 7,
                  sigmaY: 7,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                color.withOpacity(.5),
                                color.withOpacity(.05),
                              ],
                              stops: const [
                                0,
                                .75
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight),
                          borderRadius: BorderRadius.circular(dev_width * .075),
                          border: Border.all(
                              color: Color.alphaBlend(color, Colors.white)
                                  .withOpacity(.25))),
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                title ?? 'Opportunity Title',
                                                style: titleText,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              description!.length > 100
                                                  ? description!
                                                          .substring(0, 100) +
                                                      '...'
                                                  : description!,
                                              style: subtitleText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Image.asset(
                                            'assets/images/$category.png'))
                                  ],
                                ),
                              ),
                              Flexible(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: BetterChip(
                                              icon: Icons.location_on_outlined,
                                              label: city != null
                                                  ? city!
                                                  : 'Oradea',
                                              isGlass: true,
                                              bgColor: Colors.white,
                                              width: dev_width * .33,
                                              height: dev_height * .05,
                                            )),
                                      ),
                                      SizedBox(
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: BetterChip(
                                              icon:
                                                  Icons.calendar_today_outlined,
                                              label: DateFormat("dd/MM/yyyy")
                                                  .format(date),
                                              isGlass: true,
                                              bgColor: Colors.white,
                                              width: dev_width * .33,
                                              height: dev_height * .05,
                                            )),
                                      )
                                    ],
                                  ))
                            ],
                          ))),
                    ),
                    Positioned(
                      top: 0,
                      right: 25,
                      child: ClipPath(
                        clipper: Ribbon(),
                        child: Container(
                          width: dev_height * 0.05,
                          height: dev_height * 0.05 + 25,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Center(
                                child: Icon(
                                  _iconsForTags[category]!,
                                  color: ColorsB.gray900,
                                ),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: _colorsForTags[category]!,
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight)),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(dev_width * .075),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BigNewsContainer(
                                    title: title!,
                                    description: description!,
                                    color: color,
                                    date: DateFormat("dd/MM/yyyy").format(date),
                                    location: city!,
                                    imageString: headerImageLink,
                                    gMapsLink: gmaps_link,
                                  )));
                        },
                      ),
                    ),
                    Visibility(
                      visible: globalMap['account'] == 'Admin' ||
                          globalMap['id'] == ownerID,
                      child: Positioned(
                        bottom: dev_height * .05,
                        right: 25,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: dev_height * .05,
                          ),
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
                                              color: ColorsB.yellow500,
                                              fontSize: 15),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    color: ColorsB.yellow500,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
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
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    color: ColorsB.gray800,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class BigNewsContainer extends StatefulWidget {
  final String title;
  final String description;
  final Color? color;
  final String date;
  final String location;
  final String? imageString;
  final String? gMapsLink;

  const BigNewsContainer(
      {Key? key,
      this.gMapsLink,
      required this.title,
      required this.description,
      this.color = ColorsB.yellow500,
      this.imageString,
      required this.date,
      required this.location})
      : super(key: key);

  @override
  State<BigNewsContainer> createState() => _BigNewsContainerState();
}

class _BigNewsContainerState extends State<BigNewsContainer> {
  bool get _isCollapsed {
    return _controller.position.pixels >= screenHeight * .65 &&
        _controller.hasClients;
  }

  var avatarImg;

  final ScrollController _controller = ScrollController();

  bool visible = false;

  @override
  void initState() {
    debugPrint(avatarImg);

    _controller.addListener(() {
      _isCollapsed ? visible = true : visible = false;

      //  debugPrint(_controller.position.pixels);

      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  Widget topPage() {
    BoxDecoration woImage = BoxDecoration(color: widget.color);

    BoxDecoration wImage = BoxDecoration(
      image: DecorationImage(
          image: Image.network(
            widget.imageString!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(ColorsB.yellow500));
            },
          ).image,
          fit: BoxFit.cover),
    );

    //debugPrint(imageLink);

    return GestureDetector(
      onTap: (widget.imageString == 'null' || widget.imageString == '')
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
                              child: Image.network(widget.imageString!)),
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
        decoration: (widget.imageString == 'null' || widget.imageString == '')
            ? woImage
            : wImage,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                height: screenHeight * .3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                widget.title,
                                maxLines: 1,
                                style: TextStyle(
                                    color: ThemeData.estimateBrightnessForColor(
                                                widget.color!) ==
                                            Brightness.light
                                        ? ColorsB.gray900
                                        : Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () async {
                                if (await canLaunchUrl(
                                    Uri.parse(widget.gMapsLink!))) {
                                  await launchUrl(Uri.parse(widget.gMapsLink!));
                                } else {
                                  debugPrint('Can\'t do it chief');
                                }
                              },
                              child: Row(
                                children: [
                                  Chip(
                                      backgroundColor: Colors.grey[200],
                                      avatar: const Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      label: Text(widget.location)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Visibility(
                                    visible: widget.gMapsLink!.isNotEmpty,
                                    child: Text(
                                      'Open in Google Maps',
                                      style: TextStyle(
                                          color: ThemeData
                                                      .estimateBrightnessForColor(
                                                          widget.color!) ==
                                                  Brightness.light
                                              ? ColorsB.gray900
                                              : Colors.white,
                                          fontSize: 12.5.sp),
                                    ),
                                  )
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Chip(
                            backgroundColor: Colors.grey[200],
                            avatar: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            label: Text(widget.date),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    return Scaffold(
        bottomNavigationBar: const BackNavbar(),
        backgroundColor: ColorsB.gray900,
        body: Scrollbar(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
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
                        Text(
                          widget.title.length > 20
                              ? widget.title.substring(0, 20) + '...'
                              : widget.title,
                          style: TextStyle(
                              color: ThemeData.estimateBrightnessForColor(
                                          widget.color!) ==
                                      Brightness.light
                                  ? ColorsB.gray900
                                  : Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableLinkify(
                          linkStyle: const TextStyle(color: ColorsB.yellow500),
                          text: widget.description,
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
                        ),
                        const Spacer()
                      ],
                    )),
              )
            ],
          ),
        ));
  }
}

class SearchButtonBar extends StatefulWidget {
  final bool isAdmin;
  final TextEditingController searchController;

  const SearchButtonBar(
      {Key? key, required this.isAdmin, required this.searchController})
      : super(key: key);

  @override
  State<SearchButtonBar> createState() => _SearchButtonBarState();
}

class _SearchButtonBarState extends State<SearchButtonBar>
    with TickerProviderStateMixin {
  bool open = false;

  late AnimationController _iconController;

  //  final _search = TextEditingController();

  @override
  void initState() {
    _iconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    open = false;
    super.initState();
  }

  @override
  void dispose() {
    _iconController.dispose();
    //  _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        height: 50,
        width: open
            ? widget.isAdmin
                ? width * .65
                : width
            : width * .25,
        decoration: BoxDecoration(
          color: ColorsB.gray800,
          borderRadius: BorderRadius.circular(360),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (open) {
                        setState(() {
                          open = false;
                          _iconController.reverse();
                          widget.searchController.text = '';
                          FocusScope.of(context).unfocus();
                        });
                      }
                    },
                    child: AnimatedIcon(
                      icon: AnimatedIcons.search_ellipsis,
                      color: Colors.white,
                      progress: _iconController,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: width,
                    child: TextField(
                      controller: widget.searchController,
                      onTap: () {
                        if (!open) {
                          setState(() {
                            open = true;
                            _iconController.forward();
                          });
                        }
                      },
                      style: TextStyle(color: Colors.white),
                      onChanged: (_) {
                        //  listKey.currentState!.setState(() {});
                      },
                      decoration: InputDecoration(
                          hintText: 'Search',
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                              color: open
                                  ? Colors.white.withOpacity(.5)
                                  : Colors.white,
                              fontSize: 15.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent),
                    ),
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

class Ribbon extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path()
      ..lineTo(0, size.height)
      ..lineTo(size.width / 2, size.height - size.height * .25)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

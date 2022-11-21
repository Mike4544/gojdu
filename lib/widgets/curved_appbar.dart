import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/pages/news.dart';
import 'package:gojdu/pages/settings.dart';
import 'package:animations/animations.dart';
import '../others/options.dart';
import '../pages/notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CurvedAppbar extends StatefulWidget implements PreferredSizeWidget {
  final List<String> names;
  final int nameIndex;
  final String? accType;
  final int position;
  final Map map;
  final VoidCallback? update;
  final List<PageDescription> descriptions;
  final ValueNotifier notifs;

  CurvedAppbar(
      {Key? key,
      required this.names,
      required this.nameIndex,
      this.accType,
      required this.position,
      required this.map,
      required this.descriptions,
      this.update, required this.notifs})
      : preferredSize = Size.fromHeight(
            screenHeight < 675 ? screenHeight * .175 : screenHeight * .15),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CurvedAppbarState createState() => _CurvedAppbarState();
}

// <---------- Height and width outside of context -------------->
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class _CurvedAppbarState extends State<CurvedAppbar> {
  late bool isActive;

  
  // late var loadBall = getBall();

  final double size = screenHeight * .05 > 40 ? 40 : screenHeight * .05;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //  _controller.dispose();
    super.dispose();
  }

  Widget notifBell({required double size}) {
    if (widget.map['account'] == 'Admin' ||
        widget.map['account'] == 'Teacher') {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NotifPage(notifs: widget.notifs,
                    isAdmin: globalMap['account'] == 'Admin',
                  )));
        },
        child: SizedBox(
          height: size,
          width: size,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Stack(
              children: [
                const Icon(Icons.notifications, color: ColorsB.gray900),
                Visibility(
                  visible: widget.notifs.value > 0,
                  child: Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: size / 2.5 > 10 ? 10 : size / 2.5,
                      height: size / 2.5 > 10 ? 10 : size / 2.5,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    var height2 = height < 675
        ? MediaQuery.of(context).size.height * .175
        : MediaQuery.of(context).size.height * .15;

    return AppBar(
      toolbarHeight: height2,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: ColorsB.yellow500,
      shape: CustomShape(position: widget.position),
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            name(),
            Row(children: [
              ClipRect(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                    width: widget.map['account'] == 'Admin' ||
                            widget.map['account'] == 'Teacher'
                        ? MediaQuery.of(context).size.width * .25
                        : MediaQuery.of(context).size.width * .35,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              widget.map['account'] == 'Teacher'
                                  ? 'Prof. ${widget.map["first_name"]} ${widget.map["last_name"]}'
                                  : '${widget.map["first_name"]} ${widget.map["last_name"]}',
                              style: const TextStyle(
                                  color: ColorsB.gray900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              Misc.scoala,
                              style: const TextStyle(
                                  color: ColorsB.gray900, fontSize: 20),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
              const SizedBox(
                width: 15,
              ),
              ValueListenableBuilder(
                valueListenable: widget.notifs,
                builder: (_ , __, ___) {
                  return notifBell(size: size);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget nameText() {
    return SizedBox(
      width: screenWidth * .4,
      key: ValueKey(widget.nameIndex),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Text(
                widget.names[widget.nameIndex],
                style: const TextStyle(
                    fontSize: 22.5,
                    fontWeight: FontWeight.bold,
                    color: ColorsB.gray900),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            backgroundColor: ColorsB.gray900,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.descriptions[widget.nameIndex].title,
                                    style: TextStyle(
                                        color: ColorsB.yellow500,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.sp),
                                  ),
                                  const Divider(
                                    color: ColorsB.yellow500,
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    widget.descriptions[widget.nameIndex]
                                        .description,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.sp),
                                  ),
                                ],
                              ),
                            ),
                          ));
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: ColorsB.gray900, shape: BoxShape.circle),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.question_mark,
                      color: ColorsB.yellow500,
                      size: 15,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget name() {
    return Row(
      children: [
        Container(
          color: ColorsB.gray900,
          width: 2.5,
          height: 25,
        ),
        const SizedBox(width: 10),
        PageTransitionSwitcher(
          duration: const Duration(milliseconds: 500),
          child: nameText(),
          transitionBuilder: (child, a1, a2) => SharedAxisTransition(
            animation: a1,
            secondaryAnimation: a2,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
            fillColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class PageDescription {
  final String title;
  final String description;

  const PageDescription({required this.title, required this.description});
}

class CustomShape extends ContinuousRectangleBorder {
  final int position;
  //  0 - Left
  //  1 - middle
  //  3 - right

  const CustomShape({required this.position});

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: implement getOuterPath

    Path path = Path();

    switch (position) {
      case 0:
        path.lineTo(0, rect.height);
        path.quadraticBezierTo(20, rect.height - 30, 60, rect.height - 30);
        path.lineTo(rect.width, rect.height - 30);
        path.lineTo(rect.width, 0);
        path.close();
        break;

      case 1:
        path.lineTo(0, rect.height - 30);
        path.lineTo(rect.width, rect.height - 30);
        path.lineTo(rect.width, 0);
        path.close();
        break;

      case 2:
        path.lineTo(0, rect.height - 30);
        //  path.quadraticBezierTo(20, rect.height - 30, 60, rect.height - 30);
        path.lineTo(rect.width - 60, rect.height - 30);
        path.quadraticBezierTo(
            rect.width - 10, rect.height - 30, rect.width, rect.height);
        path.lineTo(rect.width, 0);
        path.close();
        break;
    }

    return path;
  }
}

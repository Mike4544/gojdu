import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/pages/settings.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class MenuTabs extends StatefulWidget {
  List<Widget> pages;
  Map map;
  bool notif;
  VoidCallback update;
  GlobalKey key2;

  MenuTabs(
      {Key? key,
      required this.pages,
      required this.map,
      required this.notif,
      required this.update,
      required this.key2})
      : super(key: key);

  @override
  State<MenuTabs> createState() => _MenuTabsState();
}

late int current_tab;

class _MenuTabsState extends State<MenuTabs> {
  late List<Tab> tabs;

  late List<Widget> switcherPages;

  final _controller = ScrollController();

  void update() {
    setState(() {
      _controller.jumpTo(0);
    });
  }

  bool backInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (current_tab > 0) {
      setState(() {
        current_tab = 0;
      });
      return true;
    }

    return false;
  }

  @override
  void initState() {
    BackButtonInterceptor.add(backInterceptor);

    switcherPages = [];
    current_tab = 0;
    tabs = [
      Tab(
        color: ColorsB.yellow500,
        image: "assets/images/Settings.png",
        description: "Access your account's information.",
        title: "Account Settings",
        index: 1,
        update: update,
        page: widget.pages[0],
      ),
      Tab(
        color: Colors.pink[400],
        image: "assets/images/Map.png",
        description:
            "Navigate simply and quickly through your school.",
        title: "School Map",
        index: 2,
        update: update,
      ),
       Tab(
        color: Colors.teal[200],
        image: "assets/images/orar.png",
        description: "Access your school's timetables with a single tap!",
        title: "Timetables",
        index: 3,
        update: update,
      ),
      Tab(
        color: Colors.amber[700],
        image: "assets/images/Alert.png",
        description: "The place to notify a teacher about any trouble.",
        title: "Report a school problem",
        index: 4,
        update: update,
      ),
      Tab(
        color: ColorsB.gray700,
        image: "assets/images/Calendar.png",
        description:
            "Reserve a hall according to your needs.",
        title: "Book a Hall",
        index: 5,
        update: update,
      ),
      Tab(
        color: Colors.indigoAccent,
        image: "assets/images/Carnet.png",
        description:
            "Use this section to remember important matters.",
        title: "School Notes",
        index: 6,
        update: update,
      ),
      Tab(
        color: Colors.purple[300]!,
        image: "assets/images/Target.png",
        description: "Want to help digitalize education? Tell us your ideas!",
        title: "Improve the App",
        index: 7,
        update: update,
      ),
    ];

    switcherPages.add(tabsColumn());
    switcherPages.addAll(widget.pages);

    super.initState();
  }

  Widget tabsColumn() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 50, 25, 75),
      child: Column(
        key: const ValueKey<int>(0),
        children: tabs,
      ),
    );
  }

  Widget mainPage() {
    return PageTransitionSwitcher(
      transitionBuilder: (child, pAnim, sAnim) => SharedAxisTransition(
          animation: pAnim,
          secondaryAnimation: sAnim,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: ColorsB.gray900,
          child: child),
      child: current_tab == 0
          ? switcherPages[current_tab]
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        current_tab = 0;
                        setState(() {});
                      },
                      icon: const Icon(RoundedTriangle.polygon_1,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tabs[current_tab - 1].title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                switcherPages[current_tab]
              ],
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    BackButtonInterceptor.removeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
          //  height: MediaQuery.of(context).size.height,
          child: mainPage()),
    );
  }
}

class Tab extends StatelessWidget {
  final color;
  final image;
  final title;
  final description;

  final Widget? page;

  final index;

  final VoidCallback update;

  const Tab(
      {Key? key,
      required this.color,
      required this.image,
      required this.title,
      required this.description,
      required this.index,
      required this.update,
      this.page})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sp = MediaQuery.of(context).textScaleFactor;

    var device = MediaQuery.of(context);
    var height = device.size.height;
    var width = device.size.width;

    var borderRadius = height * .075;

    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.all(height * .01),
          child: Container(
            height: height * .25,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  color,
                  Color.alphaBlend(Colors.white.withOpacity(.5), color)
                ], stops: const [
                  .3,
                  1
                ], begin: Alignment.center, end: Alignment.topRight),
                borderRadius: BorderRadius.circular(borderRadius)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: color),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                          flex: 2,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 50,
                                      )
                                    ]),
                              ),
                              Image.asset(image),
                            ],
                          )),
                      Flexible(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.sp,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                description,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15.sp,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      current_tab = index;
                      update();
                    },
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/pages/settings.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/others/rounded_triangle.dart';

class MenuTabs extends StatefulWidget {
  List<Widget> pages;
  Map map;


  MenuTabs({Key? key, required this.pages, required this.map}) : super(key: key);

  @override
  State<MenuTabs> createState() => _MenuTabsState();
}


late int current_tab;

class _MenuTabsState extends State<MenuTabs> {

  late List<Tab> tabs;

  late List<Widget> switcherPages;


  void update() {
    setState(() {

    });
  }

  @override
  void initState() {
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
        description: "Having trouble navigating the school? Worry not! We've got you covered!",
        title: "School Map",
        index: 2,
        update: update,
      ),
      Tab(
        color: ColorsB.gray700,
        image: "assets/images/Calendar.png",
        description: "Do you need to reserve one of our school's halls? This is the place!",
        title: "Book a Hall",
        index: 3,
        update: update,
      ),
      Tab(
        color: Colors.indigoAccent,
        image: "assets/images/Carnet.png",
        description: "Need to remember something important? Use this section to your heart's content.",
        title: "Notes",
        index: 4,
        update: update,
      ),
      Tab(
        color: ColorsB.gray800,
        image: "assets/images/Alert.png",
        description: "The place to notify a teacher about any trouble.",
        title: "Notify a Teacher",
        index: 5,
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

  Widget mainPage(){

    return PageTransitionSwitcher(
      transitionBuilder: (child, pAnim, sAnim) =>
          SharedAxisTransition(animation: pAnim, secondaryAnimation: sAnim, transitionType: SharedAxisTransitionType.horizontal, fillColor: ColorsB.gray900, child: child),
      child: current_tab == 0
          ? switcherPages[current_tab]
          : Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    current_tab = 0;
                    setState(() {

                    });
                  },
                  icon: const Icon(RoundedTriangle.polygon_1, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  tabs[current_tab - 1].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                  ),
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
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Menus', position: 2, map: widget.map,),
        SliverToBoxAdapter(
          child: SizedBox(
              //  height: MediaQuery.of(context).size.height,
              child: mainPage()
          ),

        )
      ],
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


  const Tab({Key? key, required this.color, required this.image, required this.title, required this.description, required this.index, required this.update, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);
    var height = device.size.height;
    var width = device.size.width;


    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Container(
        height: height * .25,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color.alphaBlend(Colors.white.withOpacity(.5), color)],
            stops: const [
              .3, 1
            ],
            begin: Alignment.center,
            end: Alignment.topRight
          ),
          borderRadius: BorderRadius.circular(30)
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: color
                ),

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
                              ]
                            ),
                          ),
                          Image.asset(image),
                        ],
                      )
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 20,
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
                  if(index == 1){
                    Navigator.push(context, PageRouteBuilder(
                        reverseTransitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, a1, a2) => page!,
                        transitionsBuilder: (context, a1, a2, child) =>
                            SharedAxisTransition(
                              animation: a1,
                              secondaryAnimation: a2,
                              transitionType: SharedAxisTransitionType.vertical,
                              fillColor: ColorsB.gray900,
                              child: child,
                            )
                    ));
                  }
                  else {
                    current_tab = index;
                    update();

                  }
                },
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


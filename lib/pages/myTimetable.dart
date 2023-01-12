import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gojdu/widgets/switchPosts.dart';
import 'package:shimmer/shimmer.dart';
import '../others/api.dart';
import '../others/colors.dart';
import 'package:http/http.dart' as http;

import '../others/floor.dart';
import '../others/options.dart';
import '../widgets/floor_selector.dart';
import 'editTables.dart';


class MyTimetable extends StatefulWidget {
  final Map globalMap;
  const MyTimetable({Key? key, required this.globalMap}) : super(key: key);

  @override
  State<MyTimetable> createState() => _MyTimetableState();
}

class _MyTimetableState extends State<MyTimetable> {
  int _currSelected = 0;
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: _currSelected);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          PostsSwitcher(
              index: _currSelected,
              ctrl: _pageController,
              update: (newInt) {
                setState(() {
                  _currSelected = newInt;
                });
              },
              labels: const ['Classes', 'Teachers'],
              icons: const [Icons.class_, Icons.person]),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: PageView(
              controller: _pageController,
              children: [
                ClassTable(globalMap: widget.globalMap),
                TeacherSearch(globalMap: widget.globalMap)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ClassTable extends StatefulWidget {
  final Map globalMap;
  const ClassTable({Key? key, required this.globalMap}) : super(key: key);

  @override
  State<ClassTable> createState() => ClassTableState();
}

class ClassTableState extends State<ClassTable>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  int floorNo = 0;

  List<Floor> classes = [];
  bool mapErrored = false;

  Future getClasses() async {
    try {
      var url =
          Uri.parse('${Misc.link}/${Misc.appName}/getTimetablesClasses.php');

      //  TODO: FIX THIS SOMEHOWWWW

      final response =
          await http.post(url, body: {}).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata.toString());
        if (jsondata['0']["error"]) {
        } else {
          for (int i = 1; i <= jsondata.length; i++) {
            //  //m_debugPrint(jsondata['$i']);
            classes.add(Floor(
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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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

  late Future _getClasses = getClasses().then((value) => placeMaps());

  // <---------- Function to switch the floor (placeholder) -------------------->
  void _mapUpdate(int newFloor) {
    setState(() {
      floorNo = newFloor;
    });
  }

  void updateThis(List<Floor> newFloors) {
    setState(() {
      classes = newFloors.toList();
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

    for (int i = 0; i < classes.length; i++) {
      maps.add(GestureDetector(
        key: Key('$i'),
        child: Image.network(
          "${Misc.link}/${Misc.appName}/timetables/${classes[i].file}",
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
                            "${Misc.link}/${Misc.appName}/timetables/${classes[i].file}",
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
    if (classes.isEmpty) {
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
        if (classes.isNotEmpty) {
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
                    DropdownSelector(update: _mapUpdate, floors: classes),
                    widget.globalMap['account'] == "Admin"
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
                                              floors: classes,
                                              type: 'classes',
                                              update: updateThis,
                                            ),
                                          )));
                            },
                            icon: const Icon(Icons.edit,
                                size: 20, color: Colors.white),
                            label: const Text(
                              "Edit timetables",
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
                visible: widget.globalMap['account'] == "Admin" ||
                    widget.globalMap['account'] == "Teacher" || widget.globalMap['account'] == "C. Elevilor",
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
                                        floors: classes,
                                        update: updateThis,
                                        type: 'classes'),
                                  )));
                    },
                    icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                    label: const Text(
                      "Add classes",
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
                classes.clear();

                setState(() {
                  isLoading = true;
                  mapErrored = false;
                });

                await getClasses();

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
    super.build(context);
    return FutureBuilder(
        future: _getClasses,
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

class TeacherSearch extends StatefulWidget {
  final Map globalMap;
  const TeacherSearch({Key? key, required this.globalMap}) : super(key: key);

  @override
  State<TeacherSearch> createState() => _TeacherSearchState();
}

class _TeacherSearchState extends State<TeacherSearch>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  final subtitleStyle = TextStyle(color: Colors.white, fontSize: 20.sp);

  List<Floor> teachers = [];
  bool mapErrored = false;

  void updateThis(List<Floor> newFloors) {
    setState(() {
      teachers = newFloors.toList();
      //  placeMaps();
    });
  }

  Future getTeachers() async {
    try {
      var url =
          Uri.parse('${Misc.link}/${Misc.appName}/getTimetablesTeachers.php');

      //  TODO: FIX THIS SOMEHOWWWW

      final response =
          await http.post(url, body: {}).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata.toString());
        if (jsondata['0']["error"]) {
        } else {
          for (int i = 1; i <= jsondata.length; i++) {
            //  //m_debugPrint(jsondata['$i']);
            teachers.add(Floor(
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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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

  late Future _getTeachers = getTeachers();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
        padding: const EdgeInsets.fromLTRB(25, 50, 25, 100),
        child: FutureBuilder(
            future: _getTeachers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),
                  ),
                );
              } else {
                return Column(
                  children: [
                    Visibility(
                        visible: widget.globalMap['account'] == 'Admin' ||
                            widget.globalMap['account'] == 'Teacher' || widget.globalMap['account'] == 'C. Elevilor',
                        child: TextButton.icon(
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
                                              floors: teachers,
                                              type: 'teachers',
                                              update: updateThis,
                                            ),
                                          )));
                            },
                            icon: const Icon(Icons.edit,
                                size: 20, color: Colors.white),
                            label: const Text(
                              "Edit timetables",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: ColorsB.gray800,
                            ))),
                    const SizedBox(
                      height: 25,
                    ),
                    Text('Input your teacher\'s name in the field below.',
                        style: subtitleStyle),
                    const SizedBox(height: 20),
                    SearchBar(searchTerms: teachers)
                  ],
                );
              }
            }));
  }
}

class SearchBar extends StatefulWidget {
  final List<Floor> searchTerms;
  const SearchBar({Key? key, required this.searchTerms}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: (t) {
            setState(() {});
          },
          style: const TextStyle(color: Colors.white),
          //  Get rid of the autocorrect
                      autocorrect: false,
                      //  Get rid of suggestions
                      enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Teacher\'s name',
            labelStyle: const TextStyle(
                color: Colors.white12, fontWeight: FontWeight.bold),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            filled: true,
            fillColor: ColorsB.gray800,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Visibility(
            visible: _controller.text.isNotEmpty ||
                widget.searchTerms.contains(_controller.text),
            child: Container(
              constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height * .25),
              decoration: BoxDecoration(
                  color: ColorsB.gray800,
                  borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: widget.searchTerms.map((e) {
                      if (e.floor
                          .toLowerCase()
                          .contains(_controller.text.toLowerCase())) {
                        return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.floor,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Icon(
                                          Icons.center_focus_strong_rounded,
                                          color: Colors.white)
                                    ],
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
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
                                                            "${Misc.link}/${Misc.appName}/timetables/${e.file}",
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }

                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation(
                                                                      ColorsB
                                                                          .yellow500),
                                                            ),
                                                          );
                                                        })),
                                                  ),
                                                  Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: IconButton(
                                                          tooltip: 'Close',
                                                          splashRadius: 25,
                                                          icon: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }))
                                                ])));
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ));
                      } else {
                        return const Visibility(
                          visible: false,
                          child: SizedBox(
                            height: 0,
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

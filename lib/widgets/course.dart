//  Import material, colors.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/options.dart';
import 'package:gojdu/widgets/lazyBuilder.dart';
import 'package:gojdu/widgets/post.dart';
import 'package:gojdu/widgets/searchBar.dart';
import 'package:gojdu/widgets/textPP.dart';
import '../others/api.dart';
import '../others/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//  Import http as http and dart:conver
import 'package:http/http.dart' as http;
import 'dart:convert';

//  Import mFiterChip
import 'back_navbar.dart';
import 'filters.dart';

class CoursesPage extends StatefulWidget {
  final Map globalMap;
  const CoursesPage({Key? key, required this.globalMap}) : super(key: key);

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  void initState() {
    super.initState();

    lazyController = ScrollController()..addListener(lazyLoadCallback);
  }

  List<CourseContainer> courses = [];

  Future<int> loadCourses() async {
    //  opportunities.clear();
    lastMaxOpportunities = maxScrollCountOpportunities;

    //  Maybe rework this a bit.

    try {
      var url =
          Uri.parse('${Misc.link}/${Misc.appName}/coursesAPI/loadCourses.php');
      final response =
          await http.post(url, body: {"lastID": '$lastID', 'turns': '$turns'});
      m_debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata.toString());

        if (jsondata[0]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata[0]["success"]) {
            for (int i = 1; i < jsondata.length; i++) {
              courses
                  .add(CourseContainer.fromJson(jsondata[i], widget.globalMap));
            }

            //  Add the search terms
            maxScrollCountOpportunities += turns;
            lastID = courses.last.id;

            //  m_debugPrint(events);
          } else {
            ////m_debugPrint(jsondata[0]["message"]);
          }
        }
      }
    } catch (e) {
      throw Future.error(e.toString());
    }

    return 0;
  }

  late Future _getCourses = loadCourses();

  late ScrollController lazyController;

  int lastMaxOpportunities = Misc.lastMax;
  int maxScrollCountOpportunities = Misc.maxScrollCount;
  int lastID = Misc.INT_MAX;
  int turns = Misc.turns;

  void lazyLoadCallback() async {
    if (lazyController.position.extentAfter == 0 &&
        lastMaxOpportunities < maxScrollCountOpportunities) {
      m_debugPrint('Haveth reached the end');

      await loadCourses();

      setState(() {});
    }
  }

  Future<void> refresh() async {
    courses.clear();

    setState(() {
      maxScrollCountOpportunities = turns;
      lastMaxOpportunities = -1;

      lastID = Misc.INT_MAX;

      _getCourses = loadCourses();
      //  setState(() {});
      //  widget.future = widget.futureFunction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SearchBar(
        searchType: SearchType.courses,
        filters: [
          "Biology",
          "Business",
          "Finance",
          "Health&Fitness",
          "Literature",
          "Maths",
          "Physics",
          "Psychology",
          "Technology"
        ].map((e) => mFilterChip(label: e, color: ColorsB.gray800)).toList(),
        adminButton: const SizedBox(),
      ),
      Expanded(
        child: LazyBuilder(
          future: _getCourses,
          widgetList: courses,
          lastID: lastID,
          lastMax: lastMaxOpportunities,
          turns: turns,
          maxScrollCount: maxScrollCountOpportunities,
          refresh: refresh,
          scrollController: lazyController,
        ),
      )
    ]);
  }
}

class CourseContainer extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? link;
  final double rating;
  final String topic;
  final Map globalMap;
  const CourseContainer(
      {Key? key,
      required this.title,
      required this.id,
      required this.description,
      this.image,
      this.link,
      required this.topic,
      required this.rating,
      required this.globalMap})
      : super(key: key);

  Image courseCover() => image != null
      ? Image.network(image!)
      : Image.asset(
          'assets/images/courseTypes/${topic.toLowerCase()}-template.jpg');

  static CourseContainer fromJson(Map json, Map globalMap) => CourseContainer(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        image: json['image'],
        link: json['link'],
        topic: json['topic'],
        rating: json['rating'] * 1.0,
        globalMap: globalMap,
      );

  @override
  Widget build(BuildContext context) {
    precacheImage(courseCover().image, context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
          height: MediaQuery.of(context).size.height * .4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                  image: courseCover().image,
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                      Colors.black54, BlendMode.darken))),
          child: Stack(alignment: Alignment.center, children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BigNewsContainer(
                                title: title,
                                description: description,
                                link: link,
                              )));
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.sp),
                    ),
                    Text(
                        description.length > 50
                            ? '${description.substring(0, 50)}...'
                            : description,
                        style: TextStyle(color: Colors.white, fontSize: 15.sp)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: globalMap['id'] >= 0,
                          child: StarBar(
                            courseID: id,
                            globalMap: globalMap,
                            initialRating: rating,
                          ),
                        ),
                        mFilterChip(
                          label: topic,
                          color: ColorsB.gray800,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ])),
    );
  }
}

class BigNewsContainer extends StatefulWidget {
  final String title;
  final String description;
  final Color? color;
  final String? imageString;
  final String? link;

  const BigNewsContainer({
    Key? key,
    this.link,
    required this.title,
    required this.description,
    this.color = ColorsB.yellow500,
    this.imageString,
  }) : super(key: key);

  @override
  State<BigNewsContainer> createState() => _BigNewsContainerState();
}

class _BigNewsContainerState extends State<BigNewsContainer> {
  bool get _isCollapsed {
    return _controller.position.pixels >= screenHeight * .65 &&
        _controller.hasClients;
  }

  final ScrollController _controller = ScrollController();

  bool visible = false;

  @override
  void initState() {
    _controller.addListener(() {
      _isCollapsed ? visible = true : visible = false;

      //  m_debugPrint(_controller.position.pixels);

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

    BoxDecoration wImage = BoxDecoration(color: widget.color);

    //m_debugPrint(imageLink);

    return GestureDetector(
      onTap: (widget.imageString == 'null' ||
              widget.imageString == '' ||
              widget.imageString == null)
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
                              imageUrl: widget.imageString!,
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
        decoration: (widget.imageString == 'null' ||
                widget.imageString == '' ||
                widget.imageString == null)
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
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  child: Stack(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextPP(
                                string: widget.description,
                                onHashtagClick: (tag) {
                                  Misc.defSearch(
                                      tag, SearchType.courses, context);
                                },
                                onLinkClick: Misc.openUrl,
                                onPhoneClick: Misc.openPhone,
                              ),
                              const Spacer()
                            ],
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Visibility(
                          visible: widget.link != null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton.icon(
                              onPressed: () {
                                Misc.openUrl(widget.link!);
                              },
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Open course link',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  elevation: 10,
                                  shadowColor: Colors.black54,
                                  backgroundColor: ColorsB.gray800,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }
}

class StarBar extends StatefulWidget {
  final int courseID;
  final double initialRating;
  final Map globalMap;
  const StarBar(
      {Key? key,
      required this.initialRating,
      required this.globalMap,
      required this.courseID})
      : super(key: key);

  @override
  State<StarBar> createState() => _StarBarState();
}

class _StarBarState extends State<StarBar> {
  Future<bool> rate(double rating) async {
    //  This will update the rating in the database TODO

    var link = "${Misc.link}/${Misc.appName}/coursesAPI/rate.php";

    //  The table columns are: id, person_id, courseID and rating
    var data = {
      'person_id': widget.globalMap['id'].toString(),
      'school_name': Misc.appName,
      'course_id': widget.courseID.toString(),
      'rating': rating.toString()
    };

    try {
      var response = await http.post(Uri.parse(link), body: data);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        m_debugPrint(data);

        return data['success'];
      }
    } catch (e, s) {
      m_debugPrint(e);
      m_debugPrint(s);
      return false;
    }

    return false;
  }

  Widget ratingContainer() => Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.all(10),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            '${widget.initialRating}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RatingBar.builder(
              initialRating: widget.initialRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              glowColor: Colors.amber,
              unratedColor: Colors.white24,
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (nRating) async {
                if (await rate(nRating)) {
                  // Show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Rating updated to $nRating',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: ColorsB.gray800,
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ratingContainer(),
            )
          ],
        ),
      ),
    );
  }
}

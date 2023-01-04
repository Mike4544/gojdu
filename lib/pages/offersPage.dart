import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gojdu/pages/addOffer.dart';
import 'package:gojdu/pages/news.dart';
import 'package:gojdu/pages/opportunities.dart';
import 'package:gojdu/widgets/filters.dart';
import 'package:gojdu/widgets/lazyBuilder.dart';
import 'package:gojdu/widgets/searchBar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/api.dart';
import '../others/colors.dart';
import '../widgets/back_navbar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

import 'package:gojdu/others/options.dart';

import '../widgets/textPP.dart';

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class OffersPage extends StatefulWidget {
  final Map globalMap;

  const OffersPage({Key? key, required this.globalMap}) : super(key: key);

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  late List<OfferContainer> offers;

  int lastMaxOffers = -1; //  INT MAX
  int maxScrollCountOffers = 10;
  int turnsOffers = 10;
  int lastIDOffers = Misc.INT_MAX;

  Future<void> refresh() async {
    offers.clear();

    setState(() {
      maxScrollCountOffers = turnsOffers;
      lastMaxOffers = -1;

      lastIDOffers = Misc.INT_MAX;

      _getOffers = loadOffers();
      setState(() {});
      //  widget.future = widget.futureFunction;
    });
  }

  void lazyLoadCallback() async {
    if (lazyController.position.extentAfter == 0 &&
        lastMaxOffers < maxScrollCountOffers) {
      m_debugPrint('Haveth reached the end');

      await loadOffers();

      setState(() {});
    }
  }

  late ScrollController lazyController;

  Future<int> loadOffers() async {
    //  offers.clear();
    lastMaxOffers = maxScrollCountOffers;
    //  Maybe rework this a bit.

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/getOffers.php');
      final response = await http.post(url, body: {
        "lastID": "$lastIDOffers",
        "turns": "$turnsOffers",
        "userID": "${widget.globalMap['id']}",
      });
      //  m_debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata.toString());

        if (jsondata[0]["error"]) {
          m_debugPrint('Error');

          // setState(() {
          //   //nameError = jsondata["message"];
          // });
        } else {
          if (jsondata[0]["success"]) {
            for (int i = 1; i < jsondata.length; i++) {
              ////m_debugPrint(globalMap['id']);

              offers.add(
                  OfferContainer.fromJson(jsondata[i], globalMap, () async {
                await deleteEvent(jsondata[i]['id'], i - 1);
              }));
            }
            maxScrollCountOffers += turnsOffers;
            lastIDOffers = offers.last.id;

            //  m_debugPrint(events);
          } else {
            ////m_debugPrint(jsondata[0]["message"]);

          }
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
      throw Future.error(e.toString());
    }

    return 0;
  }

  // Future _refresh() async {
  //   offers.clear();

  //   _getOffers = loadOffers();

  //   setState(() {});
  // }

  Future<void> deleteEvent(int Id, int index) async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/deleteOffer.php');
      final response = await http.post(url, body: {"id": Id.toString()});

      m_debugPrint(Id.toString());
      m_debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        m_debugPrint(response.body);

        var jsondata = json.decode(response.body);
        //  //m_debugPrint(jsondata.toString());

        if (jsondata['error']) {
          m_debugPrint('Errored');

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

          offers.removeAt(index);
        }
      } else {
        m_debugPrint("Deletion failed.");
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

      m_debugPrint(e.toString());
    }
  }

  Widget _offersList() {
    return LazyBuilder(
        future: _getOffers,
        widgetList: offers,
        lastID: lastIDOffers,
        lastMax: lastMaxOffers,
        maxScrollCount: maxScrollCountOffers,
        refresh: refresh,
        scrollController: lazyController,
        turns: turnsOffers);
  }

  late Future _getOffers = loadOffers();

  final searchEditor = TextEditingController();

  @override
  void initState() {
    offers = [];
    lazyController = ScrollController()..addListener(lazyLoadCallback);
    super.initState();
  }

  @override
  void dispose() {
    searchEditor.dispose();
    super.dispose();
  }

  Widget adminButton() => Visibility(
        visible: widget.globalMap['account'] == 'Admin' ||
            widget.globalMap['account'] == 'Teacher' || widget.globalMap['account'] == 'C. Elevilor',
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: ColorsB.gray800,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddOffer(gMap: widget.globalMap)));
          },
          mini: true,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          StatefulBuilder(
            builder: (context, setThisState) => const Background(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  filters: const [
                    mFilterChip(label: "Trends", color: ColorsB.yellow500),
                    mFilterChip(label: "Offers", color: Colors.blueAccent),
                  ],
                  searchType: SearchType.offers,
                  adminButton: adminButton(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(child: _offersList())
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OfferContainer extends StatefulWidget {
  final int id;
  final int owner_id;
  final Map globalMap;
  final String s_color;
  final String compName;
  final String logoLink;
  final String gmaps_link;
  final String? headerImageLink;
  final String discount;
  final String smallDescription;
  final String fullDescription;
  final String owner;
  final DateTime date;
  final Function delete;

  int likes;
  bool liked;
  bool disliked;

  OfferContainer(
      {Key? key,
      required this.id,
      required this.globalMap,
      required this.s_color,
      required this.compName,
      required this.logoLink,
      required this.gmaps_link,
      this.headerImageLink,
      required this.discount,
      required this.owner,
      required this.date,
      required this.delete,
      required this.smallDescription,
      required this.fullDescription,
      required this.likes,
      required this.liked,
      required this.disliked,
      required this.owner_id})
      : super(key: key);

  static OfferContainer fromJson(
      Map<String, dynamic> jsondata, Map globalMap, Function delete) {
    int id = jsondata["id"];
    int oid = jsondata['ownerID'];
    String discount = jsondata["discount"].toString();
    String short = jsondata["short"].toString();
    String long = jsondata["long"].toString();
    String owner = jsondata["owner"].toString();
    String company = jsondata["company"].toString();
    String location = jsondata["location"].toString();
    String mapsLink = jsondata["mapsLink"].toString();
    DateTime date = DateTime.parse(jsondata["dateTime"]);
    String Imlink = jsondata["link"].toString();
    String logo = jsondata["logo"].toString();
    String color = jsondata["color"].toString();

    return OfferContainer(
      id: id,
      owner_id: oid,
      compName: company,
      date: date,
      delete: delete,
      discount: discount,
      fullDescription: long,
      smallDescription: short,
      globalMap: globalMap,
      gmaps_link: mapsLink,
      headerImageLink: Imlink,
      logoLink: logo,
      owner: owner,
      s_color: color,
      likes: jsondata['likes'] ?? 0,
      liked: jsondata['liked'] != null && jsondata['liked'] > 0,
      disliked: jsondata['disliked'] != null && jsondata['disliked'] > 0,
    );
  }

  @override
  State<OfferContainer> createState() => _OfferContainerState();
}

class _OfferContainerState extends State<OfferContainer> {
  final StreamController<int?> _controllerLikes = StreamController<int?>();
  final StreamController<bool> _controllerLBool = StreamController<bool>();
  final StreamController<bool> _controllerDBool = StreamController<bool>();

  @override
  initState() {
    super.initState();
    _controllerLikes.stream.listen((event) {
      setState(() {
        widget.likes = event!;
      });
    });
    _controllerLBool.stream.listen((event) {
      setState(() {
        widget.liked = event;
      });
    });
    _controllerDBool.stream.listen((event) {
      setState(() {
        widget.disliked = event;
      });
    });
  }

  @override
  Future<void> like(int id, int uid) async {
    //m_debugPrint(ids);

    if (widget.disliked == true) {
      undislike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes + 1;
      widget.liked = true;

      widget.disliked = false;
      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
    //m_debugPrint(ids);

    setState(() {
      widget.likes = widget.likes - 1;
      widget.liked = false;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
    //m_debugPrint(ids);

    if (widget.liked == true) {
      unlike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes - 1;
      widget.liked = false;

      widget.disliked = true;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'DISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          m_debugPrint(id.toString());
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
    //m_debugPrint(ids);

    setState(() {
      widget.likes = widget.likes + 1;

      widget.disliked = false;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNDISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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

  Widget build(BuildContext context) {
    Widget _deleteButton() => Visibility(
          visible: widget.globalMap['account'] == 'Admin',
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
              size: screenHeight * .05,
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
                            'Are you sure you want delete this event?',
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await widget.delete();

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
                                  borderRadius: BorderRadius.circular(30),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: ColorsB.gray800,
                                      borderRadius: BorderRadius.circular(30),
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
        );

    Widget actionBar() => Visibility(
          visible: widget.globalMap['verification'] != "Pending",
          child: Container(
            height: 50,
            constraints: BoxConstraints(maxWidth: screenWidth * .5),
            decoration: BoxDecoration(
                color: ColorsB.gray800,
                borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: FittedBox(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _deleteButton(),
                      Row(children: [
                        //   Like and dislike
                        IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            Icons.thumb_up,
                            color: widget.liked == true
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 25,
                          ),
                          onPressed: () {
                            widget.liked == true
                                ? unlike(widget.id, widget.globalMap['id'])
                                : like(widget.id, widget.globalMap['id']);
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
                            color: widget.disliked == true
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 25,
                          ),
                          onPressed: () {
                            widget.disliked == true
                                ? undislike(widget.id, widget.globalMap['id'])
                                : dislike(widget.id, widget.globalMap['id']);
                            //
                          },
                        ),
                      ])
                    ]),
              ),
            ),
          ),
        );

    m_debugPrint(widget.date.toString());

    final titleStyle = TextStyle(
        color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold);

    final subtitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 15.sp,
    );

    final numberStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50.sp);

    var tempcolor = widget.s_color.split('(0x')[1].split(')')[0];
    int value = int.parse(tempcolor, radix: 16);
    Color color = Color(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              clipBehavior: Clip.hardEdge,
              height: screenHeight * .3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * .075)),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * .075),
                        border: Border.all(
                            color: Color.alphaBlend(color, Colors.white)
                                .withOpacity(.5)),
                        gradient: LinearGradient(
                            colors: [
                              color.withOpacity(.5),
                              color.withOpacity(.05)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            stops: const [0, .75]),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: screenHeight * .05,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.logoLink,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(widget.compName, style: titleStyle),
                                  const Spacer(),
                                  Icon(
                                    Icons.center_focus_strong_rounded,
                                    color: Colors.white.withOpacity(.5),
                                    size: screenHeight * .05,
                                  )
                                ],
                              ),
                              Divider(
                                color: Colors.white.withOpacity(.5),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: widget.discount.length < 10
                                          ? FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                widget.discount,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              widget.discount,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.sp),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        widget.smallDescription,
                                        style: subtitleStyle,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              BetterChip(
                                width: screenWidth * .5,
                                height: screenHeight * .05,
                                icon: Icons.timer,
                                label:
                                    'Available until ${DateFormat('dd.MM.yyyy').format(widget.date)}',
                                isGlass: true,
                                bgColor: Colors.pinkAccent,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BigNewsContainer(
                                  likes: widget.likes,
                                  liked: widget.liked,
                                  id: widget.id,
                                  globalMap: widget.globalMap,
                                  disliked: widget.disliked,
                                  contrL: _controllerLikes,
                                  contrLB: _controllerLBool,
                                  contrDB: _controllerDBool,
                                  title: widget.compName,
                                  description: widget.fullDescription,
                                  date: DateFormat('dd.MM.yyyy')
                                      .format(widget.date),
                                  gMapsLink: widget.gmaps_link,
                                  color: color,
                                  logoLink: widget.logoLink,
                                  imageString:
                                      widget.headerImageLink.toString(),
                                )));
                      },
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 20),
          actionBar()
        ],
      ),
    );
  }
}

class BigNewsContainer extends StatefulWidget {
  final String title;
  final String logoLink;
  final String description;
  final Color? color;
  final String date;
  final String? imageString;
  final String? gMapsLink;

  StreamController<int?>? contrL;
  StreamController<bool?>? contrLB;
  StreamController<bool?>? contrDB;

  int likes;
  bool liked;
  bool disliked;

  final int id;
  final Map globalMap;

  BigNewsContainer(
      {Key? key,
      this.gMapsLink,
      required this.title,
      required this.description,
      this.color = ColorsB.yellow500,
      this.imageString,
      required this.date,
      required this.likes,
      required this.liked,
      required this.disliked,
      required this.logoLink,
      this.contrL,
      this.contrLB,
      this.contrDB,
      required this.id,
      required this.globalMap})
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

  Future<void> like(int id, int uid) async {
    //m_debugPrint(ids);

    if (widget.disliked == true) {
      undislike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes + 1;
      widget.liked = true;

      widget.disliked = false;

      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.liked);
      widget.contrDB!.add(widget.disliked);
      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
    //m_debugPrint(ids);

    setState(() {
      widget.likes = widget.likes - 1;
      widget.liked = false;

      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.liked);

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
    //m_debugPrint(ids);

    if (widget.liked == true) {
      unlike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes - 1;
      widget.liked = false;

      widget.disliked = true;

      widget.contrL!.add(widget.likes);
      widget.contrLB!.add(widget.liked);
      widget.contrDB!.add(widget.disliked);

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'DISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          m_debugPrint(id.toString());
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
    //m_debugPrint(ids);

    setState(() {
      widget.likes = widget.likes + 1;

      widget.disliked = false;

      widget.contrL!.add(widget.likes);
      widget.contrDB!.add(widget.disliked);

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/offersAPI/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNDISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //m_debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //m_debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      m_debugPrint(e.toString());
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
                    height: 150,
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
                height: 150,
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
                      IconButton(
                        splashRadius: 20,
                        icon: Icon(
                          Icons.thumb_up,
                          color: widget.liked == true
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: 25,
                        ),
                        onPressed: () {
                          widget.liked == true
                              ? unlike(widget.id, globalMap['id'])
                              : like(widget.id, globalMap['id']);
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
                          color: widget.disliked == true
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: 25,
                        ),
                        onPressed: () {
                          widget.disliked == true
                              ? undislike(widget.id, globalMap['id'])
                              : dislike(widget.id, globalMap['id']);
                          //
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

  bool visible = false;

  @override
  void initState() {
    m_debugPrint(avatarImg);

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

    BoxDecoration wImage = BoxDecoration(
      image: DecorationImage(
          image: CachedNetworkImageProvider(widget.imageString!),
          fit: BoxFit.cover),
    );

    //m_debugPrint(imageLink);
    m_debugPrint(widget.imageString);

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
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SizedBox(
                                        height: screenHeight * .05,
                                        width: screenHeight * .05,
                                        child: Image.network(widget.logoLink),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      widget.title,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: ThemeData
                                                      .estimateBrightnessForColor(
                                                          widget.color!) ==
                                                  Brightness.light
                                              ? ColorsB.gray900
                                              : Colors.white,
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
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
                                  m_debugPrint('Can\'t do it chief');
                                }
                              },
                              child: Row(
                                children: [
                                  Chip(
                                      backgroundColor: Colors.grey[200],
                                      avatar: const Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      label: const Text("Location")),
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
                              label: Text(widget.date)),
                        ),
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
        body: Stack(alignment: Alignment.center, children: [
          Scrollbar(
            child: CustomScrollView(
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
                  child: SizedBox(
                    child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextPP(
                          string: widget.description,
                          onHashtagClick: (tag) {
                            Misc.defSearch(tag, SearchType.offers, context);
                          },
                          onLinkClick: Misc.openUrl,
                          onPhoneClick: Misc.openPhone,
                        )),
                  ),
                )
              ],
            ),
          ),
          _likeBar()
        ]));
  }
}

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  late double blur1, blur2, blur3;

  double lastBlur1 = 5, lastBlur2 = 3, lastBlur3 = 1;

  late AccelerometerEvent _parallaxValues;

  static const double _backConstant = 2.5;
  static const double _midConstant = 3.5;
  static const double _frontConstant = 6;

  //  static const sensitivity = 4;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _parallaxValues = AccelerometerEvent(0, 0, 0);

    blur1 = 0;
    blur2 = 0;
    blur3 = 0;

    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      _getNewValues();
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      accelerometerEvents.listen((event) {
        _parallaxValues = event;

        //m_debugPrint(event);

        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    //  _timer.cancel();
    super.dispose();
  }

  void _getNewValues() {
    lastBlur1 = blur1;
    lastBlur2 = blur2;
    lastBlur3 = blur3;

    blur1 = math.Random().nextDouble() * 5;
    blur2 = math.Random().nextDouble() * 12;
    blur3 = math.Random().nextDouble() * 5;

    //  m_debugPrint(c11);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: lastBlur1, end: blur1),
          duration: const Duration(seconds: 5),
          curve: Curves.ease,
          builder: (_, value, ___) => AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              top: screenHeight * .025 + -(_parallaxValues.y * _backConstant),
              right: 25 + -_parallaxValues.x * _backConstant,
              child: ClipRect(
                child: ClipOval(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: value,
                      sigmaY: value,
                    ),
                    child: Container(
                      width: screenWidth * .5,
                      height: screenWidth * .5,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        gradient: LinearGradient(
                            colors: [
                              Color(0xff8A2387),
                              Color(0xffE94057),
                              Color(0xffF27121)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight),
                      ),
                    ),
                  ),
                ),
              )),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: lastBlur2, end: blur2),
          duration: const Duration(seconds: 5),
          curve: Curves.ease,
          builder: (_, value, ___) => AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              top: screenHeight * .3 + -(_parallaxValues.y * _midConstant),
              left: 25 + _parallaxValues.x * _midConstant,
              child: ClipRect(
                child: ClipOval(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaY: value, sigmaX: value),
                    child: Container(
                      width: screenWidth * .15,
                      height: screenWidth * .15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          gradient: LinearGradient(
                              colors: [
                                Color(0xff8A2387),
                                Color(0xffE94057),
                                Color(0xffF27121)
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight),
                          shape: BoxShape.circle),
                    ),
                  ),
                ),
              )),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .4,
            child: Image.asset(
              'assets/images/abstractFire.png',
              frameBuilder: (BuildContext context, Widget child, int? frame,
                  bool wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  child: child,
                );
              },
            ),
          ),
        ),
        AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            bottom: screenHeight * .025 + _parallaxValues.y * _frontConstant,
            left: _parallaxValues.x * _frontConstant,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: lastBlur3, end: blur3),
              duration: const Duration(seconds: 5),
              curve: Curves.ease,
              builder: (_, value, __) => ClipRect(
                child: ClipOval(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaY: value, sigmaX: value),
                    child: Container(
                      width: screenWidth * .5,
                      height: screenWidth * .5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        gradient: LinearGradient(
                            colors: [
                              Color(0xff8A2387),
                              Color(0xffE94057),
                              Color(0xffF27121)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight),
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

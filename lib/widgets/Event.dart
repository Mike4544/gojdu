import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/widgets/profilePics.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/api.dart';
import '../others/colors.dart';

import 'package:http/http.dart' as http;

import 'back_navbar.dart';

import 'package:gojdu/others/options.dart';

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class Event extends StatelessWidget {
  final Map gMap;
  final int? id;
  final String title;
  final String body;
  final String owner;
  final int ownerID;
  final String location;
  final DateTime date;
  final String link;
  final Function delete;
  final String maps_link;
  final BuildContext Context;

  const Event({
    Key? key,
    this.id,
    required this.gMap,
    required this.title,
    required this.body,
    required this.owner,
    required this.ownerID,
    required this.location,
    required this.date,
    required this.link,
    required this.delete,
    required this.Context,
    required this.maps_link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var avatarImg = '${Misc.link}/${Misc.appName}/profiles/$ownerID.jpg';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: screenHeight * .3,
        width: screenWidth,
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                      colors: [
                        Colors.indigoAccent.withOpacity(.5),
                        Colors.indigoAccent.withOpacity(.1)
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: const [0, .75]),
                  border:
                      Border.all(color: Colors.indigoAccent.withOpacity(.25))),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: screenWidth,
                        child: Text(
                          title,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: title.length > 10 ? 20 : 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Chip(
                                label: Text(
                                    '${owner.split(' ').first} ${owner.split(' ').last[0]}.'),
                                avatar: ProfilePicture(
                                  url: avatarImg,
                                  userName: owner,
                                ),
                              )),
                              BetterChip(
                                  icon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: ColorsB.gray900,
                                  ),
                                  label: DateFormat("dd/MM/yyyy").format(date),
                                  isGlass: true)
                            ],
                          ),
                          BetterChip(
                            icon: const Icon(
                              Icons.location_on_outlined,
                              color: ColorsB.gray900,
                            ),
                            label: location.split(',')[0],
                            isGlass: true,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BigNewsContainer(
                          title: title,
                          description: body,
                          author: owner,
                          ownerID: ownerID,
                          date: DateFormat("dd/MM/yyyy").format(date),
                          location: location,
                          imageString: link,
                          mapsLink: maps_link)));
                },
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Visibility(
              visible: gMap['account'] == 'Admin' || gMap['id'] == ownerID,
              child: Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
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
                                        borderRadius: BorderRadius.circular(30),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            color: ColorsB.yellow500,
                                            borderRadius:
                                                BorderRadius.circular(30),
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
                                            borderRadius:
                                                BorderRadius.circular(30),
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
    );
  }
}

class BetterChip extends StatelessWidget {
  final double height;
  final double width;
  final Color bgColor;
  final String label;
  final bool isGlass;
  final Widget icon;
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
      //  height: height,
      // constraints: BoxConstraints(maxWidth: width),
      decoration: isGlass ? glassDecoration : normalDecoration,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: FittedBox(fit: BoxFit.scaleDown, child: icon),
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FittedBox(
                  child: Text(
                    label.length > 15 ? '${label.substring(0, 15)}...' : label,
                    style: const TextStyle(color: Colors.white),
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
                          color:
                              ThemeData.estimateBrightnessForColor(bgColor) ==
                                      Brightness.light
                                  ? ColorsB.gray900
                                  : Colors.white,
                        ),
                      ),
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BigNewsContainer extends StatefulWidget {
  final String title;
  final String description;
  final Color? color;
  final String author;
  final int ownerID;
  final String date;
  final String location;
  final String? imageString;
  final String mapsLink;

  const BigNewsContainer(
      {Key? key,
      required this.title,
      required this.description,
      this.color = ColorsB.yellow500,
      required this.author,
      required this.ownerID,
      this.imageString,
      required this.date,
      required this.location,
      required this.mapsLink})
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
    // TODO: implement initState

    avatarImg = '${Misc.link}/${Misc.appName}/profiles/${widget.ownerID}.jpg';
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
    //m_debugPrint(imageLink);

    BoxDecoration woImage = BoxDecoration(color: widget.color);

    BoxDecoration wImage = BoxDecoration(
      image: DecorationImage(
          image: CachedNetworkImageProvider(widget.imageString!),
          fit: BoxFit.cover),
    );

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
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Chip(
                          backgroundColor: ColorsB.gray200,
                          avatar: ProfilePicture(
                            url: avatarImg,
                            userName: widget.author,
                          ),
                          label: Text(
                              '${widget.author.split(' ').first} ${widget.author.split(' ').last[0]}.'),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            //  m_debugPrint(widget.mapsLink);
                            if (await canLaunchUrl(
                                Uri.parse(widget.mapsLink))) {
                              await launchUrl(Uri.parse(widget.mapsLink));
                            } else {
                              m_debugPrint('Can\'t do it chief');
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                backgroundColor: ColorsB.gray200,
                                label: Text(widget.location),
                                avatar: const Icon(Icons.location_on_outlined),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Visibility(
                                visible: widget.mapsLink.isNotEmpty,
                                child: Text(
                                  'Open in Google Maps',
                                  style: TextStyle(
                                      color:
                                          ThemeData.estimateBrightnessForColor(
                                                      widget.color!) ==
                                                  Brightness.light
                                              ? ColorsB.gray900
                                              : Colors.white,
                                      fontSize: 12.5.sp),
                                ),
                              )
                            ],
                          ),
                        ),
                        Chip(
                          backgroundColor: ColorsB.gray200,
                          label: Text(widget.date),
                          avatar: const Icon(Icons.calendar_today_outlined),
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
        body: Scrollbar(
          child: CustomScrollView(
            physics:
                const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
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
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Chip(
                          backgroundColor: ColorsB.gray200,
                          avatar: CircleAvatar(
                            backgroundImage: Image.network(
                              avatarImg,
                              errorBuilder: (c, ex, sT) =>
                                  Text(widget.author[0]),
                            ).image,
                          ),
                          label: Text(
                              '${widget.author.split(' ').first} ${widget.author.split(' ').last[0]}.'),
                        )
                      ],
                    )),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(
                  child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SelectableLinkify(
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
                      )),
                ),
              )
            ],
          ),
        ));
  }
}

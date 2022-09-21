import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/colors.dart';

import 'package:http/http.dart' as http;

import 'back_navbar.dart';

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class Event extends StatelessWidget {
  final Map gMap;
  final int? id;
  final String title;
  final String body;
  final String owner;
  final String location;
  final String date;
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
    required this.location,
    required this.date,
    required this.link,
    required this.delete,
    required this.Context,
    required this.maps_link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var avatarImg = 'https://cnegojdu.ro/GojduApp/profiles/${owner.replaceAll(' ', '_')}.jpg';

    bool? _isnt404;


    Future<int> _getImgStatus() async {
      var response = await http.get(Uri.parse(avatarImg));

       _isnt404 = response.statusCode != 404;

      return response.statusCode;
    }

    Widget _CircleAvatar() {

      late var _sCode = _getImgStatus();

      return FutureBuilder(
        future: _sCode,
        builder: (context, snapshot){
          if(snapshot.hasData){

            if(_isnt404!){
              return CircleAvatar(
                backgroundImage: Image.network(
                  avatarImg,
                ).image,
              );

            }
            else {
              return CircleAvatar(
                child: Text(
                    owner[0]
                ),
              );

            }


          }
          else if(snapshot.hasError){
            return CircleAvatar(
              child: Text(
                  owner[0]
              ),
            );
          }
          else {
            return const CircleAvatar(
              backgroundColor: Colors.white,
            );
          }
        },

      );
    }


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
                      Colors.white.withOpacity(.5),
                      Colors.white.withOpacity(.1)
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: const [0, .75]
                  ),
                border: Border.all(color: Colors.white.withOpacity(.25))
              ),

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
                              fontWeight: FontWeight.bold
                          ),
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
                            children: [
                              Flexible(
                                  child: Chip(
                                    label: Text(
                                        owner
                                    ),
                                    avatar: _CircleAvatar(),
                                  )
                              ),
                              BetterChip(
                                  icon: Icon(Icons.calendar_today_outlined, color: ColorsB.gray900,),
                                  label: date,
                                  isGlass: true
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          BetterChip(
                              icon: const Icon(Icons.location_on_outlined, color: ColorsB.gray900,),
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

                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => BigNewsContainer(title: title, description: body, author: owner, date: date, location: location, imageString: link, mapsLink: maps_link)
                      )
                  );

                },
                borderRadius: BorderRadius.circular(30),
              ),
            ),


            Visibility(
              visible: gMap['account'] == 'Admin' || gMap['first_name'] + ' ' + gMap['last_name'] == owner,
              child: Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) =>
                            AlertDialog(
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
                                          fontSize: 15
                                      ),
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

                                              await delete();

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
                                                Icons.check, color: Colors.white,
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
                                                Icons.close, color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                            )
                    );
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

  const BetterChip({
    Key? key,
    this.height = 35.0,
    this.width = 100.0,
    this.bgColor = Colors.grey,
    this.isGlass = false,
    required this.icon,
    required this.label,
    this.secIcon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var normalDecoration = BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(360)
    );

    var glassDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        gradient: LinearGradient(
            colors: [
              bgColor.withOpacity(.75),
              bgColor.withOpacity(.1)
            ],
            stops: const [
              0, .75
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight
        ),
        border: Border.all(color: Color.alphaBlend(bgColor, Colors.white).withOpacity(.25))
    );




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
                    child: icon
                ),
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
                            color: ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light ? ColorsB.gray900 : Colors.white
                        ),
                      ),
                    ),
                    if(secIcon != null) Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () {

                            //  Make the google maps stuff
                            //  TODO:GMAPS

                          },
                          child: Icon(secIcon!, color: ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light ? ColorsB.gray900 : Colors.white,),
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


class BigNewsContainer extends StatefulWidget {

  final String title;
  final String description;
  final Color? color;
  final String author;
  final String date;
  final String location;
  final String? imageString;
  final String mapsLink;


  const BigNewsContainer({Key? key, required this.title, required this.description, this.color = ColorsB.yellow500, required this.author, this.imageString, required this.date, required this.location, required this.mapsLink}) : super(key: key);

  @override
  State<BigNewsContainer> createState() => _BigNewsContainerState();
}

class _BigNewsContainerState extends State<BigNewsContainer> {


  bool get _isCollapsed {
    return _controller.position.pixels >= screenHeight * .65 && _controller.hasClients;
  }

  var avatarImg;

  final ScrollController _controller = ScrollController();

  bool visible = false;

  late bool _isnt404;

  Future<int> _getImgStatus() async {
    var response = await http.get(Uri.parse(avatarImg));

    _isnt404 = response.statusCode != 404;

    return response.statusCode;
  }

  Widget _CircleAvatar() {

    late var _sCode = _getImgStatus();

    return FutureBuilder(
      future: _sCode,
      builder: (context, snapshot){
        if(snapshot.hasData){

          if(_isnt404){
            return CircleAvatar(
              backgroundImage: Image.network(
                avatarImg,
              ).image,
            );

          }
          else {
            return CircleAvatar(
              child: Text(
                  widget.author[0]
              ),
            );

          }


        }
        else if(snapshot.hasError){
          return CircleAvatar(
            child: Text(
                widget.author[0]
            ),
          );
        }
        else {
          return const CircleAvatar(
            backgroundColor: Colors.white,
          );
        }
      },

    );


    // try {
    //   return CircleAvatar(
    //     backgroundImage: Image.network(
    //       avatarImg,
    //     ).image,
    //   );
    // }
    // catch(e) {
    //   return CircleAvatar(
    //     child: Text(
    //         widget.author[0]
    //     ),
    //   );
    // }
  }


  @override
  void initState() {
    // TODO: implement initState

    avatarImg = 'https://cnegojdu.ro/GojduApp/profiles/${widget.author.split(' ').first}_${widget.author.split(' ').last}.jpg';
    print(avatarImg);

    _controller.addListener(() {

      _isCollapsed ? visible = true : visible = false;

      //  print(_controller.position.pixels);

      setState(() {

      });

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
    //print(imageLink);


    if(widget.imageString == 'null' || widget.imageString == ''){
      return Hero(
        tag: 'title-rectangle',
        child: Container(
          width: screenWidth,
          color: widget.color,
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Chip(
                            backgroundColor: ColorsB.gray200,
                            avatar: _CircleAvatar(),
                            label: Text(
                                widget.author
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                                  onTap: () async {
                                    if(await canLaunchUrl(Uri.parse(widget.mapsLink))){
                                      await launchUrl(Uri.parse(widget.mapsLink));
                                    } else {
                                      print('Can\'t do it chief');
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  BetterChip(
                                    width: screenWidth * .5,
                                    height: screenHeight * .05,
                                    bgColor: ColorsB.gray200,
                                    icon: Icon(Icons.location_on_outlined, color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,),
                                    label: widget.location,
                                    secIcon: Icons.view_in_ar,
                                  ),
                                  const SizedBox(width: 10,),
                                  Text(
                                    'Open in Google Maps',
                                    style: TextStyle(
                                        color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,
                                        fontSize: 12.5.sp
                                    ),
                                  )
                                ],
                              )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BetterChip(
                              width: 150,
                              bgColor: ColorsB.gray200,
                              icon: Icon(Icons.calendar_today_outlined, color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white),
                              label: widget.date,
                            ),
                          ),

                        ],
                      )

                    ],
                  ),
                )
            ),
          ),
        ),
      );
    }
    else {

      // Uint8List imagBytes = base64Decode(imageString!);

      return Hero(
          tag: 'title-rectangle',
          child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            Material(
                                color: Colors.transparent,
                                child: Stack(
                                    children: [
                                      Center(
                                        child: InteractiveViewer(
                                            clipBehavior: Clip.none,
                                            child: Image.network(widget.imageString!)
                                        ),
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
                                              }
                                          )
                                      )
                                    ]
                                )
                            )
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Image.network(widget.imageString!).image,
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.25,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [
                              0,
                              0.9
                            ]
                        )
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
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
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Chip(
                                  backgroundColor: ColorsB.gray200,
                                  avatar: _CircleAvatar(),
                                  label: Text(
                                      widget.author
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if(await canLaunchUrl(Uri.parse(widget.mapsLink))){
                                      await launchUrl(Uri.parse(widget.mapsLink));
                                    } else {
                                      print('Can\'t do it chief');
                                    }
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          BetterChip(
                                            width: screenWidth * .5,
                                            height: screenHeight * .05,
                                            bgColor: ColorsB.gray200,
                                            icon: Icon(Icons.location_on_outlined, color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,),
                                            label: widget.location,
                                            secIcon: Icons.view_in_ar,
                                          ),
                                          const SizedBox(width: 10,),
                                          Text(
                                            'Open in Google Maps',
                                            style: TextStyle(
                                                color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,
                                                fontSize: 12.5.sp
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: BetterChip(
                                    width: 150,
                                    bgColor: ColorsB.gray200,
                                    icon: Icon(Icons.calendar_today_outlined, color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,),
                                    label: widget.date,
                                  ),
                                ),

                              ],
                            )

                          ],
                        ),
                      )
                  ),
                ),
              ]
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {



    var device = MediaQuery.of(context);


    return Scaffold(
      bottomNavigationBar: const BackNavbar(),
      backgroundColor: ColorsB.gray900,
      body: CustomScrollView(
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
                    widget.title.length > 20 ? widget.title.substring(0, 20) + '...' : widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(width: 25,),
                  Chip(
                    backgroundColor: ColorsB.gray200,
                    avatar: CircleAvatar(
                      backgroundImage: Image.network(
                        avatarImg,
                        errorBuilder: (c, ex, sT) => Text(
                            widget.author[0]
                        ),
                      ).image,
                    ),
                    label: Text(
                        widget.author
                    ),
                  )
                ],
              )
            ),

          ),
          SliverFillRemaining(
            child: SizedBox(
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SelectableLinkify(
                    linkStyle: const TextStyle(color: ColorsB.yellow500),
                    text: widget.description,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.5,
                        fontWeight: FontWeight.normal
                    ),
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                  )
              ),
            ),
          )
        ],
      )
    );


  }
}


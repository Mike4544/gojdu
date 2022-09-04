import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
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
    required this.Context
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: screenHeight * .3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [ColorsB.gray800, ColorsB.gray700],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
            stops: [.5, 1]
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: ColorsB.gray900
                ),

                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            SizedBox(
                              width: screenWidth * .3,
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
                            const SizedBox(width: 25,),
                            Flexible(
                              child: Text(
                                'by $owner',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                                avatar: Icon(Icons.location_on_outlined, color: ColorsB.gray900,),
                                label: Text(
                                  location,
                                  style: TextStyle(
                                    color: ColorsB.gray900,
                                  ),
                                )
                            ),
                            Chip(
                                avatar: Icon(Icons.calendar_today_outlined, color: ColorsB.gray900,),
                                label: Text(
                                  date,
                                  style: TextStyle(
                                    color: ColorsB.gray900,
                                  ),
                                )
                            )
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
                            builder: (_) => BigNewsContainer(title: title, description: body, author: owner, date: date, location: location, imageString: link,)
                        )
                    );

                  },
                  borderRadius: BorderRadius.circular(30),
                ),
              ),


              Visibility(
                visible: gMap['account'] == 'Admin' || gMap['first_name'] + ' ' + gMap['last_name'] == owner,
                child: Positioned(
                  top: 10,
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
          )
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


  const BigNewsContainer({Key? key, required this.title, required this.description, this.color = ColorsB.yellow500, required this.author, this.imageString, required this.date, required this.location}) : super(key: key);

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
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                              backgroundColor: ColorsB.gray200,
                              avatar: const Icon(Icons.location_on_outlined, color: ColorsB.gray900,),
                              label: Text(
                                widget.location,
                                style: TextStyle(
                                  color: ColorsB.gray900,
                                ),
                              )
                          ),
                          Chip(
                              backgroundColor: ColorsB.gray200,
                              avatar: const Icon(Icons.calendar_today_outlined, color: ColorsB.gray900,),
                              label: Text(
                                widget.date,
                                style: TextStyle(
                                  color: ColorsB.gray900,
                                ),
                              )
                          )

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
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Chip(
                                    backgroundColor: ColorsB.gray200,
                                    avatar: const Icon(Icons.location_on_outlined, color: ColorsB.gray900,),
                                    label: Text(
                                      widget.location,
                                      style: TextStyle(
                                        color: ColorsB.gray900,
                                      ),
                                    )
                                ),
                                Chip(
                                    backgroundColor: ColorsB.gray200,
                                    avatar: const Icon(Icons.calendar_today_outlined, color: ColorsB.gray900,),
                                    label: Text(
                                      widget.date,
                                      style: TextStyle(
                                        color: ColorsB.gray900,
                                      ),
                                    )
                                )

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
                  child: Linkify(
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


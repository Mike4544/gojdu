import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gojdu/pages/addOffer.dart';
import 'package:gojdu/pages/news.dart';
import 'package:gojdu/pages/opportunities.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/colors.dart';
import '../widgets/back_navbar.dart';
import './offersPage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class OffersPage extends StatefulWidget {
  final Map globalMap;

  const OffersPage({Key? key, required this.globalMap}) : super(key: key);

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>{

  late List<OfferContainer> offers;

  Future<int> loadOffers() async {

    offers.clear();

    //  Maybe rework this a bit.

    try {
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/getOffers.php');
      final response = await http.post(url, body: {
        "index": "0"
      });
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        print(jsondata);

        if (jsondata["1"]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata["1"]["success"]) {

            for(int i = 2; i <= 52; i++)
            {
              int id = jsondata[i.toString()]["id"];
              String discount = jsondata[i.toString()]["discount"].toString();
              String short = jsondata[i.toString()]["short"].toString();
              String long = jsondata[i.toString()]["long"].toString();
              String owner = jsondata[i.toString()]["owner"].toString();
              String company = jsondata[i.toString()]["company"].toString();
              String location = jsondata[i.toString()]["location"].toString();
              String mapsLink = jsondata[i.toString()]["mapsLink"].toString();
              String date = jsondata[i.toString()]["date"].toString();
              String Imlink = jsondata[i.toString()]["link"].toString();
              String logo = jsondata[i.toString()]["logo"].toString();
              String color = jsondata[i.toString()]["color"].toString();



              ////print(globalMap['id']);



              if(id != null){

                
                var day = int.parse(date.split('/')[0]);
                var month = int.parse(date.split('/')[1]);
                var year = int.parse(date.split('/')[2]);

                offers.add(OfferContainer(
                  id: id,
                  compName: company,
                  date: DateTime(year, month, day),
                  delete: () {},
                  discount: discount,
                  fullDescription: long,
                  smallDescription: short,
                  globalMap: globalMap,
                  gmaps_link: mapsLink,
                  logoLink: logo,
                  owner: owner,
                  s_color: color,
                ));

                print(offers.length);




              }

              /* if(post != "null")
              {
                //print(post+ " this is the post");
                //print(title+" this is the title");
                //print(owner+ " this is the owner");
              } */

            }

            //  Add the search terms


            //  print(events);
          }
          else
          {
            //print(jsondata["1"]["message"]);
          }
        }
      }
    } catch (e) {

    }

    return 0;

  }

  Future _refresh() async {
      offers.clear();

      _getOffers = loadOffers();

      setState(() {

      });
  }



  Widget _offersList() {

    List dummyList = [];

    for(var e in offers){
      if(searchEditor.text.isEmpty){
        dummyList.add(e);
      }
      else {
        if(e.compName.contains(searchEditor.text) || e.discount.contains(searchEditor.text) || e.smallDescription.contains(searchEditor.text)){
          dummyList.add(e);
        }
      }
    }


    
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: dummyList.isNotEmpty ? dummyList.length : 1,
          shrinkWrap: true,
          itemBuilder: (context, index) {
              if(dummyList.isEmpty){
                return Center(
                    child: Column(
                      children: [
                        SizedBox(
                            height: screenHeight * 0.25,
                            child: SvgPicture.asset('assets/svgs/no_posts.svg')
                        ),
                        const Text(
                          'Wow! Such empty. So class.',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                        Text(
                          "It seems the only thing here is a lonely Doge. Pet it or begone!",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextButton.icon(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Refresh',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () async {
                              //  _refresh();
                              offers.clear();


                              _getOffers = loadOffers();

                              setState(() {});

                            },
                            style: TextButton.styleFrom(
                              backgroundColor: ColorsB.yellow500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    50),
                              ),
                            )
                        ),
                      ],
                    )
                );

              }
              else {
                return dummyList[index];
              }
          }

        ),
      ),
    );
  }

  late Future _getOffers = loadOffers();


  final searchEditor = TextEditingController();


  @override
  void initState() {
    offers = [];
    super.initState();
  }

  @override
  void dispose() {
    searchEditor.dispose();
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StatefulBuilder(
          builder: (context, setThisState) => const Background(),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: FutureBuilder(
            future: _getOffers,
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return const Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SearchButtonBar(isAdmin: widget.globalMap['account'] == 'Admin', searchController: searchEditor,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                            visible: widget.globalMap['account'] == 'Admin',
                            child: FloatingActionButton(
                              elevation: 0,
                              backgroundColor: ColorsB.gray800,
                              onPressed: () {

                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => AddOffer(gMap: widget.globalMap)
                                    )
                                );

                              },
                              mini: true,
                              child: const Icon(Icons.add, color: Colors.white,),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Expanded(child: _offersList())
                  ],

                );
              }
            },
          ),
        )
      ],
    );
  }
}

class OfferContainer extends StatelessWidget {
  final int id;
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



  const OfferContainer({Key? key,
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
    required this.fullDescription
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    print(date);

    final titleStyle = TextStyle(
        color: Colors.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold
    );

    final subtitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 15.sp,
    );

    final numberStyle =  TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 50.sp
    );

    var tempcolor = s_color.split('(0x')[1].split(')')[0];
    int value = int.parse(tempcolor, radix: 16);
    Color color = Color(value);


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Container(
          clipBehavior: Clip.hardEdge,
          height: screenHeight * .3,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * .075)
        ),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 7,
                  sigmaY: 7
              ),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * .075),
                  border: Border.all(color: Color.alphaBlend(color, Colors.white).withOpacity(.5)),
                  gradient: LinearGradient(
                      colors: [
                        color.withOpacity(.5),
                        color.withOpacity(.05)
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,

                      stops: const [
                        0, .75
                      ]
                  ),
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
                              width: screenHeight * .05,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
                                child: Image.network(logoLink),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                                compName,
                                style: titleStyle
                            ),
                            const Spacer(),
                            Icon(Icons.center_focus_strong_rounded, color: Colors.white.withOpacity(.5), size: screenHeight * .05,)
                          ],
                        ),
                        Divider(color: Colors.white.withOpacity(.5),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  discount,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50.sp
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Text(
                                smallDescription,
                                style: subtitleStyle,
                              ),
                            )
                          ],
                        ),
                        BetterChip(
                          width: screenWidth * .5,
                          height: screenHeight * .05,
                          icon: Icons.timer,
                          label: 'Available until ${DateFormat('dd.MM.yyyy').format(date)}',
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
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BigNewsContainer(title: compName, description: fullDescription, date: DateFormat('dd.MM.yyyy').format(date), gMapsLink: gmaps_link, color: color, logoLink: logoLink, imageString: headerImageLink.toString(),)
                    )
                  );
                  
                  
                },
              ),
            )
          ],
        )
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


  const BigNewsContainer({Key? key, this.gMapsLink, required this.title, required this.description, this.color = ColorsB.yellow500, this.imageString, required this.date, required this.logoLink}) : super(key: key);

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
                            child: Row(
                              children: [
                                SizedBox(
                                  height: screenHeight * .05,
                                  width: screenHeight * .05,
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
                                    child: Image.network(widget.logoLink),
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  widget.title,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            )
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
                                  if(await canLaunchUrl(Uri.parse(widget.gMapsLink!))){
                                    await launchUrl(Uri.parse(widget.gMapsLink!));
                                  } else {
                                    print('Can\'t do it chief');
                                  }
                                },
                                child: Row(
                                  children: [
                                    BetterChip(
                                      width: screenWidth * .5,
                                      height: screenHeight * .05,
                                      bgColor: ColorsB.gray200,
                                      icon: Icons.location_on_outlined,
                                      label: 'Location',
                                      isGlass: true,
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
                                width: screenWidth * .33,
                                height: screenHeight * .05,
                                bgColor: ColorsB.gray200,
                                icon: Icons.calendar_today_outlined,
                                label: widget.date,
                                isGlass: true
                            ),
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
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: screenHeight * .05,
                                          width: screenHeight * .05,
                                          child: ColorFiltered(
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
                                            child: Image.network(widget.logoLink),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(
                                          widget.title,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,
                                              fontSize: 30.sp,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    )
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
                                        if(await canLaunchUrl(Uri.parse(widget.gMapsLink!))){
                                          await launchUrl(Uri.parse(widget.gMapsLink!));
                                        } else {
                                          print('Can\'t do it chief');
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          BetterChip(
                                            width: screenWidth * .5,
                                            height: screenHeight * .05,
                                            bgColor: ColorsB.gray200,
                                            icon: Icons.location_on_outlined,
                                            label: 'Location',
                                            isGlass: true,
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
                                      width: screenWidth * .33,
                                      height: screenHeight * .05,
                                      bgColor: ColorsB.gray200,
                                      icon: Icons.calendar_today_outlined,
                                      label: widget.date,
                                      isGlass: true
                                  ),
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
                        style: TextStyle(
                            color: ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light ? ColorsB.gray900 : Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
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

class Background extends StatefulWidget{
  
  
  const Background({Key? key}) : super(key: key);

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>{

  late double x, y;
  late double blur1, blur2, blur3;

  double lastBlur1 = 5, lastBlur2 = 3, lastBlur3 = 1;

  late AccelerometerEvent _parallaxValues;

  //  static const sensitivity = 4;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    x = 0;
    y = 0;

    blur1 = 0;
    blur2 = 0;
    blur3 = 0;

    _timer  = Timer.periodic(const Duration(seconds: 6), (timer) {
       _getNewValues();
      setState(() {

      });

    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      accelerometerEvents.listen((event) {
        _parallaxValues = event;

        //print(event);

        if(mounted){
          if(x >= -10.0 && x <= 10.0){
            x += .5 * _parallaxValues.x;
          }
          else {
            x > 0 ? x = 10.0 : x = -10.0;
          }

          if(y >= -10 && y <= 10){
            y += .5 * (_parallaxValues.y - 3);
          }
          else {
            y > 0 ? y = 10.0 : y = -10.0;
          }

          setState(() {

          });
        }

      });

    });


  }

  @override
  void dispose() {
    //  _timer.cancel();
    super.dispose();
  }


  void _getNewValues(){
    lastBlur1 = blur1;
    lastBlur2 = blur2;
    lastBlur3 = blur3;


    blur1 = math.Random().nextDouble() * 5;
    blur2 = math.Random().nextDouble() * 12;
    blur3 = math.Random().nextDouble() * 5;

    //  print(c11);
  }

  

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            top: screenHeight * .025 + -y,
            right: 25 + x,
            child: Container(
              width: screenWidth * .5,
              height: screenWidth * .5,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Colors.red,
                  gradient: const LinearGradient(
                      colors: [
                        Color(0xff8A2387),
                        Color(0xffE94057),
                        Color(0xffF27121)
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight
                  ),
                  borderRadius: BorderRadius.circular(360)
              ),
            )
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: lastBlur1, end: blur1),
          duration: const Duration(seconds: 5),
          curve: Curves.ease,
          builder: (_, value, ___) => AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              top: screenHeight * .3 + -y,
              left: 25 + x,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaY: value,
                    sigmaX: value
                ),
                child: Container(
                  width: screenWidth * .15,
                  height: screenWidth * .15,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      gradient: const LinearGradient(
                          colors: [
                            Color(0xff8A2387),
                            Color(0xffE94057),
                            Color(0xffF27121)
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight
                      ),
                      borderRadius: BorderRadius.circular(360)
                  ),
                ),
              )
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: lastBlur2, end: blur2),
          duration: const Duration(seconds: 5),
          curve: Curves.ease,
          builder: (_, value, __) => BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: value,
                sigmaY: value
            ),
            child: Center(
              child: SizedBox(
                height: screenHeight * .4,
                child: Image.asset('assets/images/abstractFire.png'),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
          bottom: screenHeight * .025 + y,
          left: x,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(360),
            child: SizedBox(
              width: screenWidth * .57,
              height: screenWidth * .57,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenWidth * .5,
                    height: screenWidth * .5,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        gradient: const LinearGradient(
                            colors: [
                              Color(0xff8A2387),
                              Color(0xffE94057),
                              Color(0xffF27121)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight
                        ),
                        borderRadius: BorderRadius.circular(360)
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: lastBlur3, end: blur3),
                    duration: const Duration(seconds: 5),
                    curve: Curves.ease,
                    builder: (_, value, __) => BackdropFilter(filter: ImageFilter.blur(
                        sigmaY: value,
                        sigmaX: value
                    ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }
}





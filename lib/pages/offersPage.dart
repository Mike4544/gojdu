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



class _OffersPageState extends State<OffersPage> with AutomaticKeepAliveClientMixin{
  bool get wantKeepAlive => true;

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
                  delete: () async {
                    await deleteEvent(id, i - 2);
                    setState(() {

                    });
                  },
                  discount: discount,
                  fullDescription: long,
                  smallDescription: short,
                  globalMap: globalMap,
                  gmaps_link: mapsLink,
                  headerImageLink: Imlink,
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

  Future<void> deleteEvent(int Id, int index) async {

    try {
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/deleteOffer.php');
      final response = await http.post(url, body: {
        "id": Id.toString()
      });

      print(Id.toString());
      print(response.statusCode);

      if(response.statusCode == 200){
        print(response.body);

        var jsondata = json.decode(response.body);
        //  print(jsondata);

        if(jsondata['error']){

          print('Errored');

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Row(
                  children: const [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 20,),
                    Text(
                      'Uh-oh! Something went wrong!',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              )
          );

        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                content: Row(
                  children: const [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 20,),
                    Text(
                      'Hooray! The post was deleted.',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              )
          );

          offers.removeAt(index);


        }



      }
      else {
        print("Deletion failed.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Row(
                children: const [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 20,),
                  Text(
                    'Uh-oh! Something went wrong!',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  )
                ],
              ),
            )
        );


      }

    } catch(e) {

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 20,),
                Text(
                  'Uh-oh! Something went wrong!',
                  style: TextStyle(
                      color: Colors.white
                  ),
                )
              ],
            ),
          )
      );

      print(e);

    }


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
                            child: Image.asset('assets/images/no_posts.png'),
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
    super.build(context);
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
                        SearchButtonBar(isAdmin: widget.globalMap['account'] == 'Admin' || widget.globalMap['account'] == 'Teacher', searchController: searchEditor,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                            visible: widget.globalMap['account'] == 'Admin' || widget.globalMap['account'] == 'Teacher',
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
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: discount.length < 10
                                    ? FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        discount,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    : Text(
                                  discount,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  smallDescription,
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
            ),
            Visibility(
              visible: globalMap['account'] == 'Admin' || '${globalMap['first_name']} ${globalMap['last_name']}' == owner,
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
    print(widget.imageString);


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
                              end: Alignment.topRight
                          ),
                      ),
                    ),
                  ),
                ),
              )
          ),
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
                    imageFilter: ImageFilter.blur(
                        sigmaY: value,
                        sigmaX: value
                    ),
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
                              end: Alignment.topRight
                          ),
                        shape: BoxShape.circle

                      ),
                    ),
                  ),
                ),
              )
          ),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .4,
            child: Image.asset('assets/images/abstractFire.png', frameBuilder: (BuildContext context, Widget child, int? frame,
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
            },),
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
                child: ImageFiltered(imageFilter: ImageFilter.blur(
                    sigmaY: value,
                    sigmaX: value
                ),
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
                            end: Alignment.topRight
                        ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ),
      ],
    );
  }
}




import 'dart:ffi';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/class_selector.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/widgets/input_fields.dart';
import 'package:gojdu/widgets/navbar.dart';
import 'package:rive/rive.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/floor_selector.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';
import 'package:gojdu/others/event.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class NewsPage extends StatefulWidget {

  final Map data;

  const NewsPage({Key? key, required this.data}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

//Globals
SMIInput<bool>? _mapInput, _announcementsInput, _reserveInput;
late bool loaded;

late Map globalMap;



// <---------- Height and width outside of context -------------->
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

//  TODO: Make variables for the name, password, mail etc



class _NewsPageState extends State<NewsPage>{

  bool pressed = false; //????????????? Ii folosit undeva?????

  int _currentIndex = 1;


  late final accType;


  Artboard? _mapArtboard, _announcementsArtboard, _reserveArtboard;


  //Change the animations function
  void _mapExpandAnim(SMIInput<bool>? _input) {
    if(_input?.value == false){
      if(_mapInput?.value == true && _input?.value == false) {
        _mapInput?.value = false;
      }
      if(_announcementsInput?.value == true && _input?.value == false) {
        _announcementsInput?.value = false;
      }

      if(_reserveInput?.value == true && _input?.value == false) {
        _reserveInput?.value = false;
      }



      _input?.value = true;
    }


  }

  final PageController _pageController = PageController(
    initialPage: 1,
  );


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // <---------- Load the acc type -------------->
    accType = widget.data['account'];
    globalMap = widget.data;

    //  <-----------  Loaded  ------------------>
    loaded = false;
    //Initialising the navbar icons -
    rootBundle.load('assets/map.riv').then((data){
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      var StateController = StateMachineController.fromArtboard(artboard, 'ExpandStop');
      if(StateController != null) {
        artboard.addController(StateController);
        _mapInput = StateController.findInput('Expanded');
      }
      setState(() {
        _mapArtboard = artboard;
      });
    });

    rootBundle.load('assets/announcements.riv').then((data){
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      var StateController = StateMachineController.fromArtboard(artboard, 'NewsController');
      if(StateController != null) {
        artboard.addController(StateController);
        _announcementsInput = StateController.findInput('Active');
      }
      setState(() {
        _announcementsArtboard = artboard;
      });
    });

    rootBundle.load('assets/reservation.riv').then((data){
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      var StateController = StateMachineController.fromArtboard(artboard, 'OpenClose');
      if(StateController != null) {
        artboard.addController(StateController);
        _reserveInput = StateController.findInput('Active');
      }
      setState(() {
        _reserveArtboard = artboard;
      });
    });

    //-



  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
    globalMap.clear();
  }



  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: ColorsB.gray900,
      extendBody: true,
      bottomNavigationBar:
      Container(
        width: device.size.width,
        height: 75,
        decoration: BoxDecoration(
          color: ColorsB.gray800,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 10,
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ]
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Rive(artboard: _mapArtboard!, fit: BoxFit.fill,
                  ),
                  onTap: () {
                    _mapExpandAnim(_mapInput);
                    setState(() {
                      _currentIndex = 0;
                    });
                    _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                  },
                ),
              ),

              Container(
                width: 50,
                height: 50,
                child: GestureDetector(
                  child: Rive(artboard: _announcementsArtboard!, fit: BoxFit.fill,
                  ),
                  onTap: () {
                    _mapExpandAnim(_announcementsInput);
                    setState(() {
                      _currentIndex = 1;
                    });
                    _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                  }
                ),
              ),

              Container(
                width: 60,
                height: 50,
                child: GestureDetector(
                  child: Rive(artboard: _reserveArtboard!, fit: BoxFit.fill,
                  ),
                  onTap: () {
                    _mapExpandAnim(_reserveInput);
                    setState(() {
                      _currentIndex = 2;
                    });
                    _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                ),
              ),
            ]
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          MapPage(navbarButton: _mapInput),
          Announcements(navbarButton: _announcementsInput),
          Calendar(navbarButton: _reserveInput,)
        ],
      ),
    );
  }
}

class Announcements extends StatefulWidget {

  final SMIInput<bool>? navbarButton;

  const Announcements({Key? key, required this.navbarButton}) : super(key: key);

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}


// Test

//var currentChannel = "";

int maximumCount = 0;

class _AnnouncementsState extends State<Announcements> with SingleTickerProviderStateMixin {


  var selectedColorS = Colors.white;
  var selectedColorT = ColorsB.yellow500;
  var selectedColorP = Colors.white;

  late double rectX;



  late final _announcementsController;

  var _currentAnnouncement = 1;

//  <----------------- Shimmer animation controller ----------->
  late AnimationController _shimmerController;


  //  <-------------- Loading bool for shimmer loading -------------------->
  late bool isLoading;

  //  <---------------  Scrollcontroller  ------------------------->

  late ScrollController  _scrollController;
  int maxScrollCount = 5;


  //  <-----------------  Text Keys ----------------------------->
  final GlobalKey _textKeyStudent = GlobalKey();
  final GlobalKey _textKeyTeacher = GlobalKey();
  final GlobalKey _textKeyParent = GlobalKey();




  late var currentChannel = "";

  late List<String> titles;
  late List<String> descriptions;
  late List<String> owners;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //  <-------------- Lists ------------->
    titles = [];
    descriptions = [];
    owners = [];

    maximumCount = 0;




    int _getCurrentIndex() {
      switch(globalMap['account']) {
        case 'Student':
          _currentAnnouncement = 0;
          currentChannel = 'Students';
          return 0;
        case 'Teacher':
          _currentAnnouncement = 1;
          currentChannel = 'Teachers';
          return 1;
        case 'Parent':
          _currentAnnouncement = 2;
          currentChannel = 'Parents';
          return 2;
        default:
          return 0;
      }
    }

    _announcementsController = PageController(
      initialPage:  _getCurrentIndex(),

    );
    widget.navbarButton?.value = true;
    _mapInput?.value = false;
    _reserveInput?.value = false;
    _currentAnnouncement = 1;
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    if(descriptions.isEmpty) {
      isLoading = true;
      load(currentChannel);
    }
    else {
      isLoading = false;
    }

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        _getMoreData();
      }
    });

    print(globalMap['account']);

  }

  @override
  void dispose() {
    _announcementsController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    titles.clear();
    descriptions.clear();
    owners.clear();
    super.dispose();


  }

  void _getMoreData() {

    //  TODO: Maybe make it async
    maxScrollCount += 5;
    setState(() {

    });

  }

  void _refresh() async {
    loaded = false;
    titles.clear();
    owners.clear();
    descriptions.clear();
    maximumCount = 0;
    setState(() {
      maxScrollCount = 5; //  Reset to the original scroll count
      isLoading = true;
      load(currentChannel);
    });
  }

  void _showWritable() {

     Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, a1, a2) =>
      SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
        child: const PostItPage(),
      )
    ));

  }


  // ---------- Placeholder title ------------
  String title = '';
  String description = '';

  var device = window.physicalSize;

  late var currentWidth;

  // Max max max posts


  //  <----------------- Alignment for the bar -------------->
  Alignment _alignment = Alignment.center;


  List<String> labels = [
    'Students',
    'Teachers',
    'Parents'
  ];

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  final style = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold
  );


  @override
  Widget build(BuildContext context) {

    currentWidth = _textSize(labels[_currentAnnouncement], style).width;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Announcements', accType: globalMap['account'] + ' account', position: 1,),

        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Latest news',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontSize: 25,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Visibility(
                        visible: globalMap['account'] == 'Teacher' ? true : false, // cHANGE IT,
                        child: GestureDetector(
                          onTap: _showWritable,
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 40,
                            color: ColorsB.gray800,

                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: ColorsB.gray800,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25,),

                  teachersBar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: SizedBox(
                      height: 450,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) =>
                        const material.LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            0, 0.25
                          ],
                          colors: [Colors.transparent, ColorsB.gray900]
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: PageView(
                          clipBehavior: Clip.hardEdge,
                          controller: _announcementsController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildLists(ColorsB.gray800),
                            _buildLists(Colors.amber),
                            _buildLists(Colors.indigoAccent),


                          ],
                        ),
                      )
                    ),
                  )

                ],
              ),
            )
        )

      ],
    );
  }

  Widget teachersBar() {
    if(globalMap['account'] == 'Teacher') {

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 75,
          width: device.width * 0.90,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(50)
            ),
            child: Align(
              alignment: Alignment(0, 0.5),

              //  TODO: Modify the alignment here.
              child: Transform.translate(
                offset: Offset(0, 20),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          child: Text(
                            'Students',
                            key: _textKeyStudent,
                            style: TextStyle(
                                color: selectedColorS,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedColorS = ColorsB.yellow500;
                              selectedColorT = Colors.white;
                              selectedColorP = Colors.white;
                              _alignment = Alignment.centerLeft;
                              _currentAnnouncement = 0;
                              currentWidth = _textSize(labels[_currentAnnouncement], style).width;
                              currentChannel = 'Students';
                              _refresh();
                              print(currentWidth);
                            });
                            _announcementsController.animateToPage(
                                _currentAnnouncement,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut);
                          },
                        ),
                        GestureDetector(
                          child: Text(
                            'Teachers',
                            key: _textKeyTeacher,
                            style: TextStyle(
                                color: selectedColorT,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onTap: () {

                              setState(() {
                                selectedColorS = Colors.white;
                                selectedColorT = ColorsB.yellow500;
                                selectedColorP = Colors.white;
                                _alignment = Alignment.center;
                                _currentAnnouncement = 1;
                                currentWidth = _textSize(labels[_currentAnnouncement], style).width;
                                currentChannel = 'Teachers';
                                _refresh();
                                print(currentWidth);
                              });
                              _announcementsController.animateToPage(
                                  _currentAnnouncement,
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.easeInOut);
                          },
                        ),
                        GestureDetector(
                          child: Text(
                            'Parents',
                            key: _textKeyParent,
                            style: TextStyle(
                                color: selectedColorP,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onTap: () {

                              setState(() {
                                selectedColorS = Colors.white;
                                selectedColorT = Colors.white;
                                selectedColorP = ColorsB.yellow500;
                                _alignment = Alignment.centerRight;
                                _currentAnnouncement = 2;
                                currentWidth = _textSize(labels[_currentAnnouncement], style).width;
                                currentChannel = 'Parents';
                                _refresh();
                                print(currentWidth);
                              });

                              _announcementsController.animateToPage(
                                  _currentAnnouncement,
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.easeInOut);
                            }
                        )
                      ],
                    ),
                    AnimatedAlign(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 250),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: currentWidth/3),
                        child: AnimatedContainer(
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 250),
                          width: currentWidth,
                          height: 2,
                          color: ColorsB.yellow500,
                        ),
                      ),
                      alignment: _alignment,
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    else {
      return const SizedBox(width: 0, height: 0,);
    }
  }



  Widget _buildLists(Color _color) {
    if(isLoading) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: maxScrollCount,
        itemBuilder: (_, index) =>
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Shimmer.fromColors(
                baseColor: ColorsB.gray800,
                highlightColor: ColorsB.gray700,
                child: Container(                         // Student containers. Maybe get rid of the hero
                    width: screenWidth * 0.75,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(
                          50),
                    ),
                  ),
              ),
              ),
      );
    }
    else {
      return RefreshIndicator(
        backgroundColor: ColorsB.gray900,
        color: _color,
        onRefresh: () async {
          _refresh();
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: maxScrollCount < descriptions.length ? maxScrollCount + 1 : descriptions.length,
          itemBuilder: (_, index) {

            title = titles[index];
            description = descriptions[index];
            var owner = owners[index];

            if(index != maxScrollCount){
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: screenWidth * 0.75,
                  height: 200,
                  child: Container(                         // Student containers. Maybe get rid of the hero
                    width: screenWidth * 0.75,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(
                          50),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          _hero(context, titles[index], descriptions[index], owners[index], _color);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                'by ' + owner,     //  Hard coded!!
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 25,),

                              Flexible(
                                child: Text(
                                  description,
                                  overflow: TextOverflow
                                      .ellipsis,
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.25),
                                      fontSize: 15,
                                      fontWeight: FontWeight
                                          .bold
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            else{
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Shimmer.fromColors(
                  baseColor: ColorsB.gray800,
                  highlightColor: ColorsB.gray700,
                  child: Container(                         // Student containers. Maybe get rid of the hero
                    width: screenWidth * 0.75,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(
                          50),
                    ),
                  ),
                ),
              );
            }
          }

        ),
      );
    }

  }

  //  <------------------- Hardcoded loader ------------------>





  Future<int> load(String channel) async {
    /*
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        isLoading = false;
        loaded = true;
      });

     */
      var url = Uri.parse('https://automemeapp.com/selectposts.php');
          final response = await http.post(url, body: {
            "index": "0",
            "channel": channel,
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);

        if (jsondata["1"]["error"]) {
          setState(() {
            //nameError = jsondata["message"];
          });
        } else {
          if (jsondata["1"]["success"]) {

            for(int i = 2; i <= 52; i++)
            {
              String post = jsondata[i.toString()]["post"].toString();
              String title = jsondata[i.toString()]["title"].toString();
              String owner = jsondata[i.toString()]["owner"].toString();


              if(post != "null" && post != null){
                titles.add(title);
                descriptions.add(post);
                owners.add(owner);
                ++maximumCount;
              }

              /* if(post != "null")
              {
                print(post+ " this is the post");
                print(title+" this is the title");
                print(owner+ " this is the owner");
              } */

            }
            setState(() {
              isLoading = false;
              loaded = true;
            });
          }
          else
          {
            print(jsondata["1"]["message"]);
          }
        }
      }

      return 0;

  }

  // <-------------- Placing the hero container ---------------> //
  void _hero(BuildContext context, String title, String description, String author, Color color) {
    Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secAnim) =>
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero
                ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.ease)
                ),
                child: BigNewsContainer(title: title, description: description, color: color, author: author,),
              )
        )
    );
  }




}




// <----------------- Making the 'News' container big ------------------>
class BigNewsContainer extends StatelessWidget {

  final String title;
  final String description;
  final Color color;
  final String author;

  const BigNewsContainer({Key? key, required this.title, required this.description, required this.color, required this.author}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    return Scaffold(
      bottomNavigationBar: BackNavbar(),
      backgroundColor: ColorsB.gray900,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'title-rectangle',
              child: Container(
                width: device.size.width,
                height: device.size.height * 0.5,
                color: color,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                            "by " + author,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                description,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.normal
                ),
              ),
            )

          ],
        )
      ),
    ) ;
  }
}





class MapPage extends StatefulWidget {
  final SMIInput<bool>? navbarButton;


  const MapPage({Key? key, required this.navbarButton}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  int floorNo = 1;

  // <---------- Function to switch the floor (placeholder) -------------------->
  void _mapUpdate(int newFloor) {
    setState(() {
      floorNo = newFloor;
    });
  }

  final height = ValueNotifier<double>(0);
  bool open = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _announcementsInput?.value = false;
    _reserveInput?.value = false;

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



  // <---------- Animated switcher children aka the maps ---------->
  Widget? _mapChildren() {

    switch(floorNo) {
      case 0:
        return Container(
          key: Key('1'),
          width: screenWidth * 0.75,
          height: screenHeight / 2,
          decoration: BoxDecoration(
            color: ColorsB.yellow500,
            borderRadius: BorderRadius.circular(50),
          ),
        );
      case 1:
        return Container(
          key: Key('2'),
          width: screenWidth * 0.75,
          height: screenHeight / 2,
          decoration: BoxDecoration(
            color: ColorsB.gray800,
            borderRadius: BorderRadius.circular(50),
          ),
        );
      case 2:
        return Container(
          key: Key('3'),
          width: screenWidth * 0.75,
          height: screenHeight / 2,
          decoration: BoxDecoration(
            color: ColorsB.gray700,
            borderRadius: BorderRadius.circular(50),
          ),
        );
      case 3:
        return Container(
          key: Key('4'),
          width: screenWidth * 0.75,
          height: screenHeight / 2,
          decoration: BoxDecoration(
            color: ColorsB.gray200,
            borderRadius: BorderRadius.circular(50),
          ),
        );
    }

  }


  @override
  Widget build(BuildContext context) {



    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Map', position: 0, accType: globalMap['account'] + ' account'),

        SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 50, 25, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Select floor',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontSize: 25,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          color: ColorsB.gray800,
                          height: 2,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 50,),

                  //Widgetul pt select floor

                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 100),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                            child: _mapChildren(),
                            transitionBuilder: (child, animation) =>
                                SlideTransition(
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                  position: Tween<Offset>(
                                      begin: Offset(1, 0),
                                      end: Offset.zero
                                  ).animate(animation),
                                ),
                          ),
                        ],
                      ),
                      DropdownSelector(update: _mapUpdate,),
                      //TODO: Add the images (at least a placeholder one and do the thingy)

                    ],
                  ),

                  // DropdownSelector(update: _mapUpdate,),
                  // //TODO: Add the images (at least a placeholder one and do the thingy)





                ],
              ),
            )
        )

      ],
    );



  }
}


class Calendar extends StatefulWidget {
  final SMIInput<bool>? navbarButton;


  const Calendar({Key? key, required this.navbarButton}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}


class _CalendarState extends State<Calendar> with TickerProviderStateMixin{


  late List<EdgeInsetsGeometry> _padding;
  late List<Color> _wordColor;

  late AnimationController _clipAnimation;
  late Animation<double> _clipAnimationValue;

  late AnimationController _containerAnim;
  late Animation<double> _containerAnimValue;

  late Animation<double> _gradientAnim;

  int maxStep = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _announcementsInput?.value = false;
    _mapInput?.value = false;
    currentPage = 0;
    _stepsColors = [
      ColorsB.yellow500,
      ColorsB.gray800,
      ColorsB.gray800,
      ColorsB.gray800,
    ];
    _padding = [
      const EdgeInsets.only(bottom: 50),
      EdgeInsets.zero,
      EdgeInsets.zero,
      EdgeInsets.zero,
    ];
    _wordColor = [
      Colors.white,
      ColorsB.gray800,
      ColorsB.gray800,
      ColorsB.gray800,
    ];

    _clipAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _containerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _clipAnimationValue = Tween<double>(begin: 0, end: 1).animate(_clipAnimation);

    _clipAnimationValue = Tween<double>(begin: screenWidth * 0.25, end: screenWidth * 0.1).animate(CurvedAnimation(
        parent: _clipAnimation,
        curve: Curves.easeInOut
    ));
    _containerAnimValue = Tween<double>(begin: screenWidth * 0.25, end: screenWidth * 0.1 + 20).animate(CurvedAnimation(
        parent: _containerAnim,
        curve: Curves.easeInOut
    ));

    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _clipAnimation,
        curve: Curves.easeInOut
    ));

    maxStep = 0;
    


  }

  @override
  void dispose() {
    _clipAnimation.dispose();
    _stepsColors.clear();
    _padding.clear();
    _wordColor.clear();
    _containerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      slivers: [
        const CurvedAppbar(name: 'Hall Manager', position: 2, accType: 'Student account'),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 0, 70),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _clipAnimation,
                  builder: (_, __) =>
                      Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: _clipAnimationValue.value),
                              const SizedBox(width: 2),
                              GestureDetector(
                                onTap: () {
                                  if(_clipAnimation.status == AnimationStatus.dismissed){
                                    _clipAnimation.forward();
                                    _containerAnim.forward();
                                  }
                                  else {
                                    _clipAnimation.reverse();
                                    _containerAnim.reverse();
                                  }
                                },
                                child: Container(
                                  width: 15,
                                  height: screenHeight * 0.5,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: RotationTransition(
                                      turns: Tween<double>(begin: 0.5, end: 0).animate(CurvedAnimation(parent: _clipAnimation, curve: Curves.easeInOut)),
                                      child: const Icon(
                                        Icons.keyboard_arrow_right_rounded,
                                        color: Colors.white,
                                        size: 20
                                      ),
                                    ),
                                  )
                                ),
                              )
                            ],
                          ),

                          ClipRect(
                            clipper: CustomClipBar(widthFactor: _clipAnimationValue.value),
                            child: SizedBox(
                                height: screenHeight * 0.5,
                                width:  _clipAnimationValue.value <= screenWidth * 0.2 ? _containerAnimValue.value : screenWidth * 0.25,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AnimatedPadding(
                                      curve: Curves.easeInOut,
                                      duration: const Duration(milliseconds: 250),
                                      padding: _padding[0],
                                      child: Row(
                                        children: [
                                          AnimatedContainer(duration: const Duration(milliseconds: 250),
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: _stepsColors[0],
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '1',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.normal
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15,),
                                          Flexible(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              style: TextStyle(
                                                color: _clipAnimationValue.value <= screenWidth * 0.23 ? Colors.transparent : _wordColor[0],
                                                fontSize: 10,
                                                fontFamily: 'Nunito',
                                              ),
                                              child: Text(
                                                _clipAnimationValue.value <= screenWidth * 0.2 ? '' : 'Select your hall.',
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    AnimatedPadding(
                                      curve: Curves.easeInOut,
                                      duration: const Duration(milliseconds: 250),
                                      padding: _padding[1],
                                      child: Row(
                                        children: [
                                          AnimatedContainer(duration: const Duration(milliseconds: 250),
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: _stepsColors[1],
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '2',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.normal
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15,),
                                          Flexible(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              style: TextStyle(
                                                color: _clipAnimationValue.value <= screenWidth * 0.23 ? Colors.transparent : _wordColor[1],
                                                fontSize: 10,
                                                fontFamily: 'Nunito',
                                              ),
                                              child: Text(
                                                _clipAnimationValue.value <= screenWidth * 0.2 ? '' : 'Select the day of interest.',
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    AnimatedPadding(
                                      curve: Curves.easeInOut,
                                      duration: const Duration(milliseconds: 250),
                                      padding: _padding[2],
                                      child: Row(
                                        children: [
                                          AnimatedContainer(duration: const Duration(milliseconds: 250),
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: _stepsColors[2],
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '3',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.normal
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15,),
                                          Flexible(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              style: TextStyle(
                                                color: _clipAnimationValue.value <= screenWidth * 0.23 ? Colors.transparent : _wordColor[2],
                                                fontSize: 10,
                                                fontFamily: 'Nunito',
                                              ),
                                              child: Text(
                                                _clipAnimationValue.value <= screenWidth * 0.2 ? '' : 'Select the time interval.',
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    AnimatedPadding(
                                      curve: Curves.easeInOut,
                                      duration: const Duration(milliseconds: 250),
                                      padding: _padding[3],
                                      child: Row(
                                        children: [
                                          AnimatedContainer(duration: const Duration(milliseconds: 250),
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: _stepsColors[3],
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '4',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.normal
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15,),
                                          Flexible(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              style: TextStyle(
                                                color: _clipAnimationValue.value <= screenWidth * 0.23 ? Colors.transparent : _wordColor[3],
                                                fontSize: 10,
                                                fontFamily: 'Nunito',
                                              ),
                                              child: Text(
                                                _clipAnimationValue.value <= screenWidth * 0.2 ? '' : 'Profit!',
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ],
                      )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _clipAnimation,
                    builder: (_, __) =>
                        Stack(
                          children: [
                            ShaderMask(
                              shaderCallback: (rect) {
                                return material.LinearGradient(
                                  begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      ColorsB.gray900.withOpacity(_gradientAnim.value),
                                      ColorsB.gray900,
                                    ],
                                ).createShader(rect);
                            },
                              blendMode: BlendMode.dstATop,
                              child: SizedBox(
                                height: screenHeight * 0.5,
                                child: PageTransitionSwitcher(
                                  duration: const Duration(milliseconds: 750),
                                  reverse: true,
                                  transitionBuilder: (child, animation, anim2) {
                                    return SharedAxisTransition(
                                      fillColor: ColorsB.gray900,
                                      animation: animation,
                                      secondaryAnimation: anim2,
                                      child: child,
                                      transitionType: SharedAxisTransitionType.vertical,
                                    );
                                  },
                                  child: currentPage == 0 ? CalPag1(changePage: _changePage,) : CalPag2(changePage: _changePage,)
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, screenHeight * 0.5 - 40),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if(currentPage != 0){

                                        _changePage(0);

                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 15,
                                            spreadRadius: 10,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: currentPage != 0 ? Colors.white : Colors.white.withOpacity(0.5)
                                        , size: 30,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 15,
                                            spreadRadius: 10,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: currentPage < maxStep ? Colors.white : Colors.white.withOpacity(0.5),
                                        size: 30,
                                      ),
                                    ),
                                    onTap: () {
                                      if(currentPage < maxStep){

                                        _changePage(currentPage+1);

                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ),
                  )
              ],
            ),
          ),
        )

      ],
    );
  }


  //  TODO: Implement the page changing logic

  //  <------------  Building the widgets for the animated switcher  ------------>
  int currentPage = 1;

  void _changePage(int page) {

    setState(() {
      _stepsColors[currentPage] = ColorsB.gray800;
      _padding[currentPage] = EdgeInsets.zero;
      _wordColor[currentPage] = ColorsB.gray800;

      _padding[page] = const EdgeInsets.only(bottom: 50);
      _stepsColors[page] = ColorsB.yellow500;
      _wordColor[page] = Colors.white;

      if(page > currentPage){
        maxStep = page;
      }


      currentPage = page;
    });
  }


  List<Color> _stepsColors = [
    ColorsB.yellow500,
    ColorsB.gray800,
    ColorsB.gray800,
    ColorsB.gray800,
  ];


}

class CustomClipBar extends CustomClipper<Rect> {
  final double widthFactor;

  const CustomClipBar({required this.widthFactor});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, widthFactor, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}



//  <-----------------  Calendar page 1 ------------------>
class CalPag1 extends StatelessWidget {

  final Function(int) changePage;

  const CalPag1({Key? key, required this.changePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        clipBehavior: Clip.hardEdge,         //  Find a way to do it better
        physics: const BouncingScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 125,
              decoration: BoxDecoration(
                color: ColorsB.gray800,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    changePage(1);
                  },
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const material.LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [0, 1],
                              colors: [
                                Colors.transparent,
                                Colors.black,
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Icon(
                            Icons.account_balance_sharp,
                            color: ColorsB.gray700.withOpacity(0.25),
                            size: 75,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance,
                                  color: ColorsB.yellow500,
                                  size: 20,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  'Hall $index',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.white.withOpacity(0.1),
                              thickness: 1,
                            ),
                            const SizedBox(height: 10,),
                            Text(
                              'Type: Large',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Capacity: 30',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//  <-----------------  Statefull cal page 2 ----------------->
class CalPag2 extends StatefulWidget {
  final Function(int) changePage;
  const CalPag2({Key? key, required this.changePage}) : super(key: key);

  @override
  State<CalPag2> createState() => _CalPag2State();
}

class _CalPag2State extends State<CalPag2> with TickerProviderStateMixin {

  //  <---------------- Animations for the calendar --------------------->


  var _focusedDay;
  var _selectedDay;
  var _calendarFormat;

  late double width;
  
  @override
  void initState() {
    // TODO: implement 
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _calendarFormat = CalendarFormat.week;
    _events = {};
    _selectedEvents = [];
    width = 175;
    
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;

  List<dynamic> _getEventsFromDay(DateTime date){
    return _events[date] ?? [];
  }

  // <-----------------  Time Pickers ----------------->
  late String _time1;
  late String _time2;


  // TODO: Get the data from the server and shit.



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 500),
              height: width,
              decoration: BoxDecoration(
                color: ColorsB.gray800,
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TableCalendar(
                      eventLoader: _getEventsFromDay,

                      daysOfWeekHeight: 30,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        weekendStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        decoration: BoxDecoration(
                          color: ColorsB.yellow500.withOpacity(1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        formatButtonShowsNext: false,
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      shouldFillViewport: false,
                      calendarStyle: CalendarStyle(
                        markerDecoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        disabledTextStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 12,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.25),
                          fontSize: 12,
                        ),

                        selectedDecoration: BoxDecoration(
                            color: ColorsB.yellow500,
                            shape: BoxShape.circle
                        ),
                        isTodayHighlighted: false,
                      ),
                      firstDay: DateTime.now().toUtc(),
                      lastDay: DateTime.utc(2040, 4, 12),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {






                          widget.changePage(2);
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          width = 300;
                        });
                      },
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Occupied Hours',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        var timeText = TextEditingController();
                                        var timeText2 = TextEditingController();

                                        TimeOfDay? parsedTime1;
                                        TimeOfDay? parsedTime2;

                                        var _formKey = GlobalKey<FormState>();
                                        var errorText1, errorText2;

                                        return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            backgroundColor: ColorsB.gray900,
                                            content: SizedBox(
                                              height: 200,
                                              child: Center(
                                                child: Form(
                                                  key: _formKey,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'From: ',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          SizedBox(
                                                            width: 200,
                                                            height: 50,
                                                            child: TextFormField(
                                                              controller: timeText,
                                                              style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors.white,
                                                              ),

                                                              readOnly: true,
                                                              decoration: InputDecoration(
                                                                errorText: errorText1,
                                                                icon: Icon(Icons.timer, color: Colors.white.withOpacity(0.5),), //icon of text field
                                                                labelText: "Enter Time", //label text of field
                                                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), //style of label text
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                                                                ),
                                                                enabledBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5))), //border of text field
                                                                ),

                                                              onTap: () async {
                                                                TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                if(pickedTime != null){
                                                                  parsedTime1 = pickedTime;
                                                                  DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                                                  String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                                                  //  print(formattedTime);
                                                                  setState(() {
                                                                    timeText.text = formattedTime;
                                                                    _time1 = formattedTime;
                                                                  });
                                                                }

                                                              },

                                                              validator: (value) {
                                                                if(value == null || value.isEmpty){
                                                                  return "Please enter time";
                                                                }
                                                                else if(parsedTime1 != null && parsedTime2 != null){
                                                                  if(parsedTime1!.hour > parsedTime2!.hour || ((parsedTime1!.hour == parsedTime2!.hour) && (parsedTime1!.minute >= parsedTime2!.minute))){
                                                                    return "Please enter valid time";
                                                                  }
                                                                }
                                                                return null;
                                                              },

                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'To: ',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          SizedBox(
                                                            width: 200,
                                                            height: 50,
                                                            child: TextFormField(
                                                              controller: timeText2,
                                                              style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors.white,
                                                              ),

                                                              readOnly: true,
                                                              decoration: InputDecoration(
                                                                errorText: errorText2,
                                                                icon: Icon(Icons.timer, color: Colors.white.withOpacity(0.5),), //icon of text field
                                                                labelText: "Enter Time", //label text of field
                                                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), //style of label text
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                                                                ),
                                                                enabledBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5))), //border of text field
                                                              ),

                                                              onTap: () async {
                                                                TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                parsedTime2 = pickedTime;
                                                                if(pickedTime != null){
                                                                  DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                                                  String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                                                  //  print(formattedTime);
                                                                  setState(() {
                                                                    timeText2.text = formattedTime;
                                                                    _time2 = formattedTime;
                                                                  });
                                                                }
                                                              },
                                                              validator: (value) {
                                                                if(value == null || value.isEmpty){
                                                                  return "Please enter time";
                                                                }
                                                                else if(parsedTime1 != null && parsedTime2 != null){
                                                                  if(parsedTime1!.hour > parsedTime2!.hour || ((parsedTime1!.hour == parsedTime2!.hour) && (parsedTime1!.minute >= parsedTime2!.minute))){
                                                                    return "Please enter valid time";
                                                                  }
                                                                }
                                                                return null;
                                                              },

                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          if(_formKey.currentState!.validate()){
                                                            setState(() {
                                                              if(_events[_selectedDay] != null){
                                                                _events[_selectedDay]!
                                                                    .add("$_time1 - $_time2");
                                                              }
                                                              else {
                                                                _events[_selectedDay] = ["$_time1 - $_time2"];
                                                              }
                                                            });
                                                            print(_events[_selectedDay]);//add event to list

                                                            widget.changePage(3);


                                                            Navigator.of(context).pop();
                                                          }
                                                        },
                                                        icon: const Icon(
                                                          Icons.add_circle,
                                                          color: Colors.white,
                                                        ),
                                                        label: const Text(
                                                          'Reserve',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )

                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                        );
                                      }

                                    );
                                  },
                                  child: const Text(
                                    'Reserve',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    backgroundColor: MaterialStateProperty.all<Color>(ColorsB.yellow500),
                                    shape: MaterialStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  )
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(0),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _events[_selectedDay]?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    _events[_selectedDay]![index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),


                        ],
                      )
                    )

                  ],
                ),
              )
            ),
          ],
        )
      ),
    );
  }
}




class PostItPage extends StatefulWidget {
  const PostItPage({Key? key}) : super(key: key);

  @override
  State<PostItPage> createState() => _PostItPageState();
}

class _PostItPageState extends State<PostItPage> {

  //  <---------------  Post controller ---------------->
  late TextEditingController _postController;
  late TextEditingController _postTitleController;

  // <---------------  Colors for the preview -------------->
  late Color? _postColor;
  late String? _className;


  // <---------------  Form key -------------->
  late final GlobalKey<FormState> _formKey;

  void _updatePreview(Color color, String className) {
    setState(() {
      _postColor = color;
      _className = className;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postController = TextEditingController();
    _postTitleController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _postColor = null;
    _className = null;
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorsB.gray900,
        bottomNavigationBar: const BackNavbar(variation: 1,),
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: AppBar(
            backgroundColor: ColorsB.gray900,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(35, 50, 0, 0),
              child: Row(
                children: const [
                  Icon(Icons.book, color: ColorsB.yellow500, size: 40,),
                  SizedBox(width: 20,),
                  Text(
                    'Make a new post',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(fieldName: 'Choose a title', isPassword: false, errorMessage: '', controller: _postTitleController, isEmail: false,),
                  const SizedBox(height: 50,),
                  const Text(
                    'Post contents',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _postController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    cursorColor: ColorsB.yellow500,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.red,
                        )
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field cannot be empty.';
                      }
                    },
                  ),
                  const SizedBox(height: 50,),
                  const Text(
                    'Select channel',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClassSelect(update: _updatePreview,),
                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if(_formKey.currentState!.validate()){
                            var url = Uri.parse('https://automemeapp.com/insertposts.php');
                                final response = await http.post(url, body: {
                                  "title": _postTitleController.value.text,
                                  "channel": _className,
                                  "body": _postController.value.text,
                                  "owner": globalMap["first_name"] + " " + globalMap["last_name"],
                                });
                            if (response.statusCode == 200) {
                              var jsondata = json.decode(response.body);
                              print(jsondata);
                              if (jsondata["error"]) {
                              } else {
                                if (jsondata["success"]){
                                  Navigator.pop(context);
                                }
                                else
                                {
                                  print(jsondata["message"]);
                                }
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Post',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 2.5,
                            fontSize: 20,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          backgroundColor: _postController.text.isEmpty || _postTitleController.text.isEmpty || _postColor == null ? ColorsB.gray800 : ColorsB.yellow500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: _postTitleController.text.isEmpty || _postController.text.isEmpty  || _postColor == null ? 0.5 : 1,
                        child: TextButton(
                          onPressed: () {

                            if(_formKey.currentState!.validate()) {


                              Navigator.of(context).push(
                                  PageRouteBuilder(
                                      pageBuilder: (context, animation, secAnim) {

                                        return SlideTransition(
                                          position: Tween<Offset>(
                                              begin: const Offset(0, 1),
                                              end: Offset.zero
                                          ).animate(
                                              CurvedAnimation(parent: animation, curve: Curves.ease)
                                          ),
                                          child: BigNewsContainer(title: _postTitleController.value.text, description: _postController.value.text, color: _postColor!, author: 'By Me'),
                                        );
                                      }

                                  )
                              );
                            }



                          },
                          child: const Text(
                            'Preview',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 2.5,
                              fontSize: 20,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            backgroundColor: ColorsB.gray800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 100,),
                ],
              ),
            ),
         ),
        ),
      ),
    );
  }
}







import 'dart:ffi';
import 'dart:convert';
import 'dart:io';
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
        physics: NeverScrollableScrollPhysics(),
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





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _mapInput?.value = false;
    _reserveInput?.value = false;
    _currentAnnouncement = 1;
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    if(!loaded) {
      isLoading = true;
      load();
    }
    else {
      isLoading = false;
    }
    rectX = device.width * 0.107;

    int _getCurrentIndex() {
      switch(globalMap['account']) {
        case 'Student':
          _currentAnnouncement = 0;
          return 0;
        case 'Teacher':
          _currentAnnouncement = 1;
          return 1;
        case 'Parent':
          _currentAnnouncement = 2;
          return 2;
        default:
          return 0;
      }
    }

    _announcementsController = PageController(
        initialPage:  _getCurrentIndex(),

    );

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
    setState(() {
      maxScrollCount = 5; //  Reset to the original scroll count
      isLoading = true;
      load();
    });
  }

  void _showWritable() {

     Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, a1, a2) =>
      SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a1, curve: Curves.ease)),
        child: const PostItPage(),
      )
    ));

  }


  // ---------- Placeholder title ------------
  String title = 'Lorem Ipsum Title';
  String description = 'Lorem Ipsum Title Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Title Lorem Ipsum Title ';

  var device = window.physicalSize;

  late var currentWidth;

  //  <----------------- Alignment for the bar -------------->
  Alignment _alignment = Alignment.center;


  List<String> labels = [
    'Students',
    'Teachers',
    'Parents'
  ];

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
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
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: ColorsB.gray800,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 25,),

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
                          physics: NeverScrollableScrollPhysics(),
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
                      duration: Duration(milliseconds: 250),
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

  List<String> posts = ["", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", ""];
  List<String>titles = ["", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", ""];
  List<String>owner = ["", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", "","", ""];
  bool reloadable = true;

  Widget _buildLists(Color _color) {
    if(isLoading) {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
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
          itemCount: maxScrollCount + 1,
          itemBuilder: (_, index) {
            if(index != maxScrollCount){
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    _hero(context, title, description, 'By Mihai', _color);
                  },
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
                              'By Mihai',     //  Hard coded!!
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 25,),

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
              );
            }
            else {
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

  void load() async {
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
            "channel": "Student",
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
            // bool reloadable = true;
            // index ------> global variable
            // maxindex = index + 10;
            for(int i = 2; i <= 10; i++) //index; index <= maxindex; index++
            {
              if(jsondata[i.toString()]["post"].toString() != "null")
                {
                  posts[i] = jsondata[i.toString()]["post"].toString();
                  titles[i] = jsondata[i.toString()]["title"].toString();
                  owner[i] = jsondata[i.toString()]["owner"].toString();
                }
              else
              {
                reloadable = false; //------> nu o sa se incarce mai multe postari
                break;
              }

            }
            print(posts);
            print(titles);
            print(owner);
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
                child: BigNewsContainer(title: title, description: description, color: color, author: 'By Mihai',),
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
                            author,
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

class _CalendarState extends State<Calendar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _announcementsInput?.value = false;
    _mapInput?.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Room Manager', position: 2, accType: 'Student account'),

        SliverToBoxAdapter(

        )

      ],
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
          preferredSize: Size.fromHeight(75),
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







import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/widgets/navbar.dart';
import 'package:rive/rive.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/floor_selector.dart';
import 'package:gojdu/widgets/back_navbar.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';

class NewsPage extends StatefulWidget {

  final bool isAdmin;

  const NewsPage({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

//Globals
SMIInput<bool>? _mapInput, _announcementsInput, _reserveInput;
late bool loaded;



// <---------- Height and width outside of context -------------->
var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

//  TODO: Make variables for the name, password, mail etc



class _NewsPageState extends State<NewsPage>{

  bool pressed = false; //????????????? Ii folosit undeva?????

  int _currentIndex = 1;








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
          Announcements(navbarButton: _announcementsInput, isAdmin: widget.isAdmin,),
          Calendar(navbarButton: _reserveInput,)
        ],
      ),
    );
  }
}

class Announcements extends StatefulWidget {

  final SMIInput<bool>? navbarButton;
  final bool isAdmin;

  const Announcements({Key? key, required this.navbarButton, required this.isAdmin}) : super(key: key);

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> with SingleTickerProviderStateMixin {


  var selectedColorS = Colors.white;
  var selectedColorT = ColorsB.yellow500;
  var selectedColorP = Colors.white;

  late double rectX;
  
  // <---------------- Bool for admin ------------------>
  late final bool isAdmin = widget.isAdmin;


  final _announcementsController = PageController(
      initialPage: 1
  );

  var _currentAnnouncement = 1;

//  <----------------- Shimmer animation controller ----------->
  late AnimationController _shimmerController;


  //  <-------------- Loading bool for shimmer loading -------------------->
  late bool isLoading;



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

  }

  @override
  void dispose() {
    _announcementsController.dispose();
    _shimmerController.dispose();
    super.dispose();


  }


  // ---------- Placeholder title ------------
  String title = 'Lorem Ipsum Title';
  String description = 'Lorem Ipsum Title Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Title Lorem Ipsum Title ';

  var device = window.physicalSize;

  @override
  Widget build(BuildContext context) {


    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Announcements', accType: 'Student account', position: 1,),

        SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 50, 25, 25),
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
                      SizedBox(width: 10,),
                      Visibility(
                        visible: isAdmin,
                        child: GestureDetector(
                          child: Icon(
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
    if(isAdmin){
      return SizedBox(
        height: 75,
        width: device.width * 0.90,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(50)
          ),
          child: Center(
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Text(
                        'Students',
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
                          rectX = 0;
                          _currentAnnouncement = 0;
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
                        style: TextStyle(
                            color: isAdmin ? selectedColorT : Colors.grey.withOpacity(0.25),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      onTap: () {
                        if(isAdmin) {
                          setState(() {
                            selectedColorS = Colors.white;
                            selectedColorT = ColorsB.yellow500;
                            selectedColorP = Colors.white;
                            rectX = device.width * 0.107;
                            _currentAnnouncement = 1;
                          });
                          _announcementsController.animateToPage(
                              _currentAnnouncement,
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeInOut);
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: ColorsB.yellow500,
                                content: Text(
                                  'You\'re not a teacher, dude.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              )
                          );
                        }
                      },
                    ),
                    GestureDetector(
                      child: Text(
                        'Parents',
                        style: TextStyle(
                            color: isAdmin ? selectedColorP : Colors.grey.withOpacity(0.25),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      onTap: () {
                        if(isAdmin) {
                          setState(() {
                            selectedColorS = Colors.white;
                            selectedColorT = Colors.white;
                            selectedColorP = ColorsB.yellow500;
                            rectX = device.width * 0.21;
                            _currentAnnouncement = 2;
                          });
                          _announcementsController.animateToPage(
                              _currentAnnouncement,
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeInOut);
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: ColorsB.yellow500,
                                content: Text(
                                  'You\'re not a parent, dude.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              )
                          );
                        }
                      },
                    )
                  ],
                ),
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25),
                    child: Container(
                      width: 75,
                      height: 2,
                      color: ColorsB.yellow500,
                    ),
                  ),
                  left: rectX,
                  top: 26,
                ),

              ],
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
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (_, index) =>
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  _hero(context, title, description, 'By Mihai', _color);
                },
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
              ),
      );
    }
    else {
      return RefreshIndicator(
        backgroundColor: ColorsB.gray900,
        color: _color,
        onRefresh: () async {},
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: (_, index) =>
              Padding(
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
              ),
        ),
      );
    }

  }

  //  <------------------- Hardcoded loader ------------------>

  void load() async {
      await Future.delayed(Duration(seconds: 3));
      setState(() {
        isLoading = false;
        loaded = true;
      });


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
        child:Column(
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
        CurvedAppbar(name: 'Map', position: 0, accType: 'Student account'),

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






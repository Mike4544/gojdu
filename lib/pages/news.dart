import 'package:flutter/material.dart';
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

class NewsPage extends StatefulWidget {

  final bool isAdmin;

  const NewsPage({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

//Globals
SMIInput<bool>? _mapInput, _announcementsInput, _reserveInput;

//TODO: Make the news page. At least begin it

class _NewsPageState extends State<NewsPage>{

  bool pressed = false; //????????????? Ii folosit undeva?????

  int _currentIndex = 1;

  //Navbar Anim stuff
  //Controllers?


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

  PageController _pageController = PageController(
    initialPage: 1,
  );


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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


  var selectedColorS = ColorsB.yellow500;
  var selectedColorT = Colors.white;

  double rectX = 0;
  
  // <---------------- Bool for admin ------------------>
  late final bool isAdmin = widget.isAdmin;


  final _announcementsController = PageController(
      initialPage: 0
  );

  var _currentAnnouncement = 0;

//  <----------------- Shimmer animation controller ----------->
  late AnimationController _shimmerController;


  //  <-------------- Loading bool for shimmer loading -------------------->
  bool isLoading = true;

  // <---------- Height and width outside of context -------------->
  var screenHeight = window.physicalSize.height / window.devicePixelRatio;
  var screenWidth = window.physicalSize.width / window.devicePixelRatio;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _mapInput?.value = false;
    _reserveInput?.value = false;
    _currentAnnouncement = 0;
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    _Load();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _announcementsController.dispose();
    _shimmerController.dispose();
  }


  // ---------- Placeholder title ------------
  String title = 'Lorem Ipsum Title';
  String description = 'Lorem Ipsum Title Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Title Lorem Ipsum Title ';



  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Announcements',),

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
                  SizedBox(height: 50,),

                  SizedBox(
                    height: 75,
                    width: device.size.width * 0.75,
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
                                        rectX = device.size.width * 0.75 * 0.5;
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
                                  width: 100,
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
                  ),

                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 400,
                      child: PageView(
                        controller: _announcementsController,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildLists(ColorsB.gray800),
                          _buildLists(Colors.amber),


                        ],
                      ),
                    ),
                  )

                ],
              ),
            )
        )

      ],
    );
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
                  _hero(context, title, description,
                      _color);
                },
                child: Hero(
                  tag: 'title-container',
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
              ),
      );
    }
    else {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (_, index) =>
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  _hero(context, title, description,
                      _color);
                },
                child: Hero(
                  tag: 'title-container',
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
      );
    }

  }

  //  <------------------- Hardcoded loader ------------------>

  void _Load() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isLoading = false;
    });
  }

  // <-------------- Placing the hero container ---------------> //
  void _hero(BuildContext context, String title, String description, Color color) {
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
                child: BigNewsContainer(title: title, description: description, color: color),
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

  const BigNewsContainer({Key? key, required this.title, required this.description, required this.color}) : super(key: key);

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
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
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
    // TODO: implement dispose
    super.dispose();
    height.dispose();
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

    var device = MediaQuery.of(context);


    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CurvedAppbar(name: 'Map',),

        SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 50, 25, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select floor',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontSize: 25,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(width: 10,),
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



/*TODO: KNOWN BUGS
        + Sometimes the dropdown from the second page doesn't work first time
        + Sometimes icons are stuck
 */





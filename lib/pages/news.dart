import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/widgets/navbar.dart';
import 'package:rive/rive.dart';
import 'package:gojdu/others/rounded_triangle.dart';
import 'package:gojdu/widgets/floor_selector.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

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
    if(_input?.value == false && _input?.controller.isActive == false){
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
                    _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
                  },
                ),
              ),
            ]
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          MapPage(navbarButton: _mapInput),
          Announcements(navbarButton: _announcementsInput),
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

class _AnnouncementsState extends State<Announcements> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _mapInput?.value = false;
    _reserveInput?.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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

                  ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Container(
                        height: 50,
                        color: ColorsB.yellow500,
                      ),
                      Container(
                        height: 50,
                        color: ColorsB.yellow500,
                      ),
                      Container(
                        height: 50,
                        color: ColorsB.yellow500,
                      ),
                      Container(
                        height: 50,
                        color: ColorsB.yellow500,
                      ),

                      //TODO: Wait for Darius

                    ],
                  ),

                ],
              ),
            )
        )

      ],
    );
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

  final height = ValueNotifier<double>(0);
  bool open = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.navbarButton?.value = true;
    _announcementsInput?.value = false;
    _reserveInput?.value = false;
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

                  DropdownSelector(),
                  //TODO: Add the images (at least a placeholder one and do the thingy)

                  SizedBox(height: 200)

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





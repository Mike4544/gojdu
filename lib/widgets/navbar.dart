import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
import 'package:rive/rive.dart';

class RoundedNavbar extends StatefulWidget {
  const RoundedNavbar({Key? key}) : super(key: key);

  @override
  State<RoundedNavbar> createState() => _RoundedNavbarState();
}

class _RoundedNavbarState extends State<RoundedNavbar> {



  //TODO: Make the damn controllers

  //Controllers?

  SMIInput<bool>? _mapInput, _announcementsInput;
  Artboard? _mapArtboard, _announcementsArtboard;


  void _mapExpandAnim(SMIInput<bool>? _input) {
    if(_input?.value == false && _input?.controller.isActive == false){
      if(_mapInput?.value == true && _input?.value == false) {
        _mapInput?.value = false;
      }
      if(_announcementsInput?.value == true && _input?.value == false) {
        _announcementsInput?.value = false;
      }



      _input?.value = true;
    }
    else if(_input?.value == true && _input?.controller.isActive == false) {
      _input?.value = false;
    }


  }



  @override
  void initState() {
    super.initState();


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

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context);
    return Container(
      color: ColorsB.gray800,
      width: device.size.width,
      height: 75,
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
              onTap: () => _mapExpandAnim(_mapInput),
            ),
          ),

          Container(
            width: 50,
            height: 50,
            child: GestureDetector(
              child: Rive(artboard: _announcementsArtboard!, fit: BoxFit.fill,
              ),
              onTap: () => _mapExpandAnim(_announcementsInput),
            ),
          ),
        ]
      ),
    );
  }


}




//TODO: Make the functionality -Navbar

import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

import '../widgets/back_navbar.dart';

class EditFloors extends StatefulWidget {
  Map floors;

  EditFloors({Key? key, required this.floors}) : super(key: key);

  @override
  State<EditFloors> createState() => _EditFloorsState();
}

class _EditFloorsState extends State<EditFloors> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Icon(Icons.edit, color: ColorsB.yellow500, size: 40,),
                SizedBox(width: 20,),
                Text(
                  'Edit current floors',
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

    );
  }
}

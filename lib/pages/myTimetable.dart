import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../others/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class MyTimetable extends StatefulWidget {
  const MyTimetable({Key? key}) : super(key: key);

  @override
  State<MyTimetable> createState() => _MyTimetableState();
}

class _MyTimetableState extends State<MyTimetable> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late var _currentTable;

  Future<int> loadTable() async {

    final prefs = await _prefs;

    _currentTable = prefs.getString("setTable");



    return 1;
  }

  Future setTable(List<int> imageBytes) async {
    final prefs = await _prefs;

    String encoded = base64Encode(imageBytes);
    prefs.setString('setTable', encoded);

    setState(() {
      _currentTable = encoded;
    });

  }

  late final Future _getTable = loadTable();



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * .15),
        child: FutureBuilder(
          future: _getTable,
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),),
              );
            }
            else {

             if(_currentTable != null){
               Uint8List? bytes = base64Decode(_currentTable);
               return Stack(
                 children: [
                   Container(
                       height: height * .5,
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(height * .003),
                           image: DecorationImage(
                               image: Image.memory(bytes,
                               frameBuilder:(context, child, frame, wasSync) {
                                 if(wasSync) return child;
                                 return AnimatedSwitcher(
                                   duration: const Duration(milliseconds: 200),
                                   child: frame != null
                                       ? child
                                       : const SizedBox(
                                           height: 60,
                                           width: 60,
                                           child: CircularProgressIndicator(
                                             valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),
                                               strokeWidth: 6),
                                         ),
                                 );
                               },
                               ).image
                           )

                       )
                   ),
                   SizedBox(
                     height: height * .5,
                     child: Material(
                       color: Colors.transparent,
                       child: InkWell(
                         onTap: () {
                           showDialog(
                             context: context,
                             builder: (context) => Material(
                               color: Colors.transparent,
                               child: Stack(
                                 alignment: Alignment.center,
                                 children: [
                                   InteractiveViewer(
                                     child: Image.memory(bytes),
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
                                 ],
                               ),
                             )
                           );
                         },
                       ),
                     ),
                   ),
                   Positioned(
                     right: 10,
                     top: 10,
                     child: IconButton(
                       icon: const Icon(Icons.more_vert, color: Colors.white,),
                       onPressed: () async {
                         final ImagePicker _picker = ImagePicker();

                         final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

                         if(image == null) return;

                         File _temp = File(image.path);

                         var fileBytes = _temp.readAsBytesSync();

                         await setTable(fileBytes);
                       },
                     ),
                   )
                 ],
               );
             }
             else {
               return SizedBox(
                 height: height * .3,
                 child: FittedBox(
                   fit: BoxFit.contain,
                   child: Column(
                     children: [
                       const Text(
                         "No timetable selected",
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 20,
                         ),
                       ),
                       const SizedBox(height: 10),
                       TextButton.icon(
                         icon: const Icon(Icons.upload_rounded, color:  Colors.white,),
                         label: const Text(
                           'Upload timetable',
                           style: TextStyle(
                             color: Colors.white
                           ),
                         ),
                         onPressed: () async {

                           final ImagePicker _picker = ImagePicker();

                           final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

                           if(image == null) return;

                           File _temp = File(image.path);

                           var fileBytes = _temp.readAsBytesSync();

                           await setTable(fileBytes);



                         },
                       )
                     ],
                   ),
                 ),
               );
             }
            }
          },

        ),
      ),
    );
  }
}

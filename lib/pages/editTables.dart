import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/others/floor.dart';

import '../widgets/back_navbar.dart';
import 'package:image_picker/image_picker.dart';

class EditFloors extends StatefulWidget {
  final List<Floor> floors;

  const EditFloors({Key? key, required this.floors}) : super(key: key);

  @override
  State<EditFloors> createState() => _EditFloorsState();
}


class _EditFloorsState extends State<EditFloors> {

  late List<Floor> temporary;

  final ImagePicker _picker = ImagePicker();
  late XFile? image;
  File? _file;

  String? format;

  Future<void> uploadImage(File? file, String name) async {
    try{
      if(image == null || file == null){
        return;
      }
      var imageBytes = file.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);



      var url = Uri.parse('https://cnegojdu.ro/GojduApp/image_upload.php');
      final response = await http.post(url, body: {
        "image": baseimage,
        "name": name,
        "format": format
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata["error"]){
          //print(jsondata["msg"]);
        }else{
          //print("Upload successful");
        }
      } else {
        //print("Upload failed");
      }




    }
    catch(e){
      //print("Error during converting to Base64");
    }
  }

  @override
  void dispose() {
    temporary.clear();
    super.dispose();
  }

  @override
  void initState() {

    temporary = List.from(widget.floors);


    super.initState();
  }


  List<DataRow> dataRows(List<Floor> array){
    List<DataRow> temp = [];

    const TextStyle style = TextStyle(
      color: ColorsB.gray900,
      fontWeight: FontWeight.normal,
      overflow: TextOverflow.fade
    );

    for(var i = 0; i < array.length; i++){
      print(array[i].floor);

      temp.insert(i, DataRow(
        cells: [
          DataCell(
              Container(
                decoration: BoxDecoration(
                  color: ColorsB.gray200,
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                  child: Text(
                    array[i].floor.length > 10 ? '${array[i].floor.substring(0, 10)}...' : array[i].floor,
                    style: style,
                  ),
                ),
              )
          ),
          DataCell(
              Container(
                decoration: BoxDecoration(
                    color: ColorsB.gray200,
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                  child: Text(
                    array[i].file.length > 10 ? '${array[i].file.substring(0, 10)}...${array[i].file.substring(array[i].file.length - 4)}' : array[i].file,
                    style: style,
                  )
                ),
              )
            ),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {
                  var nameController = TextEditingController();
                  String buttonText = 'Choose image';

                  showDialog(context: context, builder: (context) {

                    return StatefulBuilder(
                      builder: (_, StateSetter setThisState) =>
                      AlertDialog(
                        actionsPadding: const EdgeInsets.all(5),
                        actions: [
                          TextButton(
                            onPressed: () {
                              array[i].floor = nameController.text;
                              setState(() {

                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // nameController.dispose();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          )
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: ColorsB.gray900,
                        title: Column(
                          children: const [
                            Text(
                              'Edit entry',
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
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    style: const TextStyle(
                                      color: Colors.white
                                    ),
                                    cursorColor: Colors.white,
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      label: Text(
                                        'Edit name',
                                        style: TextStyle(
                                          color: Colors.white
                                        ),
                                      )
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: () {},
                                  label: Text(
                                    buttonText,
                                    style: const TextStyle(
                                      color: Colors.white
                                    ),
                                  ),
                                  icon: const Icon(Icons.image, color: Colors.white),
                                )
                              ],
                            ),

                          ),
                        ),
                      ),
                    );

                  });
                },
                  icon: Icon(Icons.edit, color: Colors.white),
                  splashRadius: 20,
                ),
                IconButton(onPressed: () {
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
                                    'Are you sure you want delete this entry?',
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
                                            temporary.removeAt(i);
                                            Navigator.of(context).pop();

                                            setState(() {

                                            });

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
                }, icon: Icon(Icons.delete, color: Colors.red), splashRadius: 20),
              ],
            )
          )
        ]
      ));
    }

    return temp;
  }






  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;


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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22.5, bottom: 10),
              child: Row(
                children: const [
                  Text(
                      "Name",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(width: 75,),
                  Text(
                      "File",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            if (temporary.isNotEmpty) Scrollbar(
              radius: const Radius.circular(50),
              isAlwaysShown: true,
              child: SizedBox(
                height: height * .35,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowHeight: 0,
                          dataRowHeight: 75,
                          dividerThickness: 0,
                          columns: const [
                            DataColumn(
                                label: Text(
                                    "",
                                    style: TextStyle(color: Colors.white)
                                )
                            ),
                            DataColumn(
                                label: Text(
                                    "",
                                    style: TextStyle(color: Colors.white)
                                )
                            ),
                            DataColumn(
                                label: Text(
                                    "",
                                    style: TextStyle(color: Colors.white)
                                )
                            ),
                          ],
                          rows: dataRows(temporary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ) else const Center(
                child: Text(
                'No floors added. Why not add one?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
            ),
              ),

            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .1,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: ColorsB.gray800, width: 2)
                    ),
                    child: const Center(
                      child: Text(
                        'Add a floor',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .1,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          var nameController = TextEditingController();
                          String buttonText = 'Choose Image';


                          showDialog(context: context, builder: (context) {

                            return StatefulBuilder(
                              builder: (_, StateSetter setThisState) =>
                                  AlertDialog(
                                    actionsPadding: const EdgeInsets.all(5),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          temporary.add(Floor(
                                            floor: nameController.text,
                                            file: 'Test.png'
                                          ));
                                          Navigator.of(context).pop();


                                        },
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // nameController.dispose();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                      )
                                    ],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    backgroundColor: ColorsB.gray900,
                                    title: Column(
                                      children: const [
                                        Text(
                                          'Add entry',
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
                                      height: 150,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: TextField(
                                                style: const TextStyle(
                                                    color: Colors.white
                                                ),
                                                cursorColor: Colors.white,
                                                controller: nameController,
                                                decoration: const InputDecoration(
                                                    label: Text(
                                                      'Edit name',
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    )
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton.icon(
                                              onPressed: () {},
                                              label: Text(
                                                buttonText,
                                                style: const TextStyle(
                                                    color: Colors.white
                                                ),
                                              ),
                                              icon: const Icon(Icons.image, color: Colors.white),
                                            )
                                          ],
                                        ),

                                      ),
                                    ),
                                  ),
                            );

                          });
                        },
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  )
                ],
              )
            ),

            SizedBox(height: height * .1,),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /*
                TODO: Schimba culoarea butonului in functie de nr de schimbari
                 */

                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.check, color: Colors.white,),
                  label: Text(
                    'Update Floors',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor: ColorsB.yellow500,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      )
                  ),
                )
              ],
            )

          ],
        ),
      ),

    );
  }
}

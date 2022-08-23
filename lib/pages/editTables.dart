import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/others/floor.dart';

import '../widgets/back_navbar.dart';
import 'package:image_picker/image_picker.dart';

class EditFloors extends StatefulWidget {
  List<Floor> floors;
  final ValueChanged<List<Floor>> update;

  EditFloors({Key? key, required this.floors, required this.update}) : super(key: key);

  @override
  State<EditFloors> createState() => _EditFloorsState();
}


class _EditFloorsState extends State<EditFloors> {

  List<Floor> temporary = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> images = [];
  List<String> terms = [];

  late bool canClick;

  final ImagePicker _picker = ImagePicker();

  String? format;


  Future<void> uploadTable(Map<String, dynamic> data) async {
    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/insertfloor.php');
      final response = await http.post(url, body: {
        "data": jsonEncode(data).toString(),
      });

      print(response.statusCode);

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        print(jsondata);
        if(jsondata["error"]){
          print(jsondata["message"]);

          _scaffoldKey.currentState!.showSnackBar(
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

        }else{
          print("Upload successful");

           widget.update(temporary);
          //  widget.floors = temporary;
          //  print(widget.floors);

          _scaffoldKey.currentState!.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              content: Row(
                children: const [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 20,),
                  Text(
                    'Hooray! The update was a success!',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  )
                ],
              ),
            )
          );

          Navigator.of(context).pop();

          widget.floors = temporary;
        }
      } else {
        print("Upload failed");
        _scaffoldKey.currentState!.showSnackBar(
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


        Navigator.of(context).pop();
      }

    }
    catch(e){
      //print("Error during converting to Base64");
      _scaffoldKey.currentState!.showSnackBar(
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

}

  @override
  void dispose() {
    temporary.clear();
    images.clear();
    terms.clear();
    super.dispose();
  }

  @override
  void initState() {

    for(int i = 0; i < widget.floors.length; ++i){
      temporary.add(widget.floors[i].clone());
    }
    images = [];
    terms = [];
    canClick = false;


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
                  setState(() {
                    canClick = true;
                  });

                  var nameController = TextEditingController();
                  String buttonText = 'Choose image';

                  String? _format;
                  XFile? image;
                  File? _file;


                  var errorText;

                  var _formKey = GlobalKey<FormState>();



                  showDialog(context: context, builder: (context) {

                    return StatefulBuilder(
                      builder: (_, StateSetter setThisState) =>
                      AlertDialog(
                        actionsPadding: const EdgeInsets.all(5),
                        actions: [
                          TextButton(
                            onPressed: () {
                              //  print(json.encode(temporary));

                              if(_formKey.currentState!.validate()){
                                array[i].floor = nameController.text;
                                if(_file != null){

                                  var imageBytes = _file!.readAsBytesSync();
                                  String baseimage = base64Encode(imageBytes);

                                  if(i >= images.length){
                                    images.add(baseimage);
                                    terms.add(_format!);
                                  }
                                  else {
                                    images[i] = baseimage;
                                    terms[i] = _format!;
                                  }

                                  array[i].file = nameController.text + _format!;

                                }


                                setState(() {

                                });
                                Navigator.of(context).pop();
                              }
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: TextFormField(
                                      validator: (string) {
                                        if(string!.isEmpty){
                                          return "Field cannot be empty.";
                                        }
                                      },
                                      style: const TextStyle(
                                        color: Colors.white
                                      ),
                                      cursorColor: Colors.white,
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        errorText: errorText,
                                        label: const Text(
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
                                    onPressed: () async {

                                      try{
                                        final _image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
                                        if(_image == null) return;

                                        image = _image;
                                        _file = File(image!.path);

                                        _format = '.' + image!.name.split('.').last;

                                        buttonText = image!.name;



                                      } catch(e) {
                                        errorText = 'Error! ${e.toString()}';
                                      }

                                      setThisState(() {

                                      });


                                    },
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
                      ),
                    );

                  });
                },
                  icon: Icon(Icons.edit, color: Colors.white),
                  splashRadius: 20,
                ),
                IconButton(onPressed: () {

                  setState(() {
                    canClick = true;
                  });

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
                                            if(images.length > i){
                                              images.removeAt(i);
                                              terms.removeAt(i);
                                            }
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
      key: _scaffoldKey,
      backgroundColor: ColorsB.gray900,
      bottomNavigationBar: const BackNavbar(variation: 1,),
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          backgroundColor: ColorsB.gray900,
          automaticallyImplyLeading: false,
          toolbarHeight: height * .15,
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

                          setState(() {
                            canClick = true;
                          });

                          var nameController = TextEditingController();
                          String buttonText = 'Choose Image';

                          String? _format;
                          XFile? image;
                          File? _file;



                          var errorText;

                          var _formKey = GlobalKey<FormState>();


                          showDialog(context: context, builder: (context) {

                            return StatefulBuilder(
                              builder: (_, StateSetter setThisState) =>
                                  AlertDialog(
                                    actionsPadding: const EdgeInsets.all(5),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if(_formKey.currentState!.validate()){
                                            if(_file == null){
                                              setThisState(() {
                                                errorText = "Please select a photo.";
                                              });
                                              return;
                                            }

                                            var imageBytes = _file!.readAsBytesSync();
                                            String baseimage = base64Encode(imageBytes);

                                            images.add(baseimage);
                                            terms.add(_format!);

                                            setThisState(() {
                                              errorText = '';
                                            });
                                            temporary.add(Floor(
                                                floor: nameController.text,
                                                file: nameController.text + _format!
                                            ));

                                            setState(() {

                                            });
                                            Navigator.of(context).pop();
                                          }


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
                                        child: Form(
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          key: _formKey,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: TextFormField(
                                                  style: const TextStyle(
                                                      color: Colors.white
                                                  ),
                                                  cursorColor: Colors.white,
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                                                    errorText: errorText,
                                                      label: const Text(
                                                        'Edit name',
                                                        style: TextStyle(
                                                            color: Colors.white
                                                        ),
                                                      )
                                                  ),
                                                  validator: (element) {
                                                    if(element!.isEmpty){
                                                      return "Field cannot be empty.";
                                                    }

                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              TextButton.icon(
                                                onPressed: () async {

                                                  try{
                                                    final _image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
                                                    if(_image == null) return;

                                                    image = _image;
                                                    _file = File(image!.path);

                                                    _format = '.' + image!.name.split('.').last;

                                                    buttonText = image!.name;



                                                  } catch(e) {
                                                    errorText = 'Error! ${e.toString()}';
                                                  }

                                                  setThisState(() {

                                                  });

                                                },
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


                TextButton.icon(
                  onPressed: () async {
                    if(!canClick){
                      return;
                    }

                    // print(jsonEncode(images));
                    // //  print(jsonEncode(names));
                    // print(jsonEncode(terms));

                    Map<String, Map<String, String>> data = {};

                    for(int i = 0; i < temporary.length; i++){
                      data.addAll({"id[$i]":{"floor": temporary[i].floor, "file": temporary[i].file}});
                    }
                    for(int i = 0; i < images.length; i++){
                      data['id[$i]']!.addAll({"b64": images[i], 'name': temporary[i].floor, 'term': terms[i]});
                    }

                    print(jsonEncode(data).toString());

                    showDialog(context: context,
                      builder: (context) {
                        return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500)));
                      }
                    );

                     await uploadTable(data);




                  },
                  icon: const Icon(Icons.check, color: Colors.white,),
                  label: const Text(
                    'Update Floors',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor: canClick ? ColorsB.yellow500 : ColorsB.gray800,
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

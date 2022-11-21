import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/others/floor.dart';

import '../widgets/back_navbar.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gojdu/others/options.dart';

class EditFloors extends StatefulWidget {
  List<Floor> floors;
  String? type;
  final ValueChanged<List<Floor>> update;

  EditFloors({Key? key, required this.floors, required this.update, this.type})
      : super(key: key);

  @override
  State<EditFloors> createState() => _EditFloorsState();
}

class _EditFloorsState extends State<EditFloors> {
  List<Floor> temporary = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late bool canClick;

  final ImagePicker _picker = ImagePicker();

  String? format;

  Future<void> uploadTable(Map<String, dynamic> data) async {
    String? url1;
    Map postBody;

    widget.type == null
        ? url1 = '${Misc.link}/${Misc.appName}/insertfloor.php'
        : url1 = '${Misc.link}/${Misc.appName}/insertTimetable.php';

    widget.type == null
        ? postBody = {
            "data": jsonEncode(data).toString(),
          }
        : postBody = {"data": jsonEncode(data).toString(), "type": widget.type};

    try {
      var url = Uri.parse(url1);
      final response = await http.post(url, body: postBody);

      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //debugPrint(jsondata.toString());
        if (jsondata["error"]) {
          //debugPrint(jsondata["message"]);

          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Uh-oh! Something went wrong!',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ));
        } else {
          debugPrint("Upload successful");

          widget.update(temporary);
          //  widget.floors = temporary;
          //  debugPrint(widget.floors);

          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Hooray! The update was a success!',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ));

          Navigator.of(context).pop();

          widget.floors = temporary;
        }
      } else {
        debugPrint("Upload failed");
        ScaffoldMessenger.of(_scaffoldKey.currentContext!)
            .showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(
                width: 20,
              ),
              Text(
                'Uh-oh! Something went wrong!',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ));

        Navigator.of(context).pop();
      }
    } catch (e) {
      //debugPrint("Error during converting to Base64");
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(
              width: 20,
            ),
            Text(
              'Uh-oh! Something went wrong!',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ));
    }
  }

  @override
  void dispose() {
    temporary.clear();
    super.dispose();
  }

  Future<String> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return base64Encode(bytes);
  }

  @override
  void initState() {
    debugPrint(widget.type.toString());
    for (int i = 0; i < widget.floors.length; ++i) {
      temporary.add(widget.floors[i].clone());
      // debugPrint('${temporary[i].floor}: ${temporary[i].image.substring(0, 10)}');

    }

    canClick = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      for (int i = 0; i < widget.floors.length; ++i) {
        temporary[i].image = await networkImageToBase64(temporary[i].image);
      }

      debugPrint(temporary.toString());
    });

    super.initState();
  }

  List<DataRow> dataRows(List<Floor> array) {
    List<DataRow> temp = [];

    const TextStyle style = TextStyle(
        color: ColorsB.gray900,
        fontWeight: FontWeight.normal,
        overflow: TextOverflow.fade);

    for (var i = 0; i < array.length; i++) {
      debugPrint(array[i].floor);

      temp.insert(
          i,
          DataRow(cells: [
            DataCell(Container(
              decoration: BoxDecoration(
                  color: ColorsB.gray200,
                  borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                child: Text(
                  array[i].floor.length > 10
                      ? '${array[i].floor.substring(0, 10)}...'
                      : array[i].floor,
                  style: style,
                ),
              ),
            )),
            DataCell(Container(
              decoration: BoxDecoration(
                  color: ColorsB.gray200,
                  borderRadius: BorderRadius.circular(50)),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                  child: Text(
                    array[i].file.split('.').first.length > 10
                        ? '${array[i].file.split('.').first.substring(0, 10)}...${array[i].file.substring(array[i].file.length - 4)}'
                        : array[i].file,
                    style: style,
                  )),
            )),
            DataCell(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      canClick = true;
                    });

                    var nameController =
                        TextEditingController(text: temporary[i].floor);
                    String buttonText = 'Choose image';

                    String? _format;
                    XFile? image;
                    File? _file;

                    var errorText;

                    var _formKey = GlobalKey<FormState>();

                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (_, StateSetter setThisState) =>
                                AlertDialog(
                              actionsPadding: const EdgeInsets.all(5),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    //  debugPrint(json.encode(temporary));

                                    if (_formKey.currentState!.validate()) {
                                      array[i].floor = nameController.text;
                                      if (_file != null) {
                                        var imageBytes =
                                            _file!.readAsBytesSync();
                                        String baseimage =
                                            base64Encode(imageBytes);

                                        debugPrint('Index $i is $baseimage');

                                        // images[i] = baseimage;
                                        temporary[i].image = baseimage;
                                        // terms[i] = _format!;

                                        array[i].file =
                                            removeSpaces(nameController.text) +
                                                _format!;
                                      }

                                      setState(() {});
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // nameController.dispose();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
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
                                        color: ColorsB.yellow500, fontSize: 15),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            validator: (string) {
                                              if (string!.isEmpty) {
                                                return "Field cannot be empty.";
                                              }
                                            },
                                            style: const TextStyle(
                                                color: Colors.white),
                                            cursorColor: Colors.white,
                                            controller: nameController,
                                            decoration: InputDecoration(
                                                errorText: errorText,
                                                label: const Text(
                                                  'Edit name',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton.icon(
                                          onPressed: () async {
                                            try {
                                              final _image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                      imageQuality: 100);
                                              if (_image == null) return;

                                              image = _image;
                                              _file = File(image!.path);

                                              _format = '.' +
                                                  image!.name.split('.').last;

                                              debugPrint(_format.toString());

                                              buttonText = image!.name;
                                            } catch (e) {
                                              errorText =
                                                  'Error! ${e.toString()}';
                                            }

                                            setThisState(() {});
                                          },
                                          label: Text(
                                            buttonText,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          icon: const Icon(Icons.image,
                                              color: Colors.white),
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
                IconButton(
                    onPressed: () {
                      setState(() {
                        canClick = true;
                      });

                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: ColorsB.gray900,
                              title: Column(
                                children: const [
                                  Text(
                                    'Are you sure you want delete this entry?',
                                    style: TextStyle(
                                        color: ColorsB.yellow500, fontSize: 15),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            temporary.removeAt(i);

                                            Navigator.of(context).pop();

                                            setState(() {});

                                            //  logoff(context);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              color: ColorsB.yellow500,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            height: 50,
                                            width: 75,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              color: ColorsB.gray800,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            height: 50,
                                            width: 75,
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )));
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                    splashRadius: 20),
              ],
            ))
          ]));
    }

    return temp;
  }

  String removeSpaces(String original) {
    return original.replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final _controller = ScrollController();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorsB.gray900,
      bottomNavigationBar: const BackNavbar(
        variation: 1,
      ),
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
              children: [
                const Icon(
                  Icons.edit,
                  color: ColorsB.yellow500,
                  size: 40,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  widget.type == null
                      ? 'Edit current floors'
                      : 'Edit timetables',
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
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
                  Text("Name",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 75,
                  ),
                  Text("File",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (temporary.isNotEmpty)
              Scrollbar(
                controller: _controller,
                radius: const Radius.circular(50),
                isAlwaysShown: true,
                child: SizedBox(
                  height: height * .35,
                  child: SingleChildScrollView(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowHeight: 0,
                            dataRowHeight: 75,
                            dividerThickness: 0,
                            columns: const [
                              DataColumn(
                                  label: Text("",
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text("",
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text("",
                                      style: TextStyle(color: Colors.white))),
                            ],
                            rows: dataRows(temporary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  widget.type == null
                      ? 'No floors added. Why not add one?'
                      : "No timetables added. Why not add one?",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
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
                          border: Border.all(color: ColorsB.gray800, width: 2)),
                      child: Center(
                        child: Text(
                          widget.type == null
                              ? 'Add a floor'
                              : 'Add a timetable',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (_, StateSetter setThisState) =>
                                        AlertDialog(
                                      actionsPadding: const EdgeInsets.all(5),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (_file == null) {
                                                setThisState(() {
                                                  errorText =
                                                      "Please select a photo.";
                                                });
                                                return;
                                              }

                                              var imageBytes =
                                                  _file!.readAsBytesSync();
                                              String baseimage =
                                                  base64Encode(imageBytes);

                                              setThisState(() {
                                                errorText = '';
                                              });
                                              temporary.add(Floor(
                                                  floor: nameController.text,
                                                  file: removeSpaces(
                                                          nameController.text) +
                                                      _format!,
                                                  image: baseimage));

                                              setState(() {});
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Text(
                                            'Save',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // nameController.dispose();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.white),
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
                                                fontSize: 15),
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
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            key: _formKey,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: 150,
                                                  child: TextFormField(
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                    cursorColor: Colors.white,
                                                    controller: nameController,
                                                    decoration: InputDecoration(
                                                        errorText: errorText,
                                                        label: const Text(
                                                          'Edit name',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                    validator: (element) {
                                                      if (element!.isEmpty) {
                                                        return "Field cannot be empty.";
                                                      }
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                TextButton.icon(
                                                  onPressed: () async {
                                                    try {
                                                      final _image =
                                                          await _picker.pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery,
                                                              imageQuality:
                                                                  100);
                                                      if (_image == null)
                                                        return;

                                                      image = _image;
                                                      _file = File(image!.path);

                                                      _format = '.' +
                                                          image!.name
                                                              .split('.')
                                                              .last;
                                                      //  debugPrint(_format.toString());

                                                      buttonText = image!.name;
                                                    } catch (e) {
                                                      errorText =
                                                          'Error! ${e.toString()}';
                                                    }

                                                    setThisState(() {});
                                                  },
                                                  label: Text(
                                                    buttonText,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: const Icon(Icons.image,
                                                      color: Colors.white),
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
                )),
            SizedBox(
              height: height * .1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    if (!canClick) {
                      return;
                    }

                    // debugPrint(jsonEncode(images));
                    // //  debugPrint(jsonEncode(names));
                    // debugPrint(jsonEncode(terms));

                    Map<String, Map<String, String>> data = {};

                    for (int i = 0; i < temporary.length; i++) {
                      data.addAll({
                        "id[$i]": {
                          "floor": temporary[i].floor,
                          "file": temporary[i].file,
                          "b64": temporary[i].image
                        }
                      });
                    }

                    debugPrint(jsonEncode(data).toString());

                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorsB.yellow500)));
                        });

                    await uploadTable(data);
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    widget.type == null ? 'Update Floors' : 'Update Timetables',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor:
                          canClick ? ColorsB.yellow500 : ColorsB.gray800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

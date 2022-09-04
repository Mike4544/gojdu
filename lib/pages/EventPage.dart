import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/colors.dart';
import 'package:http/http.dart' as http;

import '../widgets/back_navbar.dart';
import '../widgets/input_fields.dart';

class PostEvent extends StatefulWidget {
  final Map gMap;


  const PostEvent({Key? key, required this.gMap}) : super(key: key);

  @override
  State<PostEvent> createState() => _PostEventState();
}

class _PostEventState extends State<PostEvent> {

  //  <---------------  Post controller ---------------->
  late TextEditingController _postController;
  late TextEditingController _postTitleController;
  late TextEditingController _locationController;

  // <---------------  Colors for the preview -------------->
  late Color? _postColor;
  late String? _className;


  // <---------------  Form key -------------->
  late final GlobalKey<FormState> _formKey;



  // Firebase stuff




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postController = TextEditingController();
    _postTitleController = TextEditingController();
    _locationController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _postColor = null;
  }

  @override
  void dispose() {
    _postController.dispose();
    _postTitleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  List<bool?> classes = [false, false, false];
  List<String> channels = [];
  String errorText = '';

  //  Image text
  String _imageText = 'Add Image';
  final ImagePicker _picker = ImagePicker();
  late XFile? image;
  File? _file;

  String? format;

  DateTime pickedDate = DateTime.now();
  bool choosen = false;


  String generateString(){
    String generated = '';

    DateTime now = DateTime.now();
    String formatedDate = DateFormat('yyyyMMddkkmm').format(now);

    generated = widget.gMap['first_name'][0] + formatedDate;

    return generated;


  }

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
          preferredSize: const Size.fromHeight(75),
          child: AppBar(
            backgroundColor: ColorsB.gray900,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(35, 50, 0, 0),
              child: Row(
                children: const [
                  Icon(Icons.event, color: ColorsB.yellow500, size: 40,),
                  SizedBox(width: 20,),
                  Text(
                    'Create an event',
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
                    'Event details',
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
                      if(!choosen){
                        return 'Please choose a date.';
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                  InputField(fieldName: 'Choose a location', isPassword: false, errorMessage: '', controller: _locationController, isEmail: false, icon: const Icon(Icons.location_on, color: Colors.white,),),
                  const SizedBox(height: 50,),
                  const Text(
                    'Choose a date',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextButton.icon(
                    icon: Icon(Icons.location_on, color: choosen
                      ? ColorsB.yellow500
                      : Colors.white,),
                    label: Text(
                      choosen
                          ? DateFormat('dd/MM/yyyy').format(pickedDate)
                          : 'Choose a date',
                      style: TextStyle(
                        color: choosen ? ColorsB.yellow500 : Colors.white,
                        fontSize: 15
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: pickedDate,
                          lastDate: DateTime(2101, 12, 31)
                      );

                      if(picked != null && picked != pickedDate){
                        setState(() {
                          pickedDate = picked;
                          choosen = true;
                        });
                      }


                    },
                  ),

                  const SizedBox(height: 10),
                  Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),

                  ),

                  const SizedBox(height: 25),
                  ExpansionTile(

                    collapsedIconColor: ColorsB.gray800,
                    iconColor: ColorsB.yellow500,
                    title: const Text(
                      'Header Image - Optional',
                      style: TextStyle(
                        color: ColorsB.yellow500,
                      ),
                    ),
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          //  Image picker things

                          try{
                            final _image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
                            if(_image == null) return;

                            image = _image;
                            _file = File(image!.path);

                            format = image!.name.split('.').last;

                            setState(() {
                              _imageText = image!.name;
                            });
                          } catch(e) {
                            setState(() {
                              _imageText = 'Error! ${e.toString()}';
                            });
                          }

                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                        ),
                        label: Text(
                          _imageText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.white,

                          ),
                        ),
                      )
                    ],
                  ),


                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {

                          if(_formKey.currentState!.validate()){

                            showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ColorsB.yellow500),),));
                            setState(() {
                              errorText = '';
                            });

                            String name = generateString();

                            bool imgSub = false;

                            try {


                              if(!imgSub && _file != null){
                                await uploadImage(_file, name);
                                imgSub = true;
                              }
                              //print(channels[i]);

                              //print(_file);

                              var url = Uri.parse('https://cnegojdu.ro/GojduApp/insertEvent.php');
                              final response;
                              if(_file != null){
                                response = await http.post(url, body: {
                                  "title": _postTitleController.value.text,
                                  "location": _locationController.value.text,
                                  "date":  DateFormat('dd/MM/yyyy').format(pickedDate),
                                  "body": _postController.value.text,
                                  "owner": widget.gMap["first_name"] + " " + widget.gMap["last_name"],
                                  "link": "https://cnegojdu.ro/GojduApp/imgs/$name.$format"
                                });
                              }
                              else {
                                response = await http.post(url, body: {
                                  "title": _postTitleController.value.text,
                                  "location": _locationController.value.text,
                                  "date":  DateFormat('dd/MM/yyyy').format(pickedDate),
                                  "body": _postController.value.text,
                                  "owner": widget.gMap["first_name"] + " " + widget.gMap["last_name"],
                                  "link": ""
                                });
                              }
                              if (response.statusCode == 200) {
                                var jsondata = json.decode(response.body);
                                print(jsondata);
                                if (jsondata["error"]) {
                                  //  Navigator.of(context).pop();
                                } else {
                                  if (jsondata["success"]){

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.green,
                                          content: Row(
                                            children: const [
                                              Icon(Icons.check, color: Colors.white),
                                              SizedBox(width: 20,),
                                              Text(
                                                'Hooray! A new event was born.',
                                                style: TextStyle(
                                                    color: Colors.white
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                    );

                                    Navigator.of(context).pop();


                                    //  Navigator.of(context).pop();
                                  }
                                  else
                                  {
                                    //print(jsondata["message"]);
                                  }
                                }
                              }
                            } catch (e) {
                              //print(e);
                              //Navigator.of(context).pop();
                            }

                            //TODO: There is some unhandled exception and I have no fucking idea where. - Mihai
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
                          backgroundColor: _postController.text.isEmpty || _postTitleController.text.isEmpty || channels.isEmpty ? ColorsB.gray800 : ColorsB.yellow500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
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


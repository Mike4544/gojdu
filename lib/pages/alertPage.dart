import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../others/colors.dart';

import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

// Firebase for messaging
import 'package:firebase_messaging/firebase_messaging.dart';

import '../widgets/back_navbar.dart';
import '../widgets/input_fields.dart';

import 'package:path/path.dart' as path;


class AlertPage extends StatefulWidget {
  Map gMap;

  AlertPage({Key? key, required this.gMap}) : super(key: key);

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {

  //  <---------------  Post controller ---------------->
  late TextEditingController _postController;
  late TextEditingController _postTitleController;

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
    _formKey = GlobalKey<FormState>();
    _postColor = null;
  }

  @override
  void dispose() {
    _postController.dispose();
    _postTitleController.dispose();
    super.dispose();
  }

  String errorText = '';

  //  Image text
  String _imageText = 'Add Image';
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

  Future<void> sendReport(File? file, String title, String description, var fileFormat) async {
    try{

      String? baseimage;

      if(file != null){
        var imageBytes = file.readAsBytesSync();
        baseimage = base64Encode(imageBytes);
      }

      print(fileFormat.toString());

      var url = Uri.parse('https://cnegojdu.ro/GojduApp/notifications.php');
      final response = await http.post(url, body: {
        "action": "Report",
        "channel": "Admins",
        "fterm": fileFormat.toString(),
         "image": baseimage.toString(),   // FIXME: Upload it on the server and be done with it
        "rtitle": title,
        "rdesc": description,
        "rowner": '${widget.gMap['first_name']} ${widget.gMap['last_name']}',
        "time": DateTime.now().toIso8601String()
      });

      // print(response.statusCode);
      //       // print(response.body);
      //  print(DateTime.now().toIso8601String());

      if(response.statusCode == 200){
        var jsondata = jsonDecode(response.body);

        print(jsondata);

        //  Navigator.of(context).pop();
      }
      else {
        print('Error!');
      }





    }
    catch(e){
      print("Exception! $e");
    }


  }





  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(fieldName: 'Title', isPassword: false, errorMessage: '', controller: _postTitleController, isEmail: false, lengthLimiter: 30,),
              const SizedBox(height: 50,),
              const Text(
                'Feedback',
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
                },
                onChanged: (s) {
                  setState(() {

                  });
                },
              ),

              const SizedBox(height: 50),
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
                          _imageText = path.basename(_file!.path);
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

                         print(_postTitleController.text);
                         print(_postController.text);

                        await sendReport(_file, _postTitleController.text, _postController.text, format);


                        bool imgSub = false;



                        Navigator.of(context).pop();

                        //TODO: There is some unhandled exception and I have no fucking idea where. - Mihai
                      }

                    },
                    child: const Text(
                      'Send',
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
                      backgroundColor: _postController.text.isEmpty || _postTitleController.text.isEmpty ? ColorsB.gray800 : ColorsB.yellow500,
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
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../others/colors.dart';
import 'package:http/http.dart' as http;

import '../widgets/back_navbar.dart';
import '../widgets/input_fields.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocode/geocode.dart';

import 'package:location/location.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:gojdu/others/options.dart';

class AddOffer extends StatefulWidget {
  final Map gMap;

  const AddOffer({Key? key, required this.gMap}) : super(key: key);

  @override
  State<AddOffer> createState() => _AddOfferState();
}

class _AddOfferState extends State<AddOffer> {
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
    discountController.dispose();
    companyName.dispose();
    shortDescription.dispose();
    super.dispose();
  }

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

  String locationButton = 'Please select a location';

  late LatLng coordsForLink;

  Color? choosenColor;

  File? logo;
  String? logoString;
  String? logoFormat;

  final discountController = TextEditingController();
  final shortDescription = TextEditingController();
  final companyName = TextEditingController();

  String generateString() {
    String generated = '';

    DateTime now = DateTime.now();
    String formatedDate = DateFormat('yyyyMMddkkmm').format(now);

    generated = widget.gMap['first_name'][0] + formatedDate;

    return generated;
  }

  Future<void> uploadImage(File? file, String name, String _format) async {
    try {
      if (file == null) {
        return;
      }
      var imageBytes = file.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);

      var url = Uri.parse('${Misc.link}/${Misc.appName}/image_upload.php');
      final response = await http.post(url,
          body: {"image": baseimage, "name": name, "format": _format});

      print('Image: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["error"]) {
          //print(jsondata["msg"]);
        } else {
          //print("Upload successful");
        }
      } else {
        //print("Upload failed");
      }
    } catch (e) {
      //print("Error during converting to Base64");
      throw Exception(e);
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
        bottomNavigationBar: const BackNavbar(
          variation: 1,
        ),
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
                  Icon(
                    Icons.local_activity_rounded,
                    color: ColorsB.yellow500,
                    size: 40,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Create an offer',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
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
                  InputField(
                    fieldName: 'Discount',
                    isPassword: false,
                    errorMessage: '',
                    controller: discountController,
                    isEmail: false,
                    lengthLimiter: 20,
                    label: 'Eg: 25%',
                  ),
                  const SizedBox(height: 10),
                  InputField(
                    fieldName: 'Short description',
                    isPassword: false,
                    errorMessage: '',
                    controller: shortDescription,
                    isEmail: false,
                    lengthLimiter: 45,
                    label: 'Eg: Pentru produsele din gama X.',
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Long description',
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
                          )),
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
                      if (!choosen) {
                        return 'Please choose a date.';
                      }
                      if (locationButton == 'Please select a location') {
                        return 'Please select a location.';
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Choose your location',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.location_on_outlined,
                      color: choosen ? ColorsB.yellow500 : Colors.white,
                    ),
                    label: Text(
                      locationButton,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const FullScreenMap()));

                      if (!mounted) return;

                      if (result == null) return;

                      locationButton = result['location'];
                      coordsForLink = result['coords'];

                      setState(() {});

                      print(locationButton);
                      print(coordsForLink);
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Choose the end date',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: choosen ? ColorsB.yellow500 : Colors.white,
                    ),
                    label: Text(
                      choosen
                          ? DateFormat('dd/MM/yyyy').format(pickedDate)
                          : 'Choose a date',
                      style: TextStyle(
                          color: choosen ? ColorsB.yellow500 : Colors.white,
                          fontSize: 15),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: pickedDate,
                          lastDate: DateTime(2101, 12, 31));

                      if (picked != null && picked != pickedDate) {
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
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Choose your logo',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (logo == null)
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          final _image = await _picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 25);
                          if (_image == null) return;

                          //logo = _image;

                          CroppedFile? croppedFile =
                              await ImageCropper().cropImage(
                            sourcePath: _image.path,
                            aspectRatio:
                                const CropAspectRatio(ratioX: 1, ratioY: 1),
                            maxHeight: 1080,
                            maxWidth: 1080,
                            compressFormat: ImageCompressFormat.png,
                          );

                          if (croppedFile == null) return;

                          logo = File(croppedFile.path);

                          logoFormat = "png";

                          logoString = base64Encode(logo!.readAsBytesSync());

                          setState(() {});
                        } catch (e) {
                          setState(() {
                            //  _imageText = 'Error! ${e.toString()}';
                          });
                        }
                      },
                      label: const Text(
                          'Choose a logo (MUST have transparency)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal)),
                      icon: const Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    )
                  else
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        Image.memory(base64Decode(logoString!))
                                            .image)),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                try {
                                  final _image = await _picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 25);
                                  if (_image == null) return;

                                  //logo = _image;

                                  CroppedFile? croppedFile =
                                      await ImageCropper().cropImage(
                                    sourcePath: _image.path,
                                    maxHeight: 1080,
                                    maxWidth: 1080,
                                    compressQuality: 75,
                                    compressFormat: ImageCompressFormat.png,
                                  );

                                  if (croppedFile == null) return;

                                  logo = File(croppedFile.path);

                                  logoFormat = "png";

                                  logoString =
                                      base64Encode(logo!.readAsBytesSync());

                                  setState(() {});
                                } catch (e) {
                                  setState(() {
                                    //  _imageText = 'Error! ${e.toString()}';
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  InputField(
                    fieldName: 'Enter your company\'s name',
                    isPassword: false,
                    errorMessage: '',
                    controller: companyName,
                    isEmail: false,
                    lengthLimiter: 20,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Choose a color',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: ColorsB.yellow500,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: Icon(Icons.format_paint_rounded,
                        color: choosenColor ?? Colors.white),
                    label: Text(
                      choosenColor == null
                          ? 'Please choose a color.'
                          : choosenColor.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      var pickerColor = Colors.white;

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: (nColor) {
                                setState(() {
                                  pickerColor = nColor;
                                });
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                setState(() => choosenColor = pickerColor);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
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

                          try {
                            final _image = await _picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 25);
                            if (_image == null) return;

                            image = _image;
                            _file = File(image!.path);

                            format = image!.name.split('.').last;

                            setState(() {
                              _imageText = image!.name;
                            });
                          } catch (e) {
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
                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                                context: context,
                                builder: (context) => const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ColorsB.yellow500),
                                      ),
                                    ));
                            setState(() {
                              errorText = '';
                            });

                            String name = generateString();

                            bool imgSub = false;

                            try {
                              if (!imgSub && _file != null) {
                                await uploadImage(_file, name, format!);
                                imgSub = true;
                              }
                              var name2 = companyName.text
                                  .replaceAll(' ', '_')
                                  .replaceAll('\'', '');
                              print(name2);
                              print('Logo ${logo == null}');

                              await uploadImage(logo, name2, "png");
                              //print(channels[i]);

                              //print(_file);

                              var url = Uri.parse(
                                  '${Misc.link}/${Misc.appName}/addOffer.php');
                              final response;
                              if (_file != null) {
                                response = await http.post(url, body: {
                                  "d": discountController.text,
                                  "ld": _postController.value.text,
                                  "sd": shortDescription.value.text,
                                  "ow": widget.gMap["first_name"] +
                                      " " +
                                      widget.gMap["last_name"],
                                  "cn": companyName.text,
                                  "loc": locationButton,
                                  "ml":
                                      "https://www.google.com/maps/search/?api=1&query=${coordsForLink.latitude},${coordsForLink.longitude}",
                                  "date": DateFormat('dd/MM/yyyy')
                                      .format(pickedDate),
                                  "himg":
                                      "${Misc.link}/${Misc.appName}/imgs/$name.$format",
                                  "limg":
                                      "${Misc.link}/${Misc.appName}/imgs/${companyName.text.replaceAll(' ', '_').replaceAll('\'', '')}.png",
                                  "col": choosenColor.toString(),
                                });
                              } else {
                                response = await http.post(url, body: {
                                  "d": discountController.text,
                                  "ld": _postController.value.text,
                                  "sd": shortDescription.value.text,
                                  "ow": widget.gMap["first_name"] +
                                      " " +
                                      widget.gMap["last_name"],
                                  "cn": companyName.text,
                                  "loc": locationButton,
                                  "ml":
                                      "https://www.google.com/maps/search/?api=1&query=${coordsForLink.latitude},${coordsForLink.longitude}",
                                  "date": DateFormat('dd/MM/yyyy')
                                      .format(pickedDate),
                                  "himg": "",
                                  "limg":
                                      "${Misc.link}/${Misc.appName}/imgs/${companyName.text.replaceAll(' ', '_').replaceAll('\'', '')}.png",
                                  "col": choosenColor.toString(),
                                });
                              }
                              print(response.statusCode);
                              if (response.statusCode == 200) {
                                var jsondata = json.decode(response.body);
                                print(jsondata);
                                if (jsondata["error"]) {
                                  //  Navigator.of(context).pop();
                                } else {
                                  if (jsondata["success"]) {
                                    try {
                                      var ulr2 = Uri.parse(
                                          '${Misc.link}/${Misc.appName}/notifications.php');
                                      final response2 = await http.post(ulr2,
                                          body: {
                                            "action": "Offers",
                                            "channel": "Students"
                                          });

                                      print(response2.statusCode);

                                      if (response2.statusCode == 200) {
                                        var jsondata2 =
                                            json.decode(response2.body);
                                        print(jsondata2);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.green,
                                          content: Row(
                                            children: const [
                                              Icon(Icons.check,
                                                  color: Colors.white),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                'Hooray! A new offer was born.',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ));

                                        Navigator.of(context).pop();
                                        //  print(jsondata2);
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      //print(e);
                                    }

                                    //  Navigator.of(context).pop();
                                  } else {
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          backgroundColor: _postController.text.isEmpty ||
                                  _postTitleController.text.isEmpty
                              ? ColorsB.gray800
                              : ColorsB.yellow500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenMap extends StatefulWidget {
  const FullScreenMap({Key? key}) : super(key: key);

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  LatLng currentPosition = LatLng(46.4867, 22.5582);
  LatLng selectedPosition = LatLng(0, 0);
  Address? address;

  late String city, road, county;

  Future _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    Location location = Location();

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print(serviceEnabled);
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      //  return Future.error('Location services are disabled.');
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return Future.error('Location is disabled.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var position = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });

    return 1;
  }

  late final Future _getPos = _getUserLocation();

  late List<Marker> _markers;
  bool selected = false;
  bool putDown = false;

  @override
  void initState() {
    _markers = [];
    selected = false;
    super.initState();
  }

  @override
  void dispose() {
    _markers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select a location'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Flexible(
            child: FutureBuilder(
                future: _getPos,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        FlutterMap(
                          options: MapOptions(
                              center: currentPosition,
                              onTap: (_, coords) async {
                                _markers.clear();
                                //  print(coords);
                                _markers.insert(
                                    0,
                                    Marker(
                                        point: coords,
                                        rotate: true,
                                        builder: (context) => const Icon(
                                              Icons.pin_drop,
                                              size: 40,
                                              color: ColorsB.yellow500,
                                            )));

                                selectedPosition = coords;
                                selected = true;
                                print(coords);

                                var geoCode = GeoCode();

                                address = await geoCode.reverseGeocoding(
                                    latitude: selectedPosition.latitude,
                                    longitude: selectedPosition.longitude);
                                // road = address!.streetAddress!;
                                // city = address!.city!;
                                print(address);

                                setState(() {});
                              }),
                          children: [
                            TileLayer(
                              minZoom: 1,
                              maxZoom: 18,
                              backgroundColor: ColorsB.gray900,
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: _markers,
                            )
                          ],
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                          bottom: !selected
                              ? -1 * height * .5
                              : putDown
                                  ? -1 * height * .25
                                  : 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaY: 7,
                                  sigmaX: 7,
                                ),
                                child: Container(
                                    height: height * .25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white24),
                                      color: Colors.white12,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            putDown = !putDown;
                                            setState(() {});
                                          },
                                          child: Icon(
                                            !putDown
                                                ? Icons.arrow_drop_down
                                                : Icons.arrow_drop_up,
                                            color: ColorsB.gray900,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                child: Text(
                                                  address != null
                                                      ? '${address!.city!}, ${address!.streetAddress}'
                                                      : '',
                                                  style: const TextStyle(
                                                      color: ColorsB.gray900,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        selectedPosition !=
                                                                LatLng(0, 0)
                                                            ? 'Lat: ${selectedPosition.latitude.toString().substring(0, 6)}'
                                                            : '',
                                                        style: const TextStyle(
                                                            color:
                                                                ColorsB.gray900,
                                                            fontSize: 20),
                                                      ),
                                                      Text(
                                                        selectedPosition !=
                                                                LatLng(0, 0)
                                                            ? 'Long: ${selectedPosition.longitude.toString().substring(0, 6)}'
                                                            : '',
                                                        style: const TextStyle(
                                                            color:
                                                                ColorsB.gray900,
                                                            fontSize: 20),
                                                      )
                                                    ],
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.pop(context, {
                                                        'location':
                                                            '${address!.city!}, ${address!.streetAddress}',
                                                        'coords':
                                                            selectedPosition
                                                      });
                                                    },
                                                    label: const Text(
                                                      'Select Location',
                                                      style: TextStyle(
                                                        color: ColorsB.gray900,
                                                      ),
                                                    ),
                                                    icon: const Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        color: ColorsB.gray900),
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            ColorsB.yellow500,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        360))),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}

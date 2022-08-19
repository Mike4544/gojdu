import 'dart:async';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';




//ignore: must_be_immutable
class Post extends StatefulWidget {

  var title, descriptions, owners, link;
  var color;
  var likesBool, dislikes;
  var likes, ids;
  Function(BuildContext context, String title, String description, String author, Color color, String link, int? likes, int? ids, bool? dislikes, bool? likesBool, StreamController<int?> contrL, StreamController<bool> contrLB, StreamController<bool> contrDB) hero;
  var globalMap;
  var context;
  var update;


  Post({Key? key,
    required this.title,
    required this.color,
    required this.descriptions, required this.owners,
    required this.link,
    required this.hero,
    required this.globalMap,
    this.likesBool,
    this.dislikes,
    this.likes,
    this.ids,
    required this.context,
  }) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class _PostState extends State<Post> {

  // <------------------- Like, Unlike, Dislike, Undislike functions ------------------>
  Future<void> like(int id, int uid) async{
    //print(ids);

    if(widget.dislikes == true){
      undislike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes + 1;
      widget.likesBool = true;

      widget.dislikes = false;
      //widget.update();
    });

    try{

      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          print(jsondata['message']);
        }

        if(jsondata['success']){
          print(jsondata);
        }
      }

    } catch(e){
      print(e);
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> unlike(int id, int uid) async{
    //print(ids);

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;

      //widget.update();

    });

    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          print(jsondata['message']);
        }

        if(jsondata['success']){
          print(jsondata);
        }
      }

    } catch(e){
      print(e);
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> dislike(int id, int uid) async{
    //print(ids);

    if(widget.likesBool == true){
      unlike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;

      widget.dislikes = true;

      //widget.update();
    });

    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'DISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          print(jsondata['message']);
        }

        if(jsondata['success']){
          print(id);
          print(jsondata);
        }
      }

    } catch(e){
      print(e);
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> undislike(int id, int uid) async{
    //print(ids);

    setState(() {
      widget.likes = widget.likes! + 1;

      widget.dislikes = false;

      //widget.update();
    });

    try{
      var url = Uri.parse('https://cnegojdu.ro/GojduApp/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNDISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if(response.statusCode == 200){
        var jsondata = json.decode(response.body);
        if(jsondata['error']){
          print(jsondata['message']);
        }

        if(jsondata['success']){
          print(jsondata);
        }
      }

    } catch(e){
      print(e);
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontFamily: 'Nunito'
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }


  @override
  void initState() {
    _controllerLikes.stream.listen((event) {
      setState(() {
        widget.likes = event;
      });
    });
    _controllerLBool.stream.listen((event) {
      setState(() {
        widget.likesBool = event;
      });
    });
    _controllerDBool.stream.listen((event) {
      setState(() {
        widget.dislikes = event;
      });
    });

    super.initState();
  }

  final StreamController<int?> _controllerLikes = StreamController<int?>();
  final StreamController<bool> _controllerLBool = StreamController<bool>();
  final StreamController<bool> _controllerDBool = StreamController<bool>();


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
          width: screenWidth * 0.75,
          height: 200,
          child: Stack(
              children: [
                Container(                         // Student containers. Maybe get rid of the hero
                  width: screenWidth * 0.75,
                  height: 200,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(
                        50),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => widget.hero(widget.context, widget.title, widget.descriptions, widget.owners, widget.color!, widget.link, widget.likes, widget.ids, widget.dislikes, widget.likesBool, _controllerLikes, _controllerLBool, _controllerDBool),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              'by ' + widget.owners,     //  Hard coded!!
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 25,),

                            Flexible(
                              child: Text(
                                widget.descriptions,
                                overflow: TextOverflow
                                    .ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.25),
                                    fontSize: 15,
                                    fontWeight: FontWeight
                                        .bold
                                ),
                              ),
                            ),



                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 50,
                  child: widget.globalMap['verification'] != 'Pending'
                      ? Row(
                        children: [
                        //   Like and dislike
                        IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            Icons.thumb_up,
                            color: widget.likesBool == true ? Colors.white : Colors.white.withOpacity(0.5),
                            size: 25,
                          ),
                          onPressed: () {
                            widget.likesBool == true ?
                            unlike(widget.ids!, widget.globalMap['id'])
                                : like(widget.ids!, widget.globalMap['id']);
                          },
                        ),
                        Text(
                          widget.likes.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            Icons.thumb_down,
                            color: widget.dislikes == true ? Colors.white : Colors.white.withOpacity(0.5),
                            size: 25,
                          ),
                          onPressed: () {

                            widget.dislikes == true ?
                            undislike(widget.ids!, widget.globalMap['id'])
                                : dislike(widget.ids!, widget.globalMap['id']);
                            //
                          },
                        ),
                      ]
                  )
                      : const SizedBox(),
                )
              ]
          )
      ),
    );
  }
}

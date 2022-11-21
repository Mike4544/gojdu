import 'dart:async';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/options.dart';
import 'package:gojdu/pages/news.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gojdu/others/colors.dart';

import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;

//ignore: must_be_immutable
class Post extends StatefulWidget {
  int id;
  var title, descriptions, owners, link;
  var color;
  var likesBool, dislikes;
  var likes, ids;
  int ownerID;
  void Function() delete;
  String admin;
  Function(
      BuildContext context,
      String title,
      int id,
      String description,
      String author,
      int oid,
      Color color,
      String link,
      int? likes,
      int? ids,
      bool? dislikes,
      bool? likesBool,
      StreamController<int?> contrL,
      StreamController<bool> contrLB,
      StreamController<bool> contrDB) hero;
  var globalMap;
  var context;
  var update;

  Post({
    Key? key,
    required this.id,
    required this.title,
    required this.color,
    required this.descriptions,
    required this.owners,
    required this.ownerID,
    required this.link,
    required this.hero,
    required this.globalMap,
    this.likesBool,
    this.dislikes,
    this.likes,
    this.ids,
    required this.admin,
    required this.delete,
    required this.context,
  }) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class _PostState extends State<Post> {
  // <------------------- Like, Unlike, Dislike, Undislike functions ------------------>
  Future<void> like(int id, int uid) async {
    //debugPrint(ids);

    if (widget.dislikes == true) {
      undislike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes + 1;
      widget.likesBool = true;

      widget.dislikes = false;
      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> unlike(int id, int uid) async {
    //debugPrint(ids);

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> dislike(int id, int uid) async {
    //debugPrint(ids);

    if (widget.likesBool == true) {
      unlike(id, uid);
    }

    setState(() {
      widget.likes = widget.likes! - 1;
      widget.likesBool = false;

      widget.dislikes = true;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'DISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          debugPrint(id.toString());
          //debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> undislike(int id, int uid) async {
    //debugPrint(ids);

    setState(() {
      widget.likes = widget.likes! + 1;

      widget.dislikes = false;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/likes.php');
      final response = await http.post(url, body: {
        'action': 'UNDISLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
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

  Widget _deleteButton() {
    if (widget.admin == 'Admin' || widget.ownerID == globalMap['id']) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
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
                            'Are you sure you want delete this post?',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    widget.delete();

                                    Navigator.of(context).pop();

                                    setState(() {});

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
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
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
                                    child: const Icon(
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
          ),
          SizedBox(
            width: screenWidth * .05,
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget actionBar() => Visibility(
        visible: globalMap['verification'] != "Pending",
        child: Container(
          height: 50,
          constraints: BoxConstraints(maxWidth: screenWidth * .5),
          decoration: BoxDecoration(
              color: ColorsB.gray800, borderRadius: BorderRadius.circular(50)),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: FittedBox(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _deleteButton(),
                    Row(children: [
                      //   Like and dislike
                      IconButton(
                        splashRadius: 20,
                        icon: Icon(
                          Icons.thumb_up,
                          color: widget.likesBool == true
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: 25,
                        ),
                        onPressed: () {
                          widget.likesBool == true
                              ? unlike(widget.ids!, widget.globalMap['id'])
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
                          color: widget.dislikes == true
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: 25,
                        ),
                        onPressed: () {
                          widget.dislikes == true
                              ? undislike(widget.ids!, widget.globalMap['id'])
                              : dislike(widget.ids!, widget.globalMap['id']);
                          //
                        },
                      ),
                    ])
                  ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: screenWidth * 0.75,
                height: 200,
                child: Container(
                  // Student containers. Maybe get rid of the hero
                  // width: screenWidth * 0.65,
                  // height: 200,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => widget.hero(
                          widget.context,
                          widget.title,
                          widget.id,
                          widget.descriptions,
                          widget.owners,
                          widget.ownerID,
                          widget.color!,
                          widget.link,
                          widget.likes,
                          widget.ids,
                          widget.dislikes,
                          widget.likesBool,
                          _controllerLikes,
                          _controllerLBool,
                          _controllerDBool),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'by ${widget.owners.split(' ').first} ${widget.owners.split(' ').last[0]}.', //  Hard coded!!
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Flexible(
                              child: Text(
                                widget.descriptions,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.25),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            actionBar()
          ],
        ));
  }
}

class Comment extends StatefulWidget {
  final int id;
  final int ownerId;
  final String owner;
  final String body;
  int likes;
  bool likesBool;
  final Function delete;
  final DateTime timePosted;
  final Map globalMap;
  final int commentsNo;

  Comment(
      {Key? key,
      required this.id,
      required this.likes,
      required this.likesBool,
      required this.ownerId,
      required this.body,
      required this.owner,
      required this.delete,
      required this.globalMap,
      required this.commentsNo,
      required this.timePosted})
      : super(key: key);

  @override
  State<Comment> createState() => _CommentState();

  static Comment fromJson(Map json, Map gMap, Function delete) => Comment(
        id: json['id'],
        likes: json['likes'],
        likesBool: json['userLiked'] >= 1,
        ownerId: json['ownerID'],
        owner: json['owner'],
        body: json['body'],
        delete: delete,
        globalMap: gMap,
        commentsNo: 0,
        timePosted: DateTime.parse(json['time']),
      );

  static Future<void> deleteComment(
      BuildContext context, int id, int index, List<Comment> comments) async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/deleteComment.php');
      final response = await http.post(url, body: {"id": id.toString()});

      debugPrint(id.toString());
      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        debugPrint(response.body);

        var jsondata = json.decode(response.body);
        //  //debugPrint(jsondata.toString());

        if (jsondata['error']) {
          debugPrint('Errored');

          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   behavior: SnackBarBehavior.floating,
          //   backgroundColor: Colors.red,
          //   content: Row(
          //     children: const [
          //       Icon(Icons.error, color: Colors.white),
          //       SizedBox(
          //         width: 20,
          //       ),
          //       Text(
          //         'Uh-oh! Something went wrong!',
          //         style: TextStyle(color: Colors.white),
          //       )
          //     ],
          //   ),
          // ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Hooray! The comment was deleted.',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ));

          comments.removeAt(index);
        }
      } else {
        debugPrint("Deletion failed.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.red,
      //   content: Row(
      //     children: const [
      //       Icon(Icons.error, color: Colors.white),
      //       SizedBox(
      //         width: 20,
      //       ),
      //       Text(
      //         'Uh-oh! Something went wrong!',
      //         style: TextStyle(color: Colors.white),
      //       )
      //     ],
      //   ),
      // ));

      debugPrint(e.toString());
    }
  }

  static Future<int> getMaxId() async {
    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/getMaxInsert.php');
      final response = await http.post(url, body: {"table": 'comments'});

      debugPrint('Id');
      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //debugPrint(jsondata.toString());

        return jsondata['id']['ID'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return 1;
  }
}

class _CommentState extends State<Comment> with SingleTickerProviderStateMixin {
  late bool _isnt404;

  Future<void> like(int id, int uid) async {
    //debugPrint(ids);

    // if (widget.dislikes == true) {
    //   undislike(id, uid);
    // }

    setState(() {
      widget.likes = widget.likes + 1;
      widget.likesBool = true;

      //  widget.dislikes = false;
      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/commentLikes.php');
      final response = await http.post(url, body: {
        'action': 'LIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> unlike(int id, int uid) async {
    //debugPrint(ids);

    setState(() {
      widget.likes = widget.likes - 1;
      widget.likesBool = false;

      //widget.update();
    });

    try {
      var url = Uri.parse('${Misc.link}/${Misc.appName}/commentLikes.php');
      final response = await http.post(url, body: {
        'action': 'UNLIKE',
        'id': id.toString(),
        'uid': uid.toString(),
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['error']) {
          //debugPrint(jsondata['message']);
        }

        if (jsondata['success']) {
          //debugPrint(jsondata.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<int> _getImgStatus(String avatarImg) async {
    var response = await http.get(Uri.parse(avatarImg));

    _isnt404 = response.statusCode != 404;

    return response.statusCode;
  }

  Widget _CircleAvatar(String avatarImg) {
    // late var _sCode = await http.get(Uri.parse(avatarImg);
    late var _sCode = _getImgStatus(avatarImg);

    return FutureBuilder(
      future: _sCode,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_isnt404) {
            return CircleAvatar(
              backgroundImage: Image.network(
                avatarImg,
              ).image,
            );
          } else {
            return CircleAvatar(
              radius: 17.5,
              child: Text(widget.owner[0]),
            );
          }
        } else if (snapshot.hasError) {
          return CircleAvatar(
            radius: 17.5,
            child: Text(widget.owner[0]),
          );
        } else {
          return const CircleAvatar(
            radius: 17.5,
            backgroundColor: Colors.white,
          );
        }
      },
    );
  }

  bool isMinified = true;

  Widget mainCommentBody() => Container(
        constraints: const BoxConstraints(minHeight: 75),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CircleAvatar(
                '${Misc.link}/${Misc.appName}/profiles/${widget.ownerId}.jpg'),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.owner.split(' ').first} ${widget.owner.split(' ').last[0]}.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMinified = !isMinified;
                      });
                    },
                    child: Text(
                        isMinified && widget.body.length > 50
                            ? "${widget.body.substring(0, 50)}...(See More)"
                            : widget.body.length < 50
                                ? widget.body
                                : widget.body + ' (See Less)',
                        softWrap: true,
                        style:
                            TextStyle(color: Colors.white, fontSize: 17.5.sp)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 50,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text(timeago.format(widget.timePosted.toUtc()),
                              style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold)),

                          // Row(
                          //   children: [
                          //     // Text(
                          //     //     timeago.format(DateTime.now().subtract(
                          //     //         Duration(
                          //     //             days: DateTime.now().day -
                          //     //                 widget.timePosted.day,
                          //     //             hours: DateTime.now().hour -
                          //     //                 widget.timePosted.hour,
                          //     //             minutes: DateTime.now().minute -
                          //     //                 widget.timePosted.minute,
                          //     //             seconds: DateTime.now().second -
                          //     //                 widget.timePosted.second))),
                          //     //     style: TextStyle(
                          //     //         color: Colors.white24,
                          //     //         fontSize: 12.5.sp,
                          //     //         fontWeight: FontWeight.bold)),

                          //     //  Adding the reply for the next time

                          //     // TextButton(
                          //     //   onPressed: () {
                          //     //     reply();
                          //     //   },
                          //     //   child: Text('Reply',
                          //     //       style: TextStyle(
                          //     //           color: Colors.white24,
                          //     //           fontSize: 12.5.sp,
                          //     //           fontWeight: FontWeight.bold)),
                          //     // ),
                          //   ],
                          // ),
                          // TextButton.icon(
                          //   onPressed: () {},
                          //   icon:
                          // ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  if (widget.likesBool) {
                                    unlike(widget.id, globalMap['id']);
                                  } else {
                                    like(widget.id, globalMap['id']);
                                  }
                                },
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: widget.likesBool
                                      ? Colors.white
                                      : Colors.white24,
                                ),
                                label: Text(
                                  widget.likes.toString(),
                                  style: TextStyle(
                                      color: widget.likesBool
                                          ? Colors.white
                                          : Colors.white24),
                                ),
                              ),
                              Visibility(
                                  visible:
                                      widget.ownerId == widget.globalMap['id'],
                                  child: TextButton(
                                    onPressed: () {
                                      widget.delete();
                                    },
                                    child: Text('Delete',
                                        style: TextStyle(
                                            color: Colors.white24,
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );

  void reply() {
    _slideAnimCtrl.forward();
    setState(() {
      isReplying = true;
    });

    replyNode.requestFocus();
  }

  void stopReply() {
    _slideAnimCtrl.reverse();

    setState(() {
      isReplying = false;
    });
  }

  final TextEditingController _replyController = TextEditingController();

  bool isReplying = false;
  FocusNode replyNode = FocusNode();

  Widget replyCommentBody() => Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            stopReply();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          //  Add a bool for isReplying
          height: isReplying ? 50 : 0,
          child: Row(children: [
            Expanded(
              flex: 3,
              child: TextField(
                keyboardType: TextInputType.text,
                controller: _replyController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                focusNode: replyNode,
                maxLength: 150,
                //  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Reply to @${widget.owner}",
                  counterText: "",
                  errorBorder: InputBorder.none,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: const TextStyle(
                      color: Colors.white24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Visibility(
                visible: _replyController.text.isNotEmpty,
                child: FloatingActionButton(
                  mini: true,
                  elevation: 0,
                  backgroundColor: ColorsB.yellow500,
                  child: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            )
          ]),
        ),
      );

  late Tween<Offset> _transitionTween;
  late Tween<double> _opacityTween;
  late Animation<Offset> _slideInAnim;
  late Animation<double> _opacityAnim;
  late AnimationController _slideAnimCtrl;

  var difference, timeAgo;

  //  bool isReplying = false;

  @override
  void initState() {
    _slideAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _transitionTween =
        Tween<Offset>(begin: const Offset(0, -2), end: Offset.zero);

    _opacityTween = Tween(begin: 0.0, end: 1.0);

    _slideInAnim = _transitionTween.animate(
        CurvedAnimation(parent: _slideAnimCtrl, curve: Curves.easeOut));

    _opacityAnim = _opacityTween.animate(
        CurvedAnimation(parent: _slideAnimCtrl, curve: Curves.easeOut));

    //  difference = widget.timePosted.difference(DateTime.now());
    // timeAgo = DateTime.now().subtract(difference);

    //  debugPrint(difference);
    debugPrint(widget.timePosted.toString());

    //  Comment.getMaxId();

    super.initState();
  }

  @override
  void dispose() {
    _slideAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Column(
        children: [mainCommentBody(), replyCommentBody()],
      ),
    );
  }
}

class CommentBar extends StatefulWidget {
  final int postID;
  final Map gMap;
  List<Comment> comments;
  final StreamController commentStream;
  CommentBar(
      {Key? key,
      required this.postID,
      required this.gMap,
      required this.comments,
      required this.commentStream})
      : super(key: key);

  @override
  State<CommentBar> createState() => _CommentBarState();
}

class _CommentBarState extends State<CommentBar> {
  final _commentController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(children: [
        Expanded(
          flex: 3,
          child: TextField(
            keyboardType: TextInputType.text,
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            maxLines: null,
            maxLength: 150,
            //  maxLengthEnforcement: MaxLengthEnforcement.enforced,
            onChanged: (_) {
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: "Leave a comment",
              counterText: "",
              errorBorder: InputBorder.none,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintStyle:
                  TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Visibility(
            visible: _commentController.text.isNotEmpty,
            child: FloatingActionButton(
              mini: true,
              elevation: 0,
              backgroundColor: ColorsB.yellow500,
              child: !isLoading
                  ? const Icon(Icons.send, color: Colors.white)
                  : const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  var url =
                      Uri.parse('${Misc.link}/${Misc.appName}/addComment.php');
                  final response = await http.post(url, body: {
                    "pid": widget.postID.toString(),
                    "oid": widget.gMap['id'].toString(),
                    "body": _commentController.text
                  });

                  debugPrint(response.statusCode.toString());

                  if (response.statusCode == 200) {
                    var jsondata = json.decode(response.body);
                    //debugPrint(jsondata.toString());

                    if (jsondata['success']) {
                      int commentId = await Comment.getMaxId();

                      widget.comments.add(Comment(
                        id: commentId,
                        likes: 0,
                        likesBool: false,
                        ownerId: widget.gMap['id'],
                        owner: widget.gMap['first_name'] +
                            ' ' +
                            widget.gMap['last_name'],
                        body: _commentController.text,
                        delete: () async {
                          await Comment.deleteComment(
                                  context,
                                  widget.comments.last.id,
                                  widget.comments.length - 1,
                                  widget.comments)
                              .then((value) => widget.commentStream.add(1));
                        },
                        globalMap: widget.gMap,
                        commentsNo: 0,
                        timePosted: DateTime.now(),
                      ));

                      widget.commentStream.add(1);

                      FocusScope.of(context).unfocus();

                      setState(() {
                        _commentController.text = '';
                      });
                    } else {}
                  }
                } catch (e) {}

                setState(() {
                  isLoading = false;
                });
              },
            ),
          ),
        )
      ]),
    );
  }
}

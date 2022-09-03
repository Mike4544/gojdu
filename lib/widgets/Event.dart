import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../others/colors.dart';

import 'package:http/http.dart' as http;

var screenHeight = window.physicalSize.height / window.devicePixelRatio;
var screenWidth = window.physicalSize.width / window.devicePixelRatio;

class Event extends StatelessWidget {
  final Map gMap;
  final int? id;
  final String title;
  final String body;
  final String owner;
  final String location;
  final String date;
  final String link;
  final Function delete;
  final BuildContext Context;


  const Event({
    Key? key,
    this.id,
    required this.gMap,
    required this.title,
    required this.body,
    required this.owner,
    required this.location,
    required this.date,
    required this.link,
    required this.delete,
    required this.Context
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: screenHeight * .3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [ColorsB.gray800, ColorsB.gray700],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
            stops: [.5, 1]
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: ColorsB.gray900
                ),

                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text(
                              title,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: title.length > 10 ? 20 : 25,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(width: 25,),
                            Flexible(
                              child: Text(
                                'by $owner',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                                avatar: Icon(Icons.location_on_outlined, color: ColorsB.gray900,),
                                label: Text(
                                  location,
                                  style: TextStyle(
                                    color: ColorsB.gray900,
                                  ),
                                )
                            ),
                            Chip(
                                avatar: Icon(Icons.calendar_today_outlined, color: ColorsB.gray900,),
                                label: Text(
                                  date,
                                  style: TextStyle(
                                    color: ColorsB.gray900,
                                  ),
                                )
                            )
                          ],
                        ),
                      )

                    ],
                  ),
                ),

              ),
              Visibility(
                visible: gMap['account'] == 'Admin' || gMap['first_name'] + ' ' + gMap['last_name'] == owner,
                child: Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
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
                                        'Are you sure you want delete this post?',
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

                                                await delete();

                                                Navigator.of(context).pop();

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
                    },
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    
                  },
                  borderRadius: BorderRadius.circular(30),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}


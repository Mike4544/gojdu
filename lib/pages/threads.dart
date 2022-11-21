import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/options.dart';
import '../others/colors.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Threads extends StatefulWidget {
  const Threads({Key? key}) : super(key: key);

  @override
  State<Threads> createState() => _ThreadsState();
}

class _ThreadsState extends State<Threads> with SingleTickerProviderStateMixin {
  late final AssetImage _placeholder;

  late double position;

  Future _startAnim() async {
    await Future.delayed(const Duration(seconds: 7));
    setState(() {
      position = MediaQuery.of(context).size.height * .1;
    });
  }

  @override
  void initState() {
    _placeholder = const AssetImage("assets/threadsHolder.gif");

    position = -500;

    super.initState();

    _startAnim();
  }

  @override
  void dispose() {
    _placeholder.evict();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: Image(
                image: _placeholder,
              ),
            ),
            AnimatedPositioned(
              bottom: position,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: LoadingBar(
                  thisWidth: MediaQuery.of(context).size.width * .5,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class LoadingBar extends StatefulWidget {
  final double thisWidth;
  const LoadingBar({Key? key, required this.thisWidth}) : super(key: key);

  @override
  State<LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<LoadingBar> {
  Future<int> getMockInt() async {
    int schoolNumber = 0;

    final http.Response response = await http
        .get(Uri.parse('${Misc.link}/${Misc.appName}/mockNumber.php'));

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);

      schoolNumber = jsondata;
    }
    return schoolNumber;
  }

  late final _number = getMockInt();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: _number,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Text(
                  '${snapshot.data!} out of 15 schools.',
                  style: TextStyle(
                      color: ColorsB.yellow500,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(360),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black54,
                              offset: Offset(0, -3),
                              blurRadius: 25)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(7.5),
                      child: Stack(
                        children: <Widget>[
                          Container(
                              width: widget.thisWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(360),
                                  color: Colors.grey[200])),
                          Container(
                              width: (snapshot.data! / 15) * widget.thisWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(360),
                                  color: ColorsB.yellow500)),
                        ],
                      ),
                    ))
              ],
            );
          } else {
            return const SizedBox();
          }
        }));
  }
}

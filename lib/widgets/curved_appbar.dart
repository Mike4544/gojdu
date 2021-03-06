import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/pages/settings.dart';
import 'package:animations/animations.dart';

class CurvedAppbar extends StatefulWidget {
  final String name;
  final String? accType;
  final int position;

  const CurvedAppbar({Key? key, required this.name, this.accType, required this.position}) : super(key: key);

  @override
  _CurvedAppbarState createState() => _CurvedAppbarState();
}

class _CurvedAppbarState extends State<CurvedAppbar> with SingleTickerProviderStateMixin {

  //  <-----------------  Void for settings ------------------>
  void toSettings(){
    Navigator.push(context, PageRouteBuilder(
      reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, a1, a2) => SettingsPage(),
        transitionsBuilder: (context, a1, a2, child) =>
           SharedAxisTransition(
             animation: a1,
             secondaryAnimation: a2,
             transitionType: SharedAxisTransitionType.vertical,
             fillColor: ColorsB.gray900,
             child: child,
           )
    ));
  }

  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds:250));
    _offset = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
    .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 100,
      expandedHeight: 500,
      collapsedHeight: 100,
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      backgroundColor: ColorsB.yellow500,
      shape: CustomShape(position: widget.position),
      flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            var top = constraints.biggest.height;
            late bool expanded;
            if(top <= 200){
              expanded = false;
              _controller.forward();
            }
            else {
              expanded = true;
              _controller.reverse();
            }
            //print(expanded);

            //TODO: Implement the animations, implement the shape to the navbar and the news


            return FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: top/4, horizontal: 20),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 10 ,),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 250),
                              height: expanded ? 35 : 0,
                              width: 2.5,
                              color: ColorsB.gray900,
                            ),
                            SizedBox(width: 10,),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 250),
                              opacity: expanded ? 1 : 0,
                              child: Text(
                                '${widget.name}',
                                style: TextStyle(
                                  color: ColorsB.gray900,

                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SlideTransition(
                      position: _offset,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: !expanded ? 1 : 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    toSettings();
                                  },
                                  splashRadius: 30,
                                  iconSize: 40,
                                  icon: const Icon(
                                    Icons.perm_identity_rounded,
                                    color: ColorsB.gray900,
                                  ),
                                )
                              ],
                            ),
                            accoutType(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            );
          }),
    );
  }

  Widget accoutType(){

    if(widget.accType != null) {
      return Row(
        children: [
          Text(
            widget.accType!,
            style: const TextStyle(
              fontSize: 22.5,
              color: ColorsB.gray900
            ),
          ),
          SizedBox(width: 10),
          Container(
            color: ColorsB.gray900,
            width: 2.5,
            height: 25,
          )
        ],
      );
    }
    else {
      return SizedBox(width: 0, height: 0,);
    }

  }


}


class CustomShape extends ContinuousRectangleBorder {
  
  final int position;
  //  0 - Left
  //  1 - middle
  //  3 - right
  
  const CustomShape({required this.position});

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: implement getOuterPath

    Path path = Path();
    
    switch(position){
      
      case 0:
        path.lineTo(0, rect.height);
        path.quadraticBezierTo(20, rect.height - 30, 60, rect.height - 30);
        path.lineTo(rect.width, rect.height-30);
        path.lineTo(rect.width, 0);
        path.close();
        break;
        
      case 1:
        path.lineTo(0, rect.height - 30);
        path.lineTo(rect.width, rect.height-30);
        path.lineTo(rect.width, 0);
        path.close();
        break;
        
      case 2:
        path.lineTo(0, rect.height - 30);
        //  path.quadraticBezierTo(20, rect.height - 30, 60, rect.height - 30);
        path.lineTo(rect.width - 60, rect.height-30);
        path.quadraticBezierTo(rect.width - 10, rect.height - 30, rect.width, rect.height);
        path.lineTo(rect.width, 0);
        path.close();
        break;
      
    }


    return path;
  }


}


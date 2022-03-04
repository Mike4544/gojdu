import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

class CurvedAppbar extends StatefulWidget {
  final String name;

  const CurvedAppbar({Key? key, required this.name}) : super(key: key);

  @override
  _CurvedAppbarState createState() => _CurvedAppbarState();
}

class _CurvedAppbarState extends State<CurvedAppbar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 2,
      expandedHeight: 500,
      collapsedHeight: 2,
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      backgroundColor: ColorsB.yellow500,
      shape: CustomShape(),
      flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            var top = constraints.biggest.height;
            late bool expanded;
            if(top <= 200){
              expanded = false;
            }
            else {
              expanded = true;
            }
            //print(expanded);

            //TODO: Implement the animations, implement the shape to the navbar and the news


            return FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: top/4, horizontal: 20),
                child: Column(
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
              ),
            );
          }),
    );
  }
}


class CustomShape extends ContinuousRectangleBorder {

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: implement getOuterPath

    Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(20, rect.height - 30, 60, rect.height - 30);
    path.lineTo(rect.width, rect.height-30);
    path.lineTo(rect.width, 0);
    path.close();


    return path;
  }


}


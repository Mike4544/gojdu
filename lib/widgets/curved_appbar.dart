import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/pages/settings.dart';
import 'package:animations/animations.dart';

class CurvedAppbar extends StatefulWidget {
  final String name;
  final String? accType;
  final int position;
  final Map map;

  const CurvedAppbar({Key? key, required this.name, this.accType, required this.position, required this.map}) : super(key: key);

  @override
  _CurvedAppbarState createState() => _CurvedAppbarState();
}

class _CurvedAppbarState extends State<CurvedAppbar>{

  final scoala = 'Colegiul National "Emanuil Gojdu"';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //  _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;

    var height2 = height < 675 ? MediaQuery.of(context).size.height * .175 : MediaQuery.of(context).size.height * .15;

    return SliverAppBar(
      toolbarHeight: height2,
      expandedHeight: height2,
      collapsedHeight: height2,
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      backgroundColor: ColorsB.yellow500,
      shape: CustomShape(position: widget.position),
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.map["first_name"]} ${widget.map["last_name"]}',
                    style: const TextStyle(
                      color: ColorsB.gray900,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  Text(
                    scoala,
                    style: const TextStyle(
                        color: ColorsB.gray900,
                        fontSize: 15
                    ),
                  )
                ],
              ),
            ),
            name(),
          ],
        ),
      ),
    );
  }

  Widget name(){

    return Row(
      children: [
        Text(
          widget.name,
          style: const TextStyle(
              fontSize: 22.5,
              fontWeight: FontWeight.bold,
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


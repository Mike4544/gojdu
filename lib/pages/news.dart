import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}


//TODO: Make the news page. At least begin it

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsB.gray900,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 500,
            collapsedHeight: 100,
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
              print(expanded);

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
                            AnimatedSize(
                              duration: Duration(milliseconds: 250),
                              child: Icon(Icons.announcement, color: ColorsB.gray900,
                              size: expanded ? 40 : 60,
                              ),
                            ),
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
                                'Announcements',
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
            ),

          SliverToBoxAdapter(
            child: Column(
              children: [
               Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
                Text('1'),
                SizedBox(height: 75,),
              ],
            ),
          )

        ],
      ),
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/curved_appbar.dart';
import 'package:gojdu/widgets/navbar.dart';

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
      bottomNavigationBar: RoundedNavbar(),
      body: CustomScrollView(
        slivers: [
          CurvedAppbar(),

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


import 'package:flutter/material.dart';
import '../others/colors.dart';

class PostsSwitcher extends StatefulWidget {
  int index;
  final PageController ctrl;
  final Function(int value) update;


  PostsSwitcher({Key? key, required this.index, required this.ctrl, required this.update}) : super(key: key);

  @override
  State<PostsSwitcher> createState() => _PostsSwitcherState();
}

class _PostsSwitcherState extends State<PostsSwitcher> with TickerProviderStateMixin {


  void anim(int value){

    widget.update(value);

    widget.ctrl.animateToPage(value, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);


  }

  late AnimationController _c1, _c2;
  late Animation _anim1, _anim2;


  @override
  void initState() {
    _c1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _c2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _anim1 = IntTween(begin: 8000, end: 2100).animate(CurvedAnimation(parent: _c1, curve: Curves.easeInOut));
    _anim2 = IntTween(begin: 2100, end: 8000).animate(CurvedAnimation(parent: _c2, curve: Curves.easeInOut));

    _anim2.addListener(() {setState(() {

    });});

    super.initState();
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    const inactiveStyle = TextStyle(
      color: ColorsB.gray700
    );

    const activeStyle = TextStyle(
        color: ColorsB.yellow500
    );

    final cActive = BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        color: ColorsB.gray800,
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 15)
      ]
    );

    final cInactive = BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        color: ColorsB.gray800
    );


    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            height: 50,
            width: width * .5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:_anim1.value,
                  child: GestureDetector(
                    onTap: () {
                      anim(0);

                      _c1.reverse();
                       _c2.reverse();


                    },
                    child: AnimatedContainer(
                      clipBehavior: Clip.hardEdge,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 500),
                      decoration: widget.index == 0
                      ? cActive
                      : cInactive,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                  width: height * .03,
                                  height: height * .03,
                                  child: FittedBox(
                                      child: Icon(Icons.announcement, color: widget.index == 0 ? ColorsB.yellow500 : ColorsB.gray700,)
                                  )
                              ),
                              const SizedBox(width: 5,),
                              SizedBox(
                                height: height * .025,
                                width:  width * .25,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    'Announcements',
                                    overflow: TextOverflow.fade,
                                    style: widget.index == 0
                                      ? activeStyle
                                      : inactiveStyle,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: _anim2.value,
                  child: GestureDetector(
                    onTap: () {
                      anim(1);

                       _c1.forward();
                       _c2.forward();


                    },
                    child: AnimatedContainer(
                      clipBehavior: Clip.hardEdge,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 500),
                      decoration: widget.index == 1
                          ? cActive
                          : cInactive,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  width: height * .03,
                                  height: height * .03,
                                  child: FittedBox(
                                      child: Icon(Icons.event, color: widget.index == 1 ? ColorsB.yellow500 : ColorsB.gray700,),
                                  )
                              ),
                              const SizedBox(width: 5,),
                              SizedBox(
                                height: height * .025,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    'Events',
                                    overflow: TextOverflow.fade,
                                    style: widget.index == 1
                                        ? activeStyle
                                        : inactiveStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


              ],

            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

class ClassSelect extends StatefulWidget {

  // <------- For Updating the floor within the parent ------->
  final Function(Color, String) update;


  const ClassSelect({Key? key, required this.update}) : super(key: key);

  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> with TickerProviderStateMixin {


  final height = ValueNotifier<double>(0);
  bool open = false;

  //  <---------- Animated Icon ----------------->
  late AnimationController _iconController;


  int floorNo = 1;
  String channel = "Select a channel";

  @override
  void initState() {
    // TODO: implement initState
    open = false;
    floorNo = 1;
    _iconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250),);
    super.initState();

  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();

  }


  //  <------------- For the selected container ------------------>
  final List<Color> _containerColors = [
    Colors.transparent,
    Colors.transparent,
    Colors.transparent
  ];



  @override
  Widget build(BuildContext context) {

    Widget? _valueReturner(int index){
      switch(index) {
        case 0:
          return Text(
            'Students',
            style: const TextStyle(
                fontSize: 17
            ),
          );
        case 1:
          return Text(
            'Teachers',
            style: const TextStyle(
                fontSize: 17
            ),
          );
        case 2:
          return Text(
            'Parents',
            style: const TextStyle(
                fontSize: 17
            ),
          );
      }
    }

    var device = MediaQuery.of(context);

    return Container(
      width: device.size.width * 0.5,
      child: Stack(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: ValueListenableBuilder(
              valueListenable: height,
              builder: (_, value, __ ) =>
                  AnimatedContainer(
                    clipBehavior: Clip.hardEdge,
                    duration: const Duration(milliseconds: 250),
                    height: height.value,
                    curve: Curves.ease,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: ColorsB.gray200,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30)
                        )
                    ),

                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: 3,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, index) =>
                          Padding(
                            padding: index == 0 ? const EdgeInsets.fromLTRB(0, 35, 0, 0) : const EdgeInsets.all(0),
                            child: GestureDetector(
                              onTap: () {

                                setState(() {
                                  height.value = 0;
                                  open = !open;
                                  switch(index){
                                    case 0:
                                      setState(() {
                                        channel = "Students";
                                        widget.update(ColorsB.gray800, channel);
                                      });
                                      break;
                                    case 1:
                                      setState(() {
                                        channel = "Teachers";
                                        widget.update(Colors.amber, channel);
                                      });
                                      break;
                                    case 2:
                                      setState(() {
                                        channel = "Parents";
                                        widget.update(Colors.indigoAccent, channel);
                                      });
                                      break;
                                  }
                                  for(int i = 0; i < 3; i++) {
                                    if(i != index)
                                      _containerColors[i] = Colors.transparent;
                                    _containerColors[index] = ColorsB.gray700.withOpacity(0.1);
                                  }
                                  if(open){
                                    _iconController.forward();
                                  }
                                  else {
                                    _iconController.reverse();
                                  }

                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: _containerColors[index] == ColorsB.gray700.withOpacity(0.1) ?
                                    const EdgeInsets.fromLTRB(0, 0, 25, 0) :
                                    EdgeInsets.zero,
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: _containerColors[index],
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(50),
                                            bottomRight: Radius.circular(50)
                                        )
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Center(
                                        child: _valueReturner(index),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: index == 2 ? false : true,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Divider(
                                        height: 10,
                                        thickness: 1,
                                        color: Colors.grey.withOpacity(0.1),
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
          ),






        //  Note to self: Maybe change the color of the last container.


          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
              child: Text(
                '${channel}',
                style: const TextStyle(
                  color: ColorsB.gray900,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  open = !open;
                  height.value = open ? device.size.height * 0.25 : 0;

                  if(open){
                    _iconController.forward();
                  }
                  else {
                    _iconController.reverse();
                  }
                },
                child: Container(
                  height: 50,
                  width: device.size.width * 0.1,
                  child: Center(
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.5).animate(CurvedAnimation(parent: _iconController, curve: Curves.ease)),
                      child: Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: ColorsB.yellow500,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50)
                    ),

                  ),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }


}

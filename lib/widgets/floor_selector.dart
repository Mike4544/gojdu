import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

class DropdownSelector extends StatefulWidget {

  // <------- For Updating the floor within the parent ------->
  final ValueChanged<int>? update;


  const DropdownSelector({Key? key, this.update}) : super(key: key);

  @override
  _DropdownSelectorState createState() => _DropdownSelectorState();
}

class _DropdownSelectorState extends State<DropdownSelector> with TickerProviderStateMixin {


  final height = ValueNotifier<double>(0);
  bool open = false;
  
  //  <---------- Animated Icon ----------------->
  late AnimationController _iconController;


  int floorNo = 1;

  @override
  void initState() {
    // TODO: implement initState
    open = false;
    floorNo = 1;
    _iconController = AnimationController(vsync: this, duration: Duration(milliseconds: 250),);
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
    ColorsB.gray700.withOpacity(0.1),
    Colors.transparent
  ];



  @override
  Widget build(BuildContext context) {

    var device = MediaQuery.of(context);

    return Container(
      width: device.size.width * 0.4,
      child: Stack(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: ValueListenableBuilder(
              valueListenable: height,
              builder: (_, value, __ ) =>
                  AnimatedContainer(
                    clipBehavior: Clip.hardEdge,
                    duration: Duration(milliseconds: 250),
                    height: height.value,
                    curve: Curves.ease,
                    width: double.infinity,
                    decoration: BoxDecoration(
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
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (_, index) =>
                          GestureDetector(
                            onTap: () {

                              setState(() {
                                height.value = 0;
                                open = !open;
                                floorNo = index;
                                widget.update!(floorNo);
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
                                      child: Text(
                                        'Floor $index',
                                        style: const TextStyle(
                                            fontSize: 17
                                        ),
                                      ),
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









          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: ColorsB.gray800,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
              child: Text(
                'Floor $floorNo',
                style: TextStyle(
                  color: ColorsB.gray200,
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

import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

class DropdownSelector extends StatefulWidget {
  const DropdownSelector({Key? key}) : super(key: key);

  @override
  _DropdownSelectorState createState() => _DropdownSelectorState();
}

class _DropdownSelectorState extends State<DropdownSelector> {


  final height = ValueNotifier<double>(0);
  bool open = false;

  int floorNo = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



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
                    duration: Duration(milliseconds: 250),
                    height: height.value,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  height.value = 0;
                                  open = !open;
                                  floorNo = index;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Floor $index',
                                    style: TextStyle(
                                        fontSize: 17
                                    ),
                                  ),
                                  Divider(
                                    height: 10,
                                    thickness: 1,
                                  )
                                ],
                              ),
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
                  height.value = open ? device.size.height * 0.25 : 0;
                  open = !open;
                },
                child: Container(
                  height: 50,
                  width: device.size.width * 0.1,
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: ColorsB.yellow500,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          bottomRight: Radius.circular(50)
                      )
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

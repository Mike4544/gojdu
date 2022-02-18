import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:animate_icons/animate_icons.dart';

class StyledDropdown extends StatelessWidget {
  final ValueNotifier<double> containerHeight;
  final device;
  final bool sopen;
  final AnimateIconController controller;

  final String title, description;
  
  
  const StyledDropdown({Key? key, required this.containerHeight, required this.device, required this.sopen, required this.title, required this.description, required this.controller}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    bool open = sopen;

    return Stack( // Styled dropdown
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: ValueListenableBuilder(
            valueListenable: containerHeight,
            builder: (_, a, __) => AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: containerHeight.value,
              width: double.infinity,
              curve: Curves.linearToEaseOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: ColorsB.gray800,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 45,),
                      Text(
                        "$title",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      Divider(height: 15, color: Colors.white,),
                      SizedBox(height: 10,),

                      Text(
                        "$description",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Container( // The 'Why this is the case' container
          width: double.infinity,
          height: device.size.height * 0.08,
          decoration: BoxDecoration(
              border: Border.all(color: ColorsB.gray800, width: 2),
              color: ColorsB.gray900,
              borderRadius: BorderRadius.circular(360),
              // boxShadow:[
              //   BoxShadow(
              //     color: Colors.black12.withOpacity(0.25),
              //     spreadRadius: 4,
              //     blurRadius: 10,
              //     offset: Offset(0, 3),
              //   ),
              // ]
          ),

          child: Row(
            children: [
              Container(
                height: double.infinity,
                width: 75,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(360),
                        bottomLeft:Radius.circular(360)
                    ),
                    color: ColorsB.yellow500
                ),
                child: Center(
                  child: AnimateIcons(
                    startIcon: Icons.add_circle_outline,
                    endIcon: Icons.close,
                    startIconColor: Colors.white,
                    endIconColor: Colors.white,
                    size: 35,
                    controller: controller,
                    onStartIconPress: () {
                      open = !open;
                      containerHeight.value = open ? 250 : 0;
                      return true;
                    },
                    onEndIconPress: () {
                      open = !open;
                      containerHeight.value = open ? 250 : 0;
                      return true;
                    },
                    duration: Duration(milliseconds: 250),
                    clockwise: false,
                  ),
                ),
              ),
              const SizedBox(width: 25,),
              const Text(
                'Why is this the case?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:gojdu/widgets/back_navbar.dart';
import 'package:gojdu/pages/login.dart';

class SettingsPage extends StatefulWidget {

  //  TODO: Pass the user-related variables

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {

    //  <------------ For size  ---------------->
    final device = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorsB.gray900,
      bottomNavigationBar: BackNavbar(variation: 1,),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(35, 50, 0, 0),
          child: Row(
            children: [
              SvgPicture.asset('assets/svgs/settings_cogs.svg'),
              SizedBox(width: 20,),
              const Text(
                'Account Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: device.height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Email Address:',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontWeight: FontWeight.w700,
                            fontSize: 20
                        ),
                      ),
                      Text(
                        'Full Name:',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontWeight: FontWeight.w700,
                            fontSize: 20
                        ),
                      ),
                      Text(
                        'Password:',
                        style: TextStyle(
                            color: ColorsB.yellow500,
                            fontWeight: FontWeight.w700,
                            fontSize: 20
                        ),
                      ),

                    ],
                  ),
                ),
                SizedBox(
                  height: device.height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.blueGrey[900]!.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.grey[900]!)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8.5),
                              child: Center(
                                child: Text(
                                  'ceva@gojdu.com',
                                  style: TextStyle(
                                      color: Colors.white24.withOpacity(0.5),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 4),
                            child: Text(
                              'Tira Mihai',
                              style: TextStyle(
                                color: ColorsB.gray800,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 5),
                            child: TextButton(
                              onPressed: () {
                                //  Change pass
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                child: Center(
                                  child: Text(
                                    'Change your password',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: ColorsB.gray800,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )
                              ),
                            ),
                          )
                        ],
                      ),

                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: device.height * 0.1,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) =>
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: ColorsB.gray900,
                        title: Column(
                          children: const [
                            Text(
                              'Are you sure you want to log-off?',
                              style: TextStyle(
                                  color: ColorsB.yellow500,
                                  fontSize: 15
                              ),
                            ),
                            Divider(
                              color: ColorsB.yellow500,
                              thickness: 1,
                              height: 10,
                            )
                          ],
                        ),
                        content: SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You will be redirected to the login page after this. Are you sure you want to log-off?',
                                style: TextStyle(
                                    color: ColorsB.yellow500,
                                    fontSize: 15
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {

                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (context) =>
                                            Login()
                                      ));

                                      //  TODO: A proper logoff function
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: ColorsB.yellow500,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      height: 50,
                                      width: 75,
                                      child: Icon(
                                        Icons.check, color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: ColorsB.gray800,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      height: 50,
                                      width: 75,
                                      child: Icon(
                                        Icons.close, color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      )
                );
              },
              child: Container(
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(device.width * 0.5, (device.width * 0.5*0.3214626550806168).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                      painter: RPSCustomPainter(),

                    ),
                    Transform.translate(
                      offset: Offset(75,12.5),
                      child: const Text(
                        'Log-off',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                //SvgPicture.asset('assets/svgs/logout_button.svg', colorBlendMode: BlendMode.dstATop,),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(color: Colors.redAccent.withOpacity(0.25), blurRadius: 50),
                      BoxShadow(color: Colors.redAccent[400]!.withOpacity(0.05), blurRadius: 25,),
                      BoxShadow(color: Colors.redAccent[200]!.withOpacity(0.1), blurRadius: 25,),
                    ]
                ),
              ),
            ),

          ],
        )
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    Path path_0 = Path();
    path_0.moveTo(size.width*0.1148727,size.height);
    path_0.lineTo(size.width*0.1148727,size.height);
    path_0.lineTo(0,size.height*0.8125000);
    path_0.lineTo(0,0);
    path_0.lineTo(size.width*0.2106083,0);
    path_0.lineTo(size.width*0.2106083,size.height*0.3125000);
    path_0.lineTo(size.width*0.1914210,size.height*0.3125000);
    path_0.lineTo(size.width*0.1914210,size.height*0.06250000);
    path_0.lineTo(size.width*0.03827415,size.height*0.06250000);
    path_0.lineTo(size.width*0.1148727,size.height*0.1875000);
    path_0.lineTo(size.width*0.1148727,size.height*0.7500000);
    path_0.lineTo(size.width*0.1914210,size.height*0.7500000);
    path_0.lineTo(size.width*0.1914210,size.height*0.5625000);
    path_0.lineTo(size.width*0.2106083,size.height*0.5625000);
    path_0.lineTo(size.width*0.2106083,size.height*0.8125000);
    path_0.lineTo(size.width*0.1148727,size.height*0.8125000);
    path_0.lineTo(size.width*0.1148727,size.height);
    path_0.close();
    path_0.moveTo(size.width*0.8693556,size.height*0.8125000);
    path_0.lineTo(size.width*0.2063388,size.height*0.8125000);
    path_0.lineTo(size.width*0.2063388,size.height*0.5000000);
    path_0.lineTo(size.width*0.1289869,size.height*0.5000000);
    path_0.lineTo(size.width*0.1289869,size.height*0.3750000);
    path_0.lineTo(size.width*0.2063388,size.height*0.3750000);
    path_0.lineTo(size.width*0.2063388,0);
    path_0.lineTo(size.width*0.8693556,0);
    path_0.arcToPoint(Offset(size.width*0.9617259,size.height*0.1190625),radius: Radius.elliptical(size.width*0.1297905, size.height*0.4037500),rotation: 0 ,largeArc: false,clockwise: true);
    path_0.arcToPoint(Offset(size.width*0.9895022,size.height*0.5643750),radius: Radius.elliptical(size.width*0.1305942, size.height*0.4062500),rotation: 0 ,largeArc: false,clockwise: true);
    path_0.arcToPoint(Offset(size.width*0.9615249,size.height*0.6935938),radius: Radius.elliptical(size.width*0.1294389, size.height*0.4026562),rotation: 0 ,largeArc: false,clockwise: true);
    path_0.arcToPoint(Offset(size.width*0.8693556,size.height*0.8125000),radius: Radius.elliptical(size.width*0.1300417, size.height*0.4045313),rotation: 0 ,largeArc: false,clockwise: true);
    path_0.close();
    path_0.moveTo(size.width*0.2247225,size.height*0.5000000);
    path_0.lineTo(size.width*0.2247225,size.height*0.6250000);
    path_0.lineTo(size.width*0.2821337,size.height*0.4375000);
    path_0.lineTo(size.width*0.2247225,size.height*0.2500000);
    path_0.lineTo(size.width*0.2247225,size.height*0.3750000);
    path_0.lineTo(size.width*0.2063388,size.height*0.3750000);
    path_0.lineTo(size.width*0.2063388,size.height*0.5000000);
    path_0.close();

    Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
    paint_0_fill.shader = ui.Gradient.linear(Offset(size.width*-459.6062,size.height*8.267656), Offset(size.width*-460.2893,size.height*8.297500), [Color(0xfff93333).withOpacity(1),Color(0xffee3d6d).withOpacity(1)], [0,1]);
    canvas.drawPath(path_0,paint_0_fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//  For the logoff button




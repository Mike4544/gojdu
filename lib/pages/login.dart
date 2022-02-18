import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';
import 'package:gojdu/widgets/input_fields.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //Username and password 'submiters'
  final _nameController = ValueNotifier<TextEditingController>(TextEditingController());
  final _passController = ValueNotifier<TextEditingController>(TextEditingController());



  //Transition width and height
  final _tWidth = ValueNotifier<double>(0);
  final _tHeight = ValueNotifier<double>(0);
  final _radius = ValueNotifier<double>(360);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();





  }



  @override
  void dispose() {
    // TODO: D/M: Add more to dispose if necessary
    super.dispose();
    _nameController.dispose();
    _passController.dispose();

    print('disposed');
  }

  @override
  Widget build(BuildContext context) {
    print("building");

    var size = MediaQuery.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorsB.gray900,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20), //Padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset('assets/images/Logo.png'),
                        SizedBox(height: size.size.height*0.20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputField(fieldName: "Name", isPassword: false, lengthLimiter: 10, controller: _nameController.value,),

                            //TODO: Probably lessen the number of set states
                            //TODO: Below this message there are error message listeners. Modify them to be more versatile


                            // ValueListenableBuilder(
                            //     valueListenable: _nameController.value,
                            //     builder: (_, value, __) => Visibility(
                            //       visible: _nameController.value.text.isNotEmpty ? false : true,
                            //       child: const Text(
                            //         'Field cannot be empty',
                            //         style: TextStyle(
                            //           color: Colors.red,
                            //         ),
                            //       ),
                            //     ),
                            // ),


                            const SizedBox(height: 50),

                            InputField(fieldName: "Password", isPassword: true, controller: _passController.value,),

                            // ValueListenableBuilder(
                            //   valueListenable: _passController.value,
                            //   builder: (_, value, __) => Visibility(
                            //     visible: _passController.value.text.isNotEmpty ? false : true,
                            //     child: const Text(
                            //       'Field cannot be empty',
                            //       style: TextStyle(
                            //         color: Colors.red,
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            //TODO: Make the error text pop only on sign-in

                            GestureDetector(
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                child: Text(
                                  "Forgot your password?",
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: ColorsB.gray700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 50,),

                        ValueListenableBuilder(
                          valueListenable: _passController.value,
                          builder: (_, value, __) => TextButton(
                            onPressed: () async {
                              print("The name is ${_nameController.value.text} and the password is ${_passController.value.text.hashCode}");
                              //TODO: D: Send info to the server - Darius fa-ti magia
                              //TODO: M: Make page transition animation
                              /*TODO: M/D: Make a 'remember me' check.
                                        We wouldn't want to make the users uncomfy UwU
                                 */

                              _tWidth.value = size.size.width;
                              _tHeight.value = size.size.height;
                              _radius.value = 0;

                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                              child: Text(
                                  "Sign-in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Nunito',
                                    letterSpacing: 2.5,
                                  )),
                            ),
                            style: TextButton.styleFrom(
                                backgroundColor: _nameController.value.text.isNotEmpty && _passController.value.text.isNotEmpty ? ColorsB.yellow500 : ColorsB.gray800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                )
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  fontSize: 12.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: const Text(
                                  'Sign-Up',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: ColorsB.yellow500,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )


                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: ValueListenableBuilder(
              valueListenable: _tWidth,
              builder: (_, width, __) => AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: _tWidth.value,
                height: _tHeight.value,
                onEnd: () {
                  Navigator.pushReplacementNamed(context, '/news');
                },
                decoration: BoxDecoration(
                  color: ColorsB.gray900,
                  borderRadius: BorderRadius.circular(_radius.value),
                ),
              ),
            )
          ),

        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../others/api.dart';
import '../others/colors.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _postController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey();

  bool sending = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have some ideas you\'re willing to share with us? Tell us more! Who knows, they might become a reality!',
                  style: TextStyle(color: Colors.white, fontSize: 20.sp),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Post contents',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: ColorsB.yellow500,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    TextFormField(
                      controller: _postController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      cursorColor: ColorsB.yellow500,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.red,
                            )),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Field cannot be empty.';
                        }
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton(
                        onPressed: () async {
                          if (_form.currentState!.validate()) {
                            setState(() {
                              sending = true;
                            });

                            try {
                              final Email email = Email(
                                body: _postController.text,
                                subject: 'New feedback!',
                                recipients: ['teenstarnoreply@gmail.com'],
                                isHTML: false,
                              );

                              await FlutterEmailSender.send(email);

                              setState(() {
                                sending = false;
                                _postController.clear();
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Feedback sent!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ));
                            } catch (e) {
                              m_debugPrint(e.toString());

                              setState(() {
                                sending = false;
                                _postController.clear();
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Something went wrong!'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          }
                        },
                        backgroundColor: ColorsB.yellow500,
                        child: sending
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send),
                        mini: true,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

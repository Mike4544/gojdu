import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gojdu/others/colors.dart';

class InputField extends StatefulWidget {

  final String fieldName;
  final bool isPassword;
  final int? lengthLimiter;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? label;
  final FocusNode? focusNode;




  const InputField({Key? key, required this.fieldName, required this.isPassword, this.lengthLimiter, this.controller, this.onChanged, this.label, this.focusNode}) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.fieldName,
          style: const TextStyle(
            fontFamily: 'Nunito',
            color: ColorsB.yellow500,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          autofocus: false,
          cursorColor: ColorsB.yellow500,
          onChanged: widget.onChanged,
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.lengthLimiter)
          ],
          style: const TextStyle(
            fontFamily: 'Nunito',
          ),
          obscureText: widget.isPassword,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: widget.label,
            contentPadding: EdgeInsets.symmetric(vertical: 4.5, horizontal: 10),
              fillColor: ColorsB.gray200,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              constraints: BoxConstraints(
                minWidth: size.size.width*0.75,
                minHeight: 40,
                maxWidth: size.size.width * 0.9, //Previous value *.75
                maxHeight: 40,
              )
          ),

        )

      ],
    );
  }
}






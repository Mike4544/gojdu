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
  final String? errorMessage;
  final bool? isEmail;
  final Icon? icon;




  const InputField({Key? key, required this.fieldName, required this.isPassword, this.lengthLimiter, this.controller, this.onChanged, this.label, this.focusNode, this.errorMessage, this.isEmail, this.icon}) : super(key: key);

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
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          focusNode: widget.focusNode,
          controller: widget.controller,
          autofocus: false,
          cursorColor: ColorsB.yellow500,
          onChanged: (_) {
            setState(() {

            });
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.lengthLimiter)
          ],
          style: const TextStyle(
            fontFamily: 'Nunito',
          ),
          obscureText: widget.isPassword,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            suffixText: widget.lengthLimiter != null ? '${widget.controller!.text.length}/${widget.lengthLimiter}' : null,
            suffixStyle: TextStyle(
              color: Colors.black26
            ),
            icon: widget.icon,
            errorText: widget.errorMessage!.isNotEmpty ? widget.errorMessage : null,
            hintText: widget.label,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(50)
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 4.5, horizontal: 10),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
             constraints: BoxConstraints(
                minHeight: 40,
                maxWidth: size.size.width * 0.9, //Previous value *.75
                maxHeight: 70,
              )
          ),
          validator: (value) {
            if(value == null || value.isEmpty){
              return "Field cannot be empty.";
            }
            else if(widget.isEmail!) {
                if(!value.contains('@')) {
                  return 'Please enter a valid email adress.';
                }
            }
          },

        )

      ],
    );
  }
}






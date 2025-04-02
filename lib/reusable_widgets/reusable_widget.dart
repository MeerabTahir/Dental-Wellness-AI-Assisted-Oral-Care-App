import 'package:flutter/material.dart';

// Stateful Widget for TextField with Password Visibility Toggle
class ReusableTextField extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPasswordType;
  final TextEditingController controller;

  const ReusableTextField({
    Key? key,
    required this.text,
    required this.icon,
    required this.isPasswordType,
    required this.controller,
  }) : super(key: key);

  @override
  _ReusableTextFieldState createState() => _ReusableTextFieldState();
}

class _ReusableTextFieldState extends State<ReusableTextField> {
  bool _obscureText = true; // Track password visibility

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPasswordType ? _obscureText : false,
      enableSuggestions: !widget.isPasswordType,
      autocorrect: !widget.isPasswordType,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black.withOpacity(0.9), fontFamily: "GoogleSans"),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: Colors.blue),
        suffixIcon: widget.isPasswordType
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        labelText: widget.text,
        labelStyle: TextStyle(color: Colors.black, fontFamily: "GoogleSans"),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black, width: 1), // Black border
        ),
      ),
      keyboardType: widget.isPasswordType ? TextInputType.visiblePassword : TextInputType.text,
    );
  }
}

// Sign Up/Sign In Button
Container signInSignUpButton(BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.5, // 50% screen width
    height: 60, // Fixed height
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOGIN' : 'SIGNUP',
        style: const TextStyle(
          color: Colors.white,
          fontFamily: "GoogleSans",
          fontSize: 20,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.blueAccent;
            }
            return Colors.blue;
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:four_secrets_wedding_app/config/theme/app_theme.dart';
import '../config/theme/auth_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(color: Colors.black),
      decoration: AuthTheme.textFieldDecoration(widget.label).copyWith(
        errorStyle: const TextStyle(
          color: Color(0xFFFF8A80),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}

class WhiteOutlinedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hintText;
  final void Function(String)? onChanged;

  const WhiteOutlinedTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.hintText,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintText: hintText ?? label,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}

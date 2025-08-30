import 'package:flutter/material.dart';
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
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style:
          const TextStyle(color: Colors.black), // Changed from white to black
      decoration: AuthTheme.textFieldDecoration(widget.label).copyWith(
        // Make error text more visible
        errorStyle: const TextStyle(
          color: Color(
              0xFFFF8A80), // Light red color that's visible on dark backgrounds
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        // Add eye icon for password fields
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}

class WhiteOutlinedTextField extends StatefulWidget {
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
  State<WhiteOutlinedTextField> createState() => _WhiteOutlinedTextFieldState();
}

class _WhiteOutlinedTextFieldState extends State<WhiteOutlinedTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintText: widget.hintText ?? widget.label,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        labelText: widget.label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        // Add eye icon for password fields
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}

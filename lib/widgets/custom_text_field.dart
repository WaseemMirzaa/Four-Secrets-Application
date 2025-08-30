import 'package:flutter/material.dart';
import '../config/theme/auth_theme.dart';
import '../constants/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final bool isReadOnly;
  final int? maxLines;
  final TextStyle? hintStyle;
  final InputDecoration? inputDecoration;
  final TextInputType? keyboardType;
  final Function(String)? onchanged;
  final Function(String)? onSubmit;

  final String? Function(String?)? validator;

  final int? maxLength;

  final bool enabled;

  final bool isDateField;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.isReadOnly = false,
    this.validator,
    this.maxLines,
    this.onchanged,
    this.inputDecoration,
    this.onSubmit,
    this.hintStyle,
    this.maxLength,
    this.enabled = true,
    this.isDateField = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final decoration =
        (widget.inputDecoration ?? AuthTheme.textFieldDecoration(widget.label))
            .copyWith(
      hintText: widget.hint,
      hintStyle: widget.hintStyle,
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
    );

    // Force read-only for date fields when global setting is enabled
    final shouldBeReadOnly = widget.isReadOnly ||
        (widget.isDateField && AppConstants.disableDateManualEntry);

    return TextFormField(
      controller: widget.controller,
      maxLines: widget.maxLines ?? 1,
      style: TextStyle(fontSize: 16),
      readOnly: shouldBeReadOnly,
      enabled: widget.enabled,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      onFieldSubmitted: widget.onSubmit,
      onChanged: widget.onchanged,
      decoration: decoration,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLength: widget.maxLength,
    );
  }
}

class CustomTextField1 extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final bool isReadOnly;
  final int? maxLines;
  final TextStyle? hintStyle;
  final InputDecoration? inputDecoration;
  final TextInputType? keyboardType;
  final Function(String)? onchanged;
  final Function(String)? onSubmit;

  final String? Function(String?)? validator;

  final int? maxLength;

  final bool enabled;

  final bool isDateField;

  const CustomTextField1({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.isReadOnly = false,
    this.validator,
    this.maxLines,
    this.onchanged,
    this.inputDecoration,
    this.onSubmit,
    this.hintStyle,
    this.maxLength,
    this.enabled = true,
    this.isDateField = false,
  }) : super(key: key);

  @override
  State<CustomTextField1> createState() => _CustomTextField1State();
}

class _CustomTextField1State extends State<CustomTextField1> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final decoration =
        (widget.inputDecoration ?? AuthTheme.textFieldDecoration(widget.label))
            .copyWith(
      hintText: widget.hint,
      hintStyle: widget.hintStyle,
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
    );

    // Force read-only for date fields when global setting is enabled
    final shouldBeReadOnly = widget.isReadOnly ||
        (widget.isDateField && AppConstants.disableDateManualEntry);

    return TextFormField(
      controller: widget.controller,
      maxLines: widget.maxLines ?? 1,
      style: TextStyle(fontSize: 16),
      readOnly: shouldBeReadOnly,
      enabled: widget.enabled,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      onFieldSubmitted: widget.onSubmit,
      onChanged: widget.onchanged,
      decoration: decoration,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLength: widget.maxLength,
    );
  }
}

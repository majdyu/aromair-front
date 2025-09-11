import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;

  /// Callbacks
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Contrôle du clavier / focus
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  /// Contrôle externe du champ
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  /// Personnalisation optionnelle du padding
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.controller,
    this.keyboardType,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      obscureText: _obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon, color: Colors.black54),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscureText ? 'Afficher' : 'Masquer',
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      ),
    );
  }
}

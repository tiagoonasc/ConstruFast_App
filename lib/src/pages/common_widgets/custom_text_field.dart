import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSecret;
  final List<TextInputFormatter>? inputFomatters;
  final String? initialValue;
  final bool readOnly;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.label,
    this.isSecret = false,
    this.inputFomatters,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = false;

  @override
  void initState() {
    super.initState();

    isObscure = widget.isSecret;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        readOnly: widget.readOnly,
        initialValue: widget.initialValue,
        inputFormatters: widget.inputFomatters,
        obscureText: isObscure,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon),
          suffixIcon:
              widget.isSecret
                  ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    icon: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  )
                  : null,
          labelText: widget.label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

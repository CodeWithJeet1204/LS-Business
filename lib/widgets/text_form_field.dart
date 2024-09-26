import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.borderRadius,
    required this.horizontalPadding,
    this.autoFillHints,
    this.verticalPadding = 0,
    this.isPassword = false,
    this.keyboardType = TextInputType.name,
    this.autoFocus = false,
    this.maxLines = 1,
  });

  final String hintText;
  final bool isPassword;
  final bool autoFocus;
  final Iterable<String>? autoFillHints;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextEditingController controller;

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool isShowPassword = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding,
        vertical: widget.verticalPadding,
      ),
      child: widget.isPassword
          ? Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: false,
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: isShowPassword,
                    maxLines: widget.maxLines,
                    minLines: 1,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: Colors.cyan.shade700,
                        ),
                      ),
                      hintText: widget.hintText,
                    ),
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty) {
                          return 'Please enter ${widget.hintText}';
                        } else {
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                        }
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isShowPassword = !isShowPassword;
                    });
                  },
                  icon: isShowPassword
                      ? const Icon(FeatherIcons.eye)
                      : const Icon(FeatherIcons.eyeOff),
                  tooltip: isShowPassword ? 'Show Password' : 'Hide Password',
                ),
              ],
            )
          : TextFormField(
              autofillHints: widget.autoFillHints,
              autofocus: widget.autoFocus,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              minLines: 1,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: Colors.cyan.shade700,
                  ),
                ),
                hintText: widget.hintText,
              ),
              validator: (value) {
                if (value != null) {
                  if (value.isNotEmpty) {
                    if (widget.hintText == 'Email') {
                      if (!value.contains('@') || !value.contains('.co')) {
                        return 'Invalid email';
                      }
                    } else if (widget.hintText == 'Phone Number') {
                      if (value.length != 10) {
                        return 'Nnumber should be 10 chars long';
                      }
                    } else if (widget.hintText == 'GST Number') {
                      if (value.length < 15) {
                        return 'GST Number should be 15 characters long';
                      }
                    }
                  } else {
                    return 'Pls enter ${widget.hintText}';
                  }
                }
                return null;
              },
            ),
    );
  }
}

import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class CheckBoxContainer extends StatefulWidget {
  const CheckBoxContainer({
    super.key,
    required this.text,
    required this.value,
    required this.function,
    required this.width,
  });

  final String text;
  final double width;
  final bool value;
  final void Function(bool?)? function;

  @override
  State<CheckBoxContainer> createState() => _CheckBoxContainerState();
}

class _CheckBoxContainerState extends State<CheckBoxContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.width * 0.25,
      padding: EdgeInsets.symmetric(
        horizontal: widget.width * 0.0225,
      ),
      decoration: BoxDecoration(
        color: primary2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              color: primaryDark,
              fontWeight: FontWeight.w500,
              fontSize: widget.width * 0.055,
            ),
          ),
          Checkbox(
            activeColor: primaryDark2,
            checkColor: white,
            value: widget.value,
            onChanged: widget.function,
          ),
        ],
      ),
    );
  }
}

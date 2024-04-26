import 'package:find_easy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class SelectContainer extends StatefulWidget {
  const SelectContainer({
    super.key,
    required this.width,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.imageUrl,
  });

  final double width;
  final String text;
  final bool isSelected;
  final void Function()? onTap;
  final String? imageUrl;

  @override
  State<SelectContainer> createState() => _SelectContainerState();
}

class _SelectContainerState extends State<SelectContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width * 0.45,
        height: 100,
        decoration: BoxDecoration(
          color: white,
          border: Border.all(
            width: widget.isSelected ? 3 : 1,
            color: primaryDark,
          ),
          borderRadius: BorderRadius.circular(12),
          image: widget.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(widget.imageUrl!),
                  fit: BoxFit.cover,
                  opacity: 0.25,
                )
              : null,
        ),
        margin: EdgeInsets.all(widget.width * 0.015),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.width * 0.003125,
            ),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryDark,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: widget.isSelected
                    ? widget.width * 0.065
                    : widget.width * 0.055,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class ModeCard extends StatefulWidget {
  const ModeCard({
    super.key,
    required this.isSelected,
    required this.name,
    required this.onTap,
    required this.selectedTextColor,
    required this.selectedBackgroundColor,
  });

  final String name;
  final bool isSelected;
  final Color selectedTextColor;
  final Color selectedBackgroundColor;
  final void Function()? onTap;

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSelected ? width * 0.0225 : width * 0.033,
        vertical: widget.isSelected ? width * 0.0225 : width * 0.033,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: widget.isSelected ? 1 : 0.6,
          child: Container(
            width: width,
            height: widget.isSelected ? width * 0.3833 : width * 0.35,
            decoration: BoxDecoration(
              color: widget.isSelected ? widget.selectedBackgroundColor : white,
              border: Border.all(
                color: widget.isSelected
                    ? primaryDark
                    : primaryDark.withOpacity(0.5),
                width: widget.isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.name.toString().trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.isSelected
                        ? widget.selectedTextColor
                        : primaryDark,
                    fontSize: widget.isSelected ? width * 0.1 : width * 0.088,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(
                  widget.name == 'Vendor'
                      ? FeatherIcons.shoppingCart
                      : widget.name == 'Services'
                          ? Icons.handshake_outlined
                          : Icons.event_outlined,
                  size: widget.isSelected ? width * 0.15 : width * 0.05,
                  color: widget.isSelected
                      ? widget.selectedTextColor
                      : primaryDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

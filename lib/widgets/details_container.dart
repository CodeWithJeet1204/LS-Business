import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class DetailsContainer extends StatefulWidget {
  const DetailsContainer({
    super.key,
    required this.text,
    required this.value,
    required this.controller,
    required this.onTap,
    required this.isChanging,
    required this.width,
  });

  final String text;
  final String? value;
  final TextEditingController controller;
  final void Function() onTap;
  final bool isChanging;
  final double width;

  @override
  State<DetailsContainer> createState() => _DetailsContainerState();
}

class _DetailsContainerState extends State<DetailsContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.isChanging ? widget.width * 0.2775 : widget.width * 0.175,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary2.withOpacity(0.125),
        border: Border.all(
          width: widget.isChanging ? 2 : 0.5,
          color: primaryDark.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(widget.width * 0.0125),
      child: widget.isChanging
          ? TextField(
              autofocus: false,
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: "Change ${widget.text}",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: widget.width * 0.05),
                  child: SizedBox(
                    width: widget.width * 0.725,
                    child: AutoSizeText(
                      widget.value ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: widget.width * 0.06,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: widget.width * 0.03,
                  ),
                  child: IconButton(
                    onPressed: widget.onTap,
                    icon: const Icon(FeatherIcons.edit),
                    tooltip: "Edit ${widget.text}",
                  ),
                ),
              ],
            ),
    );
  }
}

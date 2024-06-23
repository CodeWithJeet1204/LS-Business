import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/utils/colors.dart';
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
  final controller;
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary2.withOpacity(0.125),
        border: Border.all(
          width: widget.isChanging ? 1 : 0.5,
          color: primaryDark.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(widget.width * 0.0125),
      child: widget.isChanging
          ? TextField(
              autofocus: false,
              controller: widget.controller,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Change ${widget.text}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(widget.width * 0.0175),
                  child: Text(
                    widget.text,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: widget.width * 0.025),
                      child: SizedBox(
                        width: widget.width * 0.725,
                        child: Text(
                          widget.value == null || widget.value == ''
                              ? 'N/A'
                              : widget.value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        tooltip: 'Edit ${widget.text}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

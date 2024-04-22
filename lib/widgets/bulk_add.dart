import 'dart:io';

import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class BulkAdd extends StatefulWidget {
  const BulkAdd({
    super.key,
    required this.width,
    required this.nameController,
    required this.priceController,
    required this.onTap,
    required this.onRemove,
    required this.image,
  });

  final double width;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final void Function() onTap;
  final void Function() onRemove;
  final File? image;

  @override
  State<BulkAdd> createState() => _BulkAddState();
}

class _BulkAddState extends State<BulkAdd> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 186,
      decoration: BoxDecoration(
        color: primary2.withOpacity(0.25),
        border: Border.all(
          width: 0.25,
          color: primaryDark,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: widget.width * 0.00625),
      margin: EdgeInsets.all(widget.width * 0.00625),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IMAGE
          widget.image == null
              ? InkWell(
                  onTap: widget.onTap,
                  splashColor: primary2,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: widget.width * 0.4,
                    height: 175,
                    decoration: BoxDecoration(
                      color: white,
                      border: Border.all(
                        color: primaryDark2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FeatherIcons.plus),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            color: primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: widget.width * 0.4,
                      height: 175,
                      decoration: BoxDecoration(
                        color: white,
                        border: Border.all(
                          color: primaryDark2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.file(widget.image!),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: widget.width * 0.003125,
                        right: widget.width * 0.003125,
                      ),
                      child: IconButton.filledTonal(
                        onPressed: widget.onRemove,
                        icon: Icon(
                          FeatherIcons.x,
                          size: widget.width * 0.05,
                        ),
                        tooltip: "Remove Image",
                      ),
                    ),
                  ],
                ),

          // NAME & PRICE
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME
              SizedBox(
                width: widget.width * 0.55,
                child: MyTextFormField(
                  hintText: 'Name',
                  controller: widget.nameController,
                  borderRadius: 12,
                  horizontalPadding: 0,
                  autoFillHints: [],
                ),
              ),

              // PRICE
              SizedBox(
                width: widget.width * 0.55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Rs. ',
                      style: TextStyle(
                        fontSize: widget.width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: widget.width * 0.4,
                      child: MyTextFormField(
                        hintText: 'Price',
                        controller: widget.priceController,
                        borderRadius: 12,
                        horizontalPadding: 0,
                        keyboardType: TextInputType.number,
                        autoFillHints: [],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

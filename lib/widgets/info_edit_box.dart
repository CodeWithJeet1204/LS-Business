import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class InfoEditBox extends StatelessWidget {
  const InfoEditBox({
    super.key,
    required this.head,
    required this.noOfAnswers,
    required this.content,
    required this.propertyValue,
    required this.width,
    required this.onPressed,
    this.maxLines = 1,
  });

  final String head;
  final double width;
  final dynamic content;
  final List<dynamic> propertyValue;
  final int noOfAnswers;
  final int? maxLines;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(width * 0.0125),
      margin: EdgeInsets.symmetric(
        vertical: width * 0.0133,
        horizontal: width * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                head.toString().trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: primaryDark2,
                ),
              ),
              noOfAnswers == 1
                  ? Text(
                      content.toString().trim(),
                      maxLines: maxLines,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: width * 0.05833,
                        fontWeight: FontWeight.w600,
                        color: primaryDark,
                      ),
                    )
                  : noOfAnswers == 2
                      ? Text(
                          content.toString().trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.05833,
                            fontWeight: FontWeight.w600,
                            color: primaryDark,
                          ),
                        )
                      : noOfAnswers == 3
                          ? propertyValue.isNotEmpty
                              ? SizedBox(
                                  width: width * 0.725,
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: propertyValue.length,
                                    itemBuilder: (context, index) {
                                      final e = propertyValue[index];

                                      return Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: primary2.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.015,
                                          vertical: width * 0.01,
                                        ),
                                        margin: EdgeInsets.only(
                                          right: width * 0.0125,
                                          top: width * 0.0125,
                                          bottom: width * 0.0125,
                                        ),
                                        child: Text(
                                          e.toString().trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: width * 0.05,
                                            color: primaryDark2,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Text(
                                  'N/A',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                          : Container(),
            ],
          ),
          noOfAnswers != 2
              ? IconButton(
                  onPressed: onPressed,
                  icon: const Icon(
                    FeatherIcons.edit,
                    color: primaryDark,
                  ),
                  tooltip: 'Edit $head',
                )
              : Container(),
        ],
      ),
    );
  }
}

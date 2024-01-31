import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class ProductInfoBox extends StatelessWidget {
  const ProductInfoBox({
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
  final dynamic content;
  final List<dynamic> propertyValue;
  final int noOfAnswers;
  final double width;
  final int? maxLines;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  head,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: primaryDark2,
                  ),
                  maxLines: maxLines,
                ),
                noOfAnswers == 1
                    ? Text(
                        content,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: primaryDark,
                        ),
                      )
                    : noOfAnswers == 2
                        ? Text(
                            content,
                            style: TextStyle(
                              fontSize: 21,
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
                                      itemCount: 1,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: propertyValue
                                              .map(
                                                (e) => Container(
                                                  height: 40,
                                                  margin: EdgeInsets.only(
                                                    right: 4,
                                                    top: 4,
                                                    bottom: 4,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: primary2
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    e,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: primaryDark2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      },
                                    ),
                                  )
                                : Text("N/A")
                            : Container(),
              ],
            ),
            noOfAnswers != 2
                ? IconButton(
                    onPressed: onPressed,
                    icon: Icon(
                      Icons.edit,
                      color: primaryDark,
                    ),
                    tooltip: "Edit ${head}",
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

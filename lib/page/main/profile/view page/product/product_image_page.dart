import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class ProductImageView extends StatefulWidget {
  const ProductImageView({
    super.key,
    required this.imagesUrl,
  });

  final List imagesUrl;

  @override
  State<ProductImageView> createState() => _ProductImageViewState();
}

class _ProductImageViewState extends State<ProductImageView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;

          return Column(
            children: [
              SizedBox(
                width: width,
                height: width * 1.575,
                child: InteractiveViewer(
                  child: Image.network(
                    widget.imagesUrl[currentIndex],
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0125,
                ),
                child: SizedBox(
                  width: width,
                  height: width * 0.2,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imagesUrl.length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: primaryDark,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                widget.imagesUrl[index],
                                height: width * 0.175,
                                width: width * 0.175,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

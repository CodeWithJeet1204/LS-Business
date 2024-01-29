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
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          return Column(
            children: [
              Container(
                width: width,
                height: height * 0.86,
                child: InteractiveViewer(
                  child: Image.network(
                    widget.imagesUrl[currentIndex],
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              SizedBox(height: height * 0.025),
              SizedBox(
                width: width,
                height: height * 0.1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imagesUrl.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          // print(index);
                          setState(() {
                            currentIndex = index;
                          });
                          print(currentIndex);
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
                              height: height * 0.1,
                              width: height * 0.1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: height * 0.01),
            ],
          );
        },
      ),
    );
  }
}

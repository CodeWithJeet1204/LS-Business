import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/product_image_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/product_info_box.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentIndex = 0;

  // void change (String propertyName, List propertyValue) async {
  //   await FirebaseFirestore.instance
  //       .collection('Business')
  //       .doc('Data')
  //       .collection('Products')
  //       .doc(widget.productId)
  //       .update({

  //       });
  // }

  @override
  Widget build(BuildContext context) {
    final productStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;
          // double height = constraints.maxHeight;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: SizedBox(
                width: width,
                child: StreamBuilder(
                    stream: productStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Something Went Wrong'),
                        );
                      }

                      if (snapshot.hasData) {
                        final productData = snapshot.data!;
                        // final Map<String, dynamic> data = productData;
                        final String name = productData['productName'];
                        final String price = productData['productPrice'];
                        final String description =
                            productData['productDescription'];
                        final String brand = productData['productBrand'];
                        final List images = productData['images'];

                        final Map<String, dynamic> properties =
                            productData['Properties'];
                        final String propertyName0 =
                            properties['propertyName0'];
                        final String propertyName1 =
                            properties['propertyName1'];
                        final String propertyName2 =
                            properties['propertyName2'];
                        final String propertyName3 =
                            properties['propertyName3'];
                        final String propertyName4 =
                            properties['propertyName4'];
                        final String propertyName5 =
                            properties['propertyName5'];

                        final List propertyValue0 =
                            properties['propertyValue0'];
                        final List propertyValue1 =
                            properties['propertyValue1'];
                        final List propertyValue2 =
                            properties['propertyValue2'];
                        final List propertyValue3 =
                            properties['propertyValue3'];
                        final List propertyValue4 =
                            properties['propertyValue4'];
                        final List propertyValue5 =
                            properties['propertyValue5'];

                        final int propertNoOfAnswers0 =
                            properties['propertyNoOfAnswers0'];
                        final int propertyNoOfAnswers1 =
                            properties['propertyNoOfAnswers1'];
                        final int propertyNoOfAnswers2 =
                            properties['propertyNoOfAnswers2'];
                        final int propertyNoOfAnswers3 =
                            properties['propertyNoOfAnswers3'];
                        final int propertyNoOfAnswers4 =
                            properties['propertyNoOfAnswers4'];
                        final int propertyNoOfAnswers5 =
                            properties['propertyNoOfAnswers5'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGES
                            CarouselSlider(
                              items: images
                                  .map(
                                    (e) => Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: primaryDark2,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: ((context) =>
                                                  ProductImageView(
                                                    imagesUrl: images,
                                                  )),
                                            ),
                                          );
                                        },
                                        child: Image.network(e),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              options: CarouselOptions(
                                enableInfiniteScroll:
                                    images.length > 1 ? true : false,
                                aspectRatio: 1.2,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),
                            // DOTS
                            images.length > 1
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: (images).map((e) {
                                        int index = images.indexOf(e);

                                        return Container(
                                          width:
                                              _currentIndex == index ? 12 : 8,
                                          height:
                                              _currentIndex == index ? 12 : 8,
                                          margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _currentIndex == index
                                                ? primaryDark
                                                : primary2,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : SizedBox(height: 36),

                            // NAME
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryDark,
                                  fontSize: name.length > 12
                                      ? 28
                                      : name.length > 10
                                          ? 30
                                          : 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // PRICE
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                price == "" ? 'N/A (price)' : 'Rs. ${price}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryDark,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // DESCRIPTION
                            FittedBox(
                              child: ProductInfoBox(
                                head: "Description",
                                content: description,
                                noOfAnswers: 1,
                                propertyValue: [],
                                maxLines: 20,
                                width: width,
                                onPressed: () {},
                              ),
                            ),

                            // BRAND
                            ProductInfoBox(
                              head: "Brand",
                              content: brand,
                              noOfAnswers: 1,
                              propertyValue: [],
                              width: width,
                              onPressed: () {},
                            ),

                            // PROPERTY 0
                            ProductInfoBox(
                              head: propertyName0,
                              content: propertyValue0,
                              noOfAnswers: propertNoOfAnswers0,
                              propertyValue: propertyValue0,
                              width: width,
                              onPressed: () {},
                            ),

                            // PROPERTY 1
                            ProductInfoBox(
                              head: propertyName1,
                              content: propertyValue1[0],
                              noOfAnswers: propertyNoOfAnswers1,
                              propertyValue: propertyValue1,
                              width: width,
                              onPressed: () {},
                            ),

                            // PROPERTY 2
                            ProductInfoBox(
                              head: propertyName2,
                              content: propertyValue2[0],
                              noOfAnswers: propertyNoOfAnswers2,
                              propertyValue: propertyValue2,
                              width: width,
                              onPressed: () {},
                            ),

                            // PROPERTY 3
                            ProductInfoBox(
                              head: propertyName3,
                              content: propertyValue3[0],
                              propertyValue: propertyValue3,
                              noOfAnswers: propertyNoOfAnswers3,
                              width: width,
                              onPressed: () {},
                            ),

                            // PROPERTY 4
                            ProductInfoBox(
                              head: propertyName4,
                              content: propertyValue4.length == 1
                                  ? propertyValue4[0]
                                  : null,
                              propertyValue: propertyValue4,
                              noOfAnswers: propertyNoOfAnswers4,
                              width: width,
                              onPressed: () {},
                            ),

                            // PROPERTY 5
                            ProductInfoBox(
                              head: propertyName5,
                              content: propertyValue5.length == 1
                                  ? propertyValue5[0]
                                  : null,
                              propertyValue: propertyValue5,
                              noOfAnswers: propertyNoOfAnswers5,
                              width: width,
                              onPressed: () {},
                            ),
                          ],
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(
                          color: primaryDark,
                        ),
                      );
                    }),
              ),
            ),
          );
        }),
      ),
    );
  }
}

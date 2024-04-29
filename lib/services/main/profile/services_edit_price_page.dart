import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/models/services_image_map.dart';
import 'package:find_easy/widgets/service_edit_price_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesEditPricePage extends StatefulWidget {
  const ServicesEditPricePage({super.key});

  @override
  State<ServicesEditPricePage> createState() => _ServicesEditPricePageState();
}

class _ServicesEditPricePageState extends State<ServicesEditPricePage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List? subCategories;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final List mySubCategories = serviceData['SubCategory'];

    setState(() {
      subCategories = mySubCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Prices'),
      ),
      body: subCategories == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.0125,
                vertical: MediaQuery.of(context).size.width * 0.00625,
              ),
              child: LayoutBuilder(
                builder: ((context, constraints) {
                  final width = constraints.maxWidth;
                  print("Sub Categories: $subCategories");

                  return SizedBox(
                    width: width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: subCategories!.length,
                      itemBuilder: ((context, index) {
                        final name = subCategories![index];
                        final imageUrl = subCategoryImageMap[name]!;
                        print("$name: $imageUrl");

                        return ServiceEditPriceContainer(
                          name: name,
                          imageUrl: imageUrl,
                          width: width,
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}

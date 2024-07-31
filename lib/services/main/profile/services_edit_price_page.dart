import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/services/models/services_image_map.dart';
import 'package:Localsearch/widgets/service_edit_price_container.dart';
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
  Map<String, dynamic>? subCategories;

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

    final Map<String, dynamic> mySubCategories = serviceData['SubCategory'];

    setState(() {
      subCategories = mySubCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prices'),
      ),
      body: subCategories == null
          ? const Center(
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

                  return SizedBox(
                    width: width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: subCategories!.length,
                      itemBuilder: ((context, index) {
                        final sortedEntries = subCategories!.entries.toList();

                        sortedEntries.sort((a, b) => a.key.compareTo(b.key));

                        subCategories = Map.fromEntries(sortedEntries);

                        final name = subCategories!.keys.toList()[index];
                        final price =
                            subCategories!.values.toList()[index][0].toString();
                        final imageUrl = subCategoryImageMap[name]!;

                        return ServiceEditPriceContainer(
                          name: name,
                          price: price,
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

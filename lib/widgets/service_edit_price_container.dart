import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceEditPriceContainer extends StatefulWidget {
  const ServiceEditPriceContainer({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.width,
  });

  final String name;
  final String price;
  final String imageUrl;
  final double width;

  @override
  State<ServiceEditPriceContainer> createState() =>
      _ServiceEditPriceContainerState();
}

class _ServiceEditPriceContainerState extends State<ServiceEditPriceContainer> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final priceController = TextEditingController();
  bool isEdit = false;
  String? currentPrice;
  String? currentPriceMethod;

  // INIT STATE
  @override
  void initState() {
    setState(() {
      currentPrice = widget.price;
    });
    getPriceMethod();
    super.initState();
  }

  // GET PRICE METHOD
  Future<void> getPriceMethod() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final Map<String, dynamic> allSubCategories = serviceData['SubCategory'];

    final currentValue = allSubCategories[widget.name];

    final String currentSearchMethod = currentValue[1];

    setState(() {
      currentPriceMethod = currentSearchMethod;
    });
  }

  // CHANGE PRICE
  Future<void> changePrice() async {
    if (double.parse(priceController.text) > 1 &&
        double.parse(priceController.text) < 1000000000) {
      setState(() {
        currentPrice = priceController.text;
        isEdit = false;
      });
      final serviceSnap =
          await store.collection('Services').doc(auth.currentUser!.uid).get();

      final serviceData = serviceSnap.data()!;

      final Map<String, dynamic> allSubCategories = serviceData['SubCategory'];

      final List currentSubCategory = allSubCategories[widget.name];

      currentSubCategory[0] = int.parse(priceController.text);

      allSubCategories[widget.name] = currentSubCategory;

      await store.collection('Services').doc(auth.currentUser!.uid).update({
        'SubCategory': allSubCategories,
      });
    } else {
      return mySnackBar(context, 'Price Range is Rs. 1 to 100 Crores');
    }
  }

  // CHANGE PRICE METHOD
  Future<void> changePriceMethod(String value) async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final Map<String, dynamic> allSubCategories = serviceData['SubCategory'];

    final List currentSubCategory = allSubCategories[widget.name];

    currentSubCategory[1] = value;

    allSubCategories[widget.name] = currentSubCategory;

    await store.collection('Services').doc(auth.currentUser!.uid).update({
      'SubCategory': allSubCategories,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 168,
      decoration: BoxDecoration(
        color: lightGrey,
        border: Border.all(
          width: 0.5,
          color: darkGrey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(widget.width * 0.00625),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: widget.width * 0.4,
            height: 160,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: widget.width * 0.5,
                child: Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.width * 0.06,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              isEdit
                  ? SizedBox(
                      width: widget.width * 0.5,
                      child: TextField(
                        controller: priceController,
                        autofocus: true,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        keyboardType: TextInputType.number,
                        minLines: 1,
                        maxLines: 1,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[0-9]*$'),
                          ),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.cyan.shade700,
                            ),
                          ),
                          hintText: 'Price',
                        ),
                      ),
                    )
                  : Container(
                      width: widget.width * 0.5,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(widget.width * 0.0225),
                      child: Text(
                        widget.price == '0' ? '--' : 'Rs. $currentPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: widget.width * 0.05,
                        ),
                      ),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  currentPriceMethod == null
                      ? Container(
                          width: widget.width * 0.4,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(widget.width * 0.0225),
                        )
                      : Container(
                          width: widget.width * 0.4,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(widget.width * 0.0225),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: widget.width * 0.1,
                                child: Text(
                                  'Per',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.w500,
                                    fontSize: widget.width * 0.0525,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: widget.width * 0.255,
                                child: DropdownButton(
                                  dropdownColor: primary,
                                  underline: const SizedBox(),
                                  hint: Text(currentPriceMethod!),
                                  value: currentPriceMethod,
                                  items: ['Service', 'Hour', 'Day']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  onChanged: (value) async {
                                    setState(() {
                                      currentPriceMethod = value;
                                    });
                                    await changePriceMethod(value!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                  IconButton(
                    onPressed: () async {
                      if (isEdit) {
                        await changePrice();
                      } else {
                        setState(() {
                          isEdit = true;
                        });
                      }
                    },
                    icon: Icon(
                      isEdit ? FeatherIcons.check : FeatherIcons.edit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

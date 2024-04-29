import 'package:find_easy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class ServiceEditPriceContainer extends StatefulWidget {
  const ServiceEditPriceContainer({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.width,
  });

  final String name;
  final String imageUrl;
  final double width;

  @override
  State<ServiceEditPriceContainer> createState() =>
      _ServiceEditPriceContainerState();
}

class _ServiceEditPriceContainerState extends State<ServiceEditPriceContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 200,
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
            height: 192,
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
                    fontSize: widget.width * 0.05,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

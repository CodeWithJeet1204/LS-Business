import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/utils/colors.dart';

class AddBox extends StatefulWidget {
  const AddBox({
    super.key,
    required this.context,
    required this.width,
    required this.icon,
    required this.label,
    required this.page,
  });

  final BuildContext context;
  final double width;
  final IconData icon;
  final String label;
  final Widget page;

  @override
  State<AddBox> createState() => _AddBoxState();
}

class _AddBoxState extends State<AddBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(194, 236, 255, 1),
            Color.fromRGBO(227, 242, 253, 1),
            Color.fromRGBO(241, 249, 255, 1),
            Color.fromRGBO(255, 241, 244, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(widget.width * 0.045),
      margin: EdgeInsets.symmetric(
        horizontal: widget.width * 0.045,
        vertical: widget.width * 0.0225,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => widget.page,
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: widget.width * 0.15,
              height: widget.width * 0.15,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.icon,
                size: widget.width * 0.1,
                color: primaryDark2,
              ),
            ),
            SizedBox(width: widget.width * 0.045),
            Expanded(
              child: AutoSizeText(
                widget.label,
                maxLines: 1,
                style: TextStyle(
                  color: primaryDark,
                  fontSize: widget.width * 0.0775,
                ),
              ),
            ),
            SizedBox(width: widget.width * 0.045),
            Icon(
              Icons.arrow_forward_ios,
              size: widget.width * 0.05,
              color: primaryDark2,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  final String categoryName = "Pens";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 21,
        physics: ClampingScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: ((context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: primaryDark2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        'https://yt3.googleusercontent.com/oSx8mAQ3_f9cvlml2wntk2_39M1DYXMDpSzLQOiK4sJOvypCMFjZ1gbiGQs62ZvRNClUN_14Ow=s900-c-k-c0x00ffffff-no-rj',
                        height: 100,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    ),
                    Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}






// import 'package:find_easy/utils/colors.dart';
// import 'package:flutter/material.dart';

// class CategoriesPage extends StatelessWidget {
//   const CategoriesPage({super.key});
//   final String categoryName = "Pens";
//   final int categoryItemsLength = 20;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: 21,
//         physics: ClampingScrollPhysics(),
//         itemBuilder: ((context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
//             child: ListTile(
//               tileColor: primary2,
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(9),
//                 child: Image.network(
//                   'https://yt3.googleusercontent.com/oSx8mAQ3_f9cvlml2wntk2_39M1DYXMDpSzLQOiK4sJOvypCMFjZ1gbiGQs62ZvRNClUN_14Ow=s900-c-k-c0x00ffffff-no-rj',
//                   height: 100,
//                   filterQuality: FilterQuality.none,
//                 ),
//               ),
//               title: Text(categoryName),
//               subtitle: Text(categoryItemsLength.toString()),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
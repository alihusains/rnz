// import 'package:flutter/material.dart';
// import 'package:raazoneyaz/database_helper.dart';

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Duas and Aamal',
//           // style: AppStyles.titleStyle,
//         ),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: DatabaseHelper().getDistinctLevel1Items(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final level1Items = snapshot.data!;
//           return ListView.separated(
//             itemCount: level1Items.length,
//             separatorBuilder: (context, index) => const Divider(
//               height: 1,
//               thickness: 0.5,
//             ), // Divider between items
//             itemBuilder: (context, index) {
//               final level1 = level1Items[index]['EnglishName'];

//               return ListTile(
//                 title: Text(
//                   level1 ?? 'No Title',
//                   // style: AppStyles.gujaratiTextStyle,
//                 ),
//                 trailing: const Icon(
//                     Icons.arrow_forward), // Arrow icon for navigation
//                 onTap: () {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     builder: (context) => Level2Screen(level1: level1),
//                   //   ),
//                   // );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



// import 'package:booking_appointmemt/consts/consts.dart';

// import 'home_screen_view_2.dart';

// class HomeViews extends StatelessWidget {
//   const HomeViews({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Opacity(
//                 opacity: 0.2,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(AppAssets.imgSignup),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                    Image(image: AssetImage(AppAssets.imgSignup)),
//                     40.heightBox,
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const HomeScreen2(),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: MediaQuery.of(context).size.width - 50,
//                         alignment: Alignment.center,
//                         padding: const EdgeInsets.all(
//                             15), // Adjust padding as needed
//                         decoration: BoxDecoration(
//                             color: Colors.blueAccent,
//                             borderRadius: BorderRadius.circular(10),
//                             gradient: const LinearGradient(
//                                 colors: [
//                                   Color.fromARGB(255, 65, 180, 132),
//                                   Color.fromARGB(255, 45, 73, 150)
//                                 ],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                                 tileMode: TileMode.clamp)),
//                         child: const Text(
//                           "Let's Go ",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20, // Adjust the font size as needed
//                             color: Colors.white, // Text color
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

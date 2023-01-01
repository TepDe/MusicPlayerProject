// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'MusicAppGetXState.dart';
//
// class BottomSheetBuilder {
//
//   final mc = Get.put(MusicController());
//
//   bottomSheetBuild() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             IconButton(
//               onPressed: () async {
//                 // mc.markindex = mc.nextsong;
//                 // mc.songName.value = (mc.storageList[mc.nextsong].title).toString();
//                 // await mc.superControl(id: 1);
//               },
//               icon: const Icon(Icons.skip_previous, size: 40),
//             ),
//             CircleAvatar(
//               backgroundColor: Colors.blue,
//               radius: 30,
//               child: Align(
//                 alignment: Alignment.center,
//                 child: IconButton(
//                   onPressed: () async {
//                     // await mc.superControl(id: 2);
//                   },
//                   icon:  const Icon(Icons.pause, size: 40),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () async {
//                 // mc.songName.value = (mc.storageList[mc.nextsong].title).toString();
//                 // mc.markindex = mc.nextsong;
//                 // await mc.superControl(id: 3);
//               },
//               icon: const Icon(
//                 Icons.skip_next,
//                 size: 40,
//               ),
//             )
//           ],
//         ),
//
//
//         // Row(
//         //   children: [
//         //     GetX<MusicController>(
//         //       builder: (_) => Slider(
//         //         value: mc.position.value.inSeconds.toDouble(),
//         //         max: mc.duration.value.inSeconds.toDouble(),
//         //         min: 0.0,
//         //         divisions: 100,
//         //         // label: slider.round().toString(),
//         //         onChanged: (double value) {
//         //           final position = Duration(seconds: value.toInt());
//         //           mc.player.seek(position);
//         //           mc.player.play();
//         //         },
//         //       ),
//         //     )
//         //   ],
//         // )
//       ],
//     );
//   }
// }

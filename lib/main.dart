import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:untitled2/Rodium/RodiumHome.dart';

void main() {
  runApp(
      const GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
       RhodiumHomeScreen(),
      // Rodium(),
    );
  }
}
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   void onNextScreen() async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const HomeScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return HomeScreen();
//
//     //   Scaffold(
//     //   backgroundColor: Colors.black,
//     //   body:  Column(children: [FlatButton(onPressed: (){onNextScreen() ;}, child: Text("Next",style: TextStyle(color: Colors.red),),)],),
//     // );
//   }
// }

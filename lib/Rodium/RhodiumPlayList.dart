import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'RhodiumAllMusic.dart';
import 'Themes.dart';

class PlayListScreen extends StatelessWidget {
  /////playerList
  final theme = AppThemes();
  final go = Get.put(GetObject());
  final mc = Get.put(MusicController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: theme.greys,
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: theme.blacks,
          actions: const [
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                width: Get.width,
                height: 200,
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Obx(() => Text(
                            go.adas.value,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() => Flexible(
              child: ListView.builder(
                  padding:
                  const EdgeInsets.only(bottom: 18, left: 18, right: 8, top: 8),
                  itemCount: go.musicList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: (){
                            go.superController(index);
                          },
                          trailing: Obx(
                                () => Text("${go.trailingList[index]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: theme.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.music_note_sharp),
                            ),
                          ),
                          subtitle:  Text("${go.subtitleList[index]}",
                              style: const TextStyle(
                                color: Colors.white,
                              )),
                          title:  Text("${go.Title[index]}",
                              style: const TextStyle(
                                color: Colors.white,
                              )),
                        ),
                        Divider(
                          color: theme.white,
                        )
                      ],
                    );
                  }),
            )),
            Spacer(flex: 2),
            mc.renderBtnControl(context: context,songPath:  mc.songPath)

          ],
        ));
  }
}

class GetObject extends GetxController {
  var argumentData = Get.arguments;
  var adas = ''.obs;
  var adass = ''.obs;
  var getparam = ''.obs;
  var musicList = ["23213"].obs;
  var trailingList = ['312'].obs;
  var Image = ['321'].obs;
  var subtitleList = ['312'].obs;
  var Title = ['3123'].obs;
  getParam() {
    adas.value = argumentData[0]['first'];
    update();
  }

  superController(atindex){
    Get.to(()=>PlayListScreen(), arguments: [
      {"first": Title[atindex]},
    ]);
  }

  @override
  void onInit() {
    getParam();

    super.onInit();
  }
}

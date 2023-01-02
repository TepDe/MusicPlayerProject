import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/Rodium/GlobalControl/glbControl.dart';
import 'package:untitled2/Rodium/RhodiumAllMusic.dart';
import 'package:untitled2/Rodium/RhodiumPlayList.dart';
import 'Themes.dart';

class RhodiumHomeScreen extends StatelessWidget {
  ////main homeScreen
  final theme = AppThemes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: theme.greys,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Rhodium',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: theme.blacks,
          actions: [
            IconButton(
                onPressed: () async {
                  pla.clearAllLocalPlayList();
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  unitOne(),
                  unitOne(),
                  unitOne(),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 18, left: 18, right: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Play List',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  // IconButton(
                  //     onPressed: () {
                  //                        pla.addOnList();
                  //     },
                  //     icon: Icon(Icons.add)),
                  InkWell(
                    onTap: () {
                      pla.addOnList(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [Text("Add PlayList"), Icon(Icons.add)],
                      ),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  )
                ],
              ),
            ),
            unitTwo(),
            mc.renderBtnControl(context: context)
          ],
        ));
  }

  unitOne({listName}) {
    return InkWell(
      onTap: () async {
        // Get.to(() => PlayListScreen(), arguments: [
        //   {"first": Title[atindex]},
        // ]);
        Get.to(RhodiumAllSong());
      },
      child: Container(
        width: 170,
        height: 170,
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: theme.halfGreys,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              size: 90,
              color: theme.white,
            ),
            Text(
              'All Song',
              style: TextStyle(
                color: theme.white,
              ),
            ),
            Text(
              'Description',
              style: TextStyle(
                color: theme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final mc = Get.put(MusicController());
  final pla = Get.put(PlayListAddOn());
  final str = StrKey();

  unitTwo() {
    return Flexible(
      child: Container(
        color: theme.darkGreys,
        child: Obx(() => ListView.builder(
            padding:
                const EdgeInsets.only(bottom: 18, left: 18, right: 8, top: 8),
            itemCount: pla.Title.value.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      pla.sentPara(index, context);
                    },
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return {'Add to playlist', 'Settings'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                      onSelected: (value) {},
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
                    subtitle: Text("Track 0",
                        style: TextStyle(
                          color: theme.halfGreys,
                        )),
                    title: Text("${pla.Title[index]}",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                  Divider(
                    color: theme.white,
                  )
                ],
              );
            })),
      ),
    );
  }
}

class PlayListAddOn extends GetxController {
  String list = '';
  var Image = [].obs;
  var subtitleList = [].obs;
  var Title = [].obs;
  List<PlayListObj> musicObj = [];
  final strkey = StrKey();
  var param;
  List<String> titleStr = [];
  List<String> subtitleStr = [];

  final theme = AppThemes();

  late SharedPreferences saveLocal;
  List<String> itemsec = [];
  List<String> listToPlay = [];

  PlayListAddOn() {
    onInit();
  }

  @override
  void onInit() async {
    // var newList = [list1, list2, list3].expand((x) => x).toList()
    saveLocal = await SharedPreferences.getInstance();
    List<String> item = saveLocal.getStringList(strkey.saveTitleList) ?? [];
    itemsec = saveLocal.getStringList(strkey.saveTitleListSec) ?? [];
    itemsec = itemsec + item;
    saveLocal.setStringList(strkey.saveTitleListSec, itemsec);
    Title.value = itemsec;
    listToPlay = itemsec;
    update();

    await saveLocal.remove(strkey.saveTitleList);

    FocusManager.instance.primaryFocus?.unfocus();
    super.onInit();
  }

  addOnList(context) {
    showMyDialog(context);
    // Image.add("title");
    // subtitleList.add("1");
    // Title.add("Player Title");
    // param = Title[2];
    update();
  }

  sentPara(atindex, context) {
    Get.to(() => PlayListScreen(), arguments: [
      {"first": Title[atindex]},
    ]);
  }

  var textField = TextEditingController().obs;

  Future<void> showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.halfGreys,
          title: const Text('PlayList Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: textField.value,
                  onSubmitted: (value) async {
                    saveLocalPlaylist(context: context);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.white),
                  ),
                  onPressed: () {
                    textField.value.clear();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: theme.white),
                  ),
                  onPressed: () async {
                    //trailingList.add("das");
                    saveLocalPlaylist(context: context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  clearAllLocalPlayList() async {
    await saveLocal.remove(strkey.saveTitleListSec);
    await saveLocal.remove(strkey.saveTitleList);
    Title.value = [];
  }

  List<String> dasd= [];
  saveLocalPlaylist({context}) async {
    Title.add(textField.value.text);
    titleStr.add(textField.value.text);

    await saveLocal.setStringList(strkey.saveTitleList, titleStr);
    final fjf=  saveLocal.setStringList(strkey.saveTitleListSec, itemsec);

    textField.value.clear();
    Navigator.pop(context);
    update();
  }
}

class PlayListObj {
  String name = '';
  List<SongObject> song = [];

  PlayListObj({name, song});
}

class SongObject {
  String name = '';
  int index = 0;
  var image;
  String playtime = '';
}

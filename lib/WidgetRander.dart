import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'Controller.dart';
import 'package:get/get.dart';

import 'Rodium/RhodiumPlayList.dart';

class WidgetRender {
  int _selectedIndex = 0;

  var colorBlack = const Color.fromRGBO(0, 0, 0, 0);
  var colorWhite = const Color.fromRGBO(255, 255, 255, 0);
  var colorGrey = const Color.fromRGBO(97, 106, 107, 100);
  var colorGreys = Colors.black45;

  ControllerOperation op = ControllerOperation();
  String songtitles = '';

  bottomNavigationBar(String? title) {
    return BottomNavigationBar(
      selectedFontSize: 20,
      iconSize: 35,
      backgroundColor: Colors.green,
      type: BottomNavigationBarType.fixed,
      unselectedFontSize: 20,
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.black,
      onTap: op.onItemTapped,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(label: 'title', icon: SizedBox()),
        BottomNavigationBarItem(label: title.toString(), icon: SizedBox()),
        BottomNavigationBarItem(
            label: '', icon: Icon(Icons.skip_previous, color: Colors.white)),
        BottomNavigationBarItem(
            label: '', icon: Icon(Icons.pause, color: Colors.white)),
        BottomNavigationBarItem(
            label: '', icon: Icon(Icons.skip_next, color: Colors.white)),
      ],
    );
  }

  playerList(context) {
    return InkWell(
      onTap: () {
        Get.to(PlayListScreen());
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) =>  PlayListScreen(),
        //   ),
        // );
      },
      child: Container(
        height: 100,
        child: Center(child: Text("data")),
      ),
    );
  }

  final OnAudioQuery _audioQuery = OnAudioQuery();

  musicList() {
    return Flexible(
      child: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(
              child: Text("No Songs Found"),
            );
          }
          return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(left: 5, right: 5.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListTile(
                    textColor: Colors.grey,
                    title: Text(
                      item.data![index].title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.data![index].displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
                    ),
                    onTap: () async {
                      op.toast(context,
                          "You Selected:   " + item.data![index].title);

                      // await op.startPlay(
                      //     path: item.data![index].uri,
                      //     title: item.data![index].title.toString());
                      // op.songtitle = (item.data![index].title).toString();
                    },
                  ),
                );
              });
        },
      ),
    );
  }

  controlBtn({icons}) {
    return CircleAvatar(
      child: IconButton(
        onPressed: () {},
        icon: icons,
        color: Colors.white,
      ),
      radius: 30,
      backgroundColor: Colors.orange,
    );
  }
}

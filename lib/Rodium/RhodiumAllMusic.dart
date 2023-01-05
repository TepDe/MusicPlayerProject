import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/Rodium/GlobalControl/glbControl.dart';
import 'package:untitled2/Rodium/RodiumHome.dart';
import 'Themes.dart';

class RhodiumAllSong extends StatelessWidget {
  ////All Music
  final mc = Get.put(MusicController());
  final themes = AppThemes();
  final pla = Get.put(PlayListAddOn());
  late SharedPreferences saveLocal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('All Song'),
        actions: const [],
      ),
      body: Container(
        color: themes.darkGreys,
        child: Column(
          children: [
            Flexible(
                child: Obx(
              () => FutureBuilder<List<SongModel>>(
                future: mc.audioQuery.value.querySongs(
                  sortType: null,
                  orderType: OrderType.ASC_OR_SMALLER,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true,
                ),
                builder: (context, item) {
                  if (item.data == null) {
                    return const CircularProgressIndicator();
                  }
                  if (item.data!.isEmpty) {
                    return const Text("Nothing found!");
                  }
                  mc.storageList = item.data!;
                  mc.lengthCatch.value = item.data!.length;
                  return GetBuilder<MusicController>(
                    builder: (_dx) => ListView.builder(
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        mc.firstSong.value = item.data![0].uri!;
                        return Container(
                          color: themes.darkGreys,
                          child: ListTile(
                            title: Text(
                              item.data![index].title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: mc.nextsong == index?  Colors.blue : Colors.white),
                            ),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                        item.data![index].artist ??
                                            "No Artist",
                                        style: TextStyle(  color: mc.nextsong == index?  Colors.lightBlueAccent : Colors.white),
                                        overflow: TextOverflow.ellipsis)),
                                //Flexible(flex:1,child: Obx(()=> Text("${mc.duration.value}" ,style: TextStyle(color: Colors.red),overflow: TextOverflow.ellipsis))),
                              ],
                            ),
                            trailing: GetBuilder<MusicController>(
                              builder: (_) => PopupMenuButton<String>(
                                itemBuilder: (BuildContext context) {
                                  return {'Add to playlist', 'Settings'}
                                      .map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                                onSelected: (value) {
                                  mc.handleClick(
                                      value: value,
                                      context: context,
                                      path: item.data![index].uri);
                                },
                              ),
                            ),
                            onTap: () async {
                              // mc.songName.value =
                              //     (mc.storageList[mc.nextsong].title).toString();
                              mc.nextsong = index;
                              mc.songPath = item.data![index].uri;
                              mc.songImage.value = item.data![index].id;
                              mc.superControl(
                                  id: 4, songPath: item.data![index].uri);
                            },
                            leading: QueryArtworkWidget(
                              id: item.data![index].id,
                              type: ArtworkType.AUDIO,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )),
            mc.renderBtnControl(context: context, songPath: mc.songPath)
          ],
        ),
      ),
    );
  }
}

class MusicController extends GetxController {
  var songName = 'song name'.obs;
  var songImage = 0.obs;
  var songPath;
  final audioQuery = OnAudioQuery().obs;
  double slider = 0;
  var isplaypause = false.obs;
  bool isPlaying = false;
  int playTime = 0;
  int currentPlayTime = 0;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var player = AudioPlayer();
  int? markCurrentPlay;
  var firstSong = ''.obs;
  List<SongModel> storageList = [];
  var nextsong = 0;
  Color SuperColor = Colors.grey;
  var isWhilePlay = false;
  var isShuffle = false.obs;
  var isLoop = false.obs;
  var whenEnd;
  var atLoopIndex = 0.obs;
  var argumentData = Get.arguments;
  var getPlay = [].obs;
  final themes = AppThemes();
  var Title = [].obs;
  final hs = Get.put(PlayListAddOn());
  var itemsec = [].obs;
  var lengthCatch = 0.obs;
  var getPlayPause ;

  @override
  void onInit() async {
    print("screens builded");
    await requestStorage();
    hs.saveLocal = await SharedPreferences.getInstance();

    List test = hs.saveLocal.getStringList(hs.strkey.saveTitleListSec) ?? [];
    itemsec.value = test;
    player.durationStream.listen((event) {
      isPlaying = event == player.playing;
      whenEnd = event;
      print(event);
    });
    player.positionStream.listen((event) {
      isPlaying = event == player.playing;
      getPlayPause = event;
      if (event >= whenEnd) {
        if (isShuffle == true) {
          //superControl(id: 6);
          onShuffle();
        } else if (isShuffle == false) {
          onLoopSong();
        }
      } else {}

      print(event);
    });
    player.durationStream.listen((eventdur) {
      duration.value = eventdur!;
    });
    player.positionStream.listen((event) {
      position.value = event;
    });
  }

  superControl({id, songPath, index}) async {
    if (id == 1) {
      nextsong--;
      if (nextsong == -1) {
        nextsong = lengthCatch.value - 1;
        update();
        controlPlaying(isNextBack: nextsong);
      } else {
        update();
        controlPlaying(isNextBack: nextsong);
      }
    } else if (id == 2) {
      if (isplaypause.value == true) {
        // isplaypause.value = false;
        // songImage.value = storageList[nextsong].id;
        isplaypause.value = false;
        player.pause();
      } else if (isplaypause.value == false) {
        // isplaypause.value = true;
        // songImage.value = storageList[nextsong].id;
        // songName.value = storageList[nextsong].title.toString();
        // await player.setAudioSource(
        //     AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        isplaypause.value = true;
        player.seek(getPlayPause);
        await player.play();
      }
    } else if (id == 3) {
      nextsong++;
      if (nextsong == lengthCatch) {
        nextsong = 0;
        controlPlaying(isNextBack: nextsong);
      } else {
        controlPlaying(isNextBack: nextsong);
      }
    } else if (id == 4) {
      print(markCurrentPlay);
      markCurrentPlay = nextsong;
      update();
      atLoopIndex.value = nextsong;
      isplaypause.value = true;
      songName.value = storageList[nextsong].title.toString();
      await player.setAudioSource(AudioSource.uri(Uri.parse(songPath)));
      await player.play();
    } else if (id == 5) {
      // loop
      isShuffle.value = false;
      isLoop.value = true;
    } else if (id == 6) {
      // //shuffle
      isShuffle.value = true;
      isLoop.value = false;
    }
  }

  controlPlaying({isNextBack}) async {
    isplaypause.value = true;
    markCurrentPlay = nextsong;
    update();
    atLoopIndex.value = nextsong;
    songImage.value = storageList[nextsong].id;
    songName.value = storageList[nextsong].title;
    await player.setAudioSource(
        AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
    await player.play();
  }

  onShuffle() async {
    nextsong++;
    isplaypause.value = true;
    nextsong = nextsong;
    //markCurrentPlay = nextsong;
    //atLoopIndex.value = nextsong;
    update();
    songImage.value = storageList[nextsong].id;
    songName.value = storageList[nextsong].title;
    await player.setAudioSource(
        AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
    await player.play();
  }

  renderBtnControl({context, songPath}) {
    return GetBuilder<MusicController>(
        builder: (controller) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  showModalBottomSheet<MusicController>(
                    enableDrag: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Flexible(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {},
                                    icon: const Icon(Icons.more_vert, size: 40),
                                  ),
                                ],
                              ),
                              Spacer(flex: 5),
                              songImage == null
                                  ? Container()
                                  : Obx(
                                      () => QueryArtworkWidget(
                                        artworkHeight: 300,
                                        artworkWidth: 300,
                                        id: songImage.value,
                                        type: ArtworkType.AUDIO,
                                      ),
                                    ),
                              Obx(() => songName.value == null
                                  ? Text("")
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Text("${songName.value}"),
                                    )),
                              Spacer(flex: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () async {},
                                    icon: const Icon(
                                      Icons.list_alt,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {},
                                    icon: const Icon(Icons.favorite, size: 40),
                                  ),
                                  IconButton(
                                    onPressed: () async {},
                                    icon: const Icon(Icons.add, size: 40),
                                  ),
                                ],
                              ),
                              position.value.inSeconds == null
                                  ? Container()
                                  : GetX<MusicController>(
                                      builder: (_) => Slider(
                                        value:
                                            position.value.inSeconds.toDouble(),
                                        max:
                                            duration.value.inSeconds.toDouble(),
                                        min: 0.0,
                                        divisions: 100,
                                        // label: slider.round().toString(),
                                        onChanged: (double value) {
                                          final position =
                                              Duration(seconds: value.toInt());
                                          player.seek(position);
                                          player.play();
                                        },
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(() => Text(
                                        formatTime(position.value.inSeconds))),
                                    Obx(() => Text(
                                        formatTime(duration.value.inSeconds))),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      songImage.value =
                                          storageList[nextsong].id;
                                      songName.value =
                                          (storageList[nextsong].title)
                                              .toString();
                                      markCurrentPlay = nextsong;
                                      await superControl(id: 1);
                                    },
                                    icon: const Icon(
                                      Icons.skip_previous,
                                      size: 40,
                                    ),
                                  ),
                                  Obx(
                                    () => IconButton(
                                      onPressed: () async {
                                        await superControl(id: 2);
                                      },
                                      icon: isplaypause == false
                                          ? const Icon(Icons.play_arrow,
                                              size: 40)
                                          : const Icon(Icons.pause, size: 40),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // markCurrentPlay = nextsong;
                                      // songImage.value =
                                      //     storageList[nextsong].id;
                                      //
                                      // songName.value =
                                      //     (storageList[nextsong].title)
                                      //         .toString();
                                      await superControl(id: 3);
                                    },
                                    icon: const Icon(Icons.skip_next, size: 40),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      //onLoopSong();
                                      superControl(id: 5);
                                    },
                                    icon: Obx(() => Icon(
                                          Icons.loop,
                                          size: 40,
                                          color: isLoop == true
                                              ? Colors.blue
                                              : Colors.grey,
                                        )),
                                  ),
                                  Icon(Icons.volume_up_rounded, size: 40),
                                  position.value.inSeconds == null
                                      ? Container()
                                      : GetX<MusicController>(
                                          builder: (_) => Slider(
                                            value: position.value.inSeconds
                                                .toDouble(),
                                            max: duration.value.inSeconds
                                                .toDouble(),
                                            min: 0.0,
                                            divisions: 100,
                                            // label: slider.round().toString(),
                                            onChanged: (double value) {
                                              final position = Duration(
                                                  seconds: value.toInt());
                                              player.seek(position);
                                              player.play();
                                            },
                                          ),
                                        ),
                                  IconButton(
                                    onPressed: () async {
                                      superControl(id: 6);
                                    },
                                    icon: Obx(() => Icon(
                                          Icons.shuffle,
                                          size: 40,
                                          color: isShuffle == true
                                              ? Colors.blue
                                              : Colors.grey,
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Color(0xFFA0A0A0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 4,
                                child: GetX<MusicController>(
                                  builder: (_) => Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "${songName}",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        markCurrentPlay = nextsong;
                                        songName.value =
                                            (storageList[nextsong].title)
                                                .toString();
                                        await superControl(id: 1);
                                      },
                                      icon: const Icon(Icons.skip_previous,
                                          size: 40),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: IconButton(
                                        onPressed: () async {
                                          await superControl(id: 2);
                                        },
                                        icon: isplaypause == false
                                            ? const Icon(Icons.play_arrow,
                                                size: 40)
                                            : const Icon(Icons.pause, size: 40),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        songName.value =
                                            (storageList[nextsong].title)
                                                .toString();
                                        markCurrentPlay = nextsong;
                                        await superControl(id: 3);
                                      },
                                      icon: const Icon(
                                        Icons.skip_next,
                                        size: 40,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  handleClick({String? value, context, path}) {
    if (value == "Add to playlist") {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: themes.halfGreys,
            title: const Text('Playlist'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('This is a demo alert dialog.'),
                  SizedBox(
                    width: 200,
                    height: 230,
                    child: Obx(() => ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: itemsec.value.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Flexible(
                              child: InkWell(
                            onTap: () {},
                            child: SizedBox(
                              width: Get.width,
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Obx(() => Text(
                                      '+++${itemsec.value[index]}',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    )),
                              ),
                            ),
                          ));
                        })),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Approve'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return Container();
    }
  }

  onLoopSong() async {
    isplaypause.value = true;
    markCurrentPlay = atLoopIndex.value;
    songImage.value = storageList[atLoopIndex.value].id;
    songName.value = storageList[atLoopIndex.value].title;
    await player.setAudioSource(AudioSource.uri(
        Uri.parse((storageList[atLoopIndex.value].uri).toString())));
    await player.play();
  }

  dragBottom() {
    return DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.75,
        minChildSize: 0.75,
        expand: true,
        builder: (context, scrollController) {
          return Container();
        });
  }

  // renderBtnControls(context, songPath) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: InkWell(
  //       onTap: () {
  //         showModalBottomSheet<void>(
  //           enableDrag: true,
  //           isScrollControlled: true,
  //           context: context,
  //           builder: (BuildContext context) {
  //             return randerXD(songPath);
  //           },
  //         );
  //       },
  //       child: Column(
  //         children: [
  //           GetX<MusicController>(
  //             builder: (_) => Slider(
  //               value: position.value.inSeconds.toDouble(),
  //               max: duration.value.inSeconds.toDouble(),
  //               min: 0.0,
  //               divisions: 100,
  //               // label: slider.round().toString(),
  //               onChanged: (double value) {
  //                 final position = Duration(seconds: value.toInt());
  //                 player.seek(position);
  //                 player.play();
  //               },
  //             ),
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Obx(() => Text(formatTime(position.value.inSeconds))),
  //               Obx(() => Text("=>${formatTime(duration.value.inSeconds)}")),
  //             ],
  //           ),
  //           GetX<MusicController>(
  //             builder: (_) => Text(
  //               "${songName}",
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               IconButton(
  //                 onPressed: () async {
  //                   markindex = nextsong;
  //                   songName.value = (storageList[nextsong].title).toString();
  //                   await superControl(id: 1);
  //                 },
  //                 icon: const Icon(Icons.skip_previous, size: 40),
  //               ),
  //               CircleAvatar(
  //                 backgroundColor: Colors.blue,
  //                 radius: 30,
  //                 child: Align(
  //                   alignment: Alignment.center,
  //                   child: IconButton(
  //                     onPressed: () async {
  //                       await superControl(id: 2);
  //                     },
  //                     icon: isplaypause == false
  //                         ? const Icon(Icons.play_arrow, size: 40)
  //                         : const Icon(Icons.pause, size: 40),
  //                   ),
  //                 ),
  //               ),
  //               IconButton(
  //                 onPressed: () async {
  //                   songName.value = (storageList[nextsong].title).toString();
  //                   markindex = nextsong;
  //                   await superControl(id: 3);
  //                 },
  //                 icon: const Icon(
  //                   Icons.skip_next,
  //                   size: 40,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // randerXDs(songpath) {
  //   return XDplayer_screen(
  //     BackBtn: (context) =>
  //         backBtn(id: 1, icon: const Icon(Icons.keyboard_arrow_down)),
  //     BackwardBtn: (context) =>
  //         backBtn(id: 1, icon: const Icon(Icons.skip_previous)),
  //     FavoritBtn: (context) => backBtn(id: 1, icon: const Icon(Icons.favorite)),
  //     Loop: (context) => backBtn(id: 1, icon: const Icon(Icons.loop)),
  //     MoreBtn: (context) => backBtn(id: 1, icon: const Icon(Icons.list)),
  //     MoreBtnRight: (context) =>
  //         backBtn(id: 1, icon: const Icon(Icons.more_vert)),
  //     Next: (context) => backBtn(id: 3, icon: const Icon(Icons.skip_next)),
  //     PlayPause: (context) =>
  //         backBtn(id: 2, icon: const Icon(Icons.play_arrow)),
  //     Shuffle: (context) => backBtn(id: 1, icon: const Icon(Icons.shuffle)),
  //     SongImage: (context) => Text("data"),
  //     SongList: (context) => backBtn(id: 1, icon: const Icon(Icons.list_alt)),
  //     SongTitle: (context) => Text("data"),
  //     Track: (context) => randerSlider(),
  //     Volume: (context) =>
  //         backBtn(id: 1, icon: const Icon(Icons.volume_down_alt)),
  //     startTrack: '00:00',
  //     totalTrack: '00:00',
  //   );
  // }

  onPopBottomSheet() {
    return IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Icon(Icons.keyboard_arrow_down));
  }

  randerSlider() {
    return GetX<MusicController>(
      builder: (_) => Slider(
        value: position.value.inSeconds.toDouble(),
        max: duration.value.inSeconds.toDouble(),
        min: 0.0,
        divisions: 100,
        // label: slider.round().toString(),
        onChanged: (double value) {
          final position = Duration(seconds: value.toInt());
          player.seek(position);
          player.play();
        },
      ),
    );
  }

  backBtn({id, icon}) {
    return IconButton(
        onPressed: () {
          superControl(id: id);
        },
        icon: icon);
  }

  showDrag(context) {
    showModalBottomSheet<void>(
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.amber,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal BottomSheet'),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showDrags(context) {
    return ElevatedButton(
      child: const Text('showModalBottomSheet'),
      onPressed: () {
        showModalBottomSheet<void>(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.amber,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Modal BottomSheet'),
                    ElevatedButton(
                      child: const Text('Close BottomSheet'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String formatTime(int sec) {
    return '${(Duration(seconds: sec))}'.split('.')[0].padLeft(8, '0');
  }

  requestStorage() async {
    print("requestStorage");
    bool permissionStatus = await audioQuery.value.permissionsStatus();
    if (!permissionStatus) {
      await audioQuery.value.permissionsRequest();
    }
    update();
  }
}

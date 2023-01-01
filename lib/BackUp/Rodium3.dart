import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Rodium extends StatelessWidget {
  final mc = Get.put(MusicController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GetX Music',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 9,
            child: FutureBuilder<List<SongModel>>(
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
                return GetBuilder<MusicController>(
                  builder: (_dx) => Container(
                    height: Get.height,
                    child: ListView.builder(
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        mc.firstSong.value = item.data![0].uri!;
                        return Container(
                          color: mc.markindex == index
                              ? Colors.lightBlueAccent
                              : Colors.white,
                          child: ListTile(
                            title: Text(
                              item.data![index].title,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                        item.data![index].artist ?? "No Artist",
                                        style: TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis)),
                                //Flexible(flex:1,child: Obx(()=> Text("${mc.duration.value}" ,style: TextStyle(color: Colors.red),overflow: TextOverflow.ellipsis))),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) {
                                return {'Logout', 'Settings'}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                            onTap: () async {
                              //
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
                  ),
                );
              },
            ),
          ),
          Spacer(),
          mc.renderBtnControl(context, mc.songPath),

        ],
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
  int? markindex;
  var firstSong = ''.obs;
  List<SongModel> storageList = [];
  var nextsong = 0;
  Color SuperColor = Colors.grey;
  var isWhilePlay = false;
  var isShuffle = false.obs;
  var isLoop = false.obs;
  var whenEnd;
  var atLoopIndex = 0.obs;

  renderBtnControl(context, songPath) {
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
                                          update();
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
                                      markindex = nextsong;
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
                                      markindex = nextsong;
                                      songImage.value =
                                          storageList[nextsong].id;

                                      songName.value =
                                          (storageList[nextsong].title)
                                              .toString();
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    markindex = nextsong;
                                    songName.value =
                                        (storageList[nextsong].title)
                                            .toString();
                                    await superControl(id: 1);
                                  },
                                  icon:
                                      const Icon(Icons.skip_previous, size: 40),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    onPressed: () async {
                                      await superControl(id: 2);
                                    },
                                    icon: isplaypause == false
                                        ? const Icon(Icons.play_arrow, size: 40)
                                        : const Icon(Icons.pause, size: 40),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    songName.value =
                                        (storageList[nextsong].title)
                                            .toString();
                                    markindex = nextsong;
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
            ));
  }

  superControl({id, songPath, index}) async {
    int lengthCatch = storageList.length;
    if (id == 1) {
      nextsong--;
      if (nextsong == -1) {
        atLoopIndex.value = nextsong;
        isplaypause.value = true;
        nextsong = lengthCatch - 1;
        markindex = nextsong;
        songImage.value = storageList[nextsong].id;
        songName.value = (storageList[nextsong].title).toString();
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        await player.play();
      } else {
        atLoopIndex.value = nextsong;
        markindex = nextsong;
        isplaypause.value = true;
        songImage.value = storageList[nextsong].id;
        update();
        songName.value = (storageList[nextsong].title).toString();
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        await player.play();
      }
      update();
    } else if (id == 2) {
      if (isplaypause.value == true) {
        isplaypause.value = false;
        songImage.value = storageList[nextsong].id;
        player.pause();
        update();
      } else if (isplaypause.value == false) {
        isplaypause.value = true;
        songImage.value = storageList[nextsong].id;
        update();
        songName.value = storageList[nextsong].title.toString();
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        await player.play();
        update();
      }
      update();
    } else if (id == 3) {
      nextsong++;
      if (nextsong == lengthCatch) {
        nextsong = 0;
        isplaypause.value = true;
        atLoopIndex.value = nextsong;
        markindex = nextsong;
        songImage.value = storageList[nextsong].id;
        songName.value = storageList[nextsong].title;
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        await player.play();
        update();
      } else {
        atLoopIndex.value = nextsong;

        isplaypause.value = true;
        markindex = nextsong;
        songImage.value = storageList[nextsong].id;
        update();
        songName.value = storageList[nextsong].title;
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        await player.play();
      }
      update();
    } else if (id == 4) {
      print(markindex);
      atLoopIndex.value = nextsong;
      markindex = nextsong;
      isplaypause.value = true;
      update();
      songName.value = storageList[nextsong].title.toString();
      await player.setAudioSource(AudioSource.uri(Uri.parse(songPath)));
      await player.play();
      update();
    } else if (id == 5) {
      // loop
      isShuffle.value = false;
      isLoop.value = true;
      if (isLoop.value == true) {
        atLoopIndex.value = nextsong;
      }
      update();
    } else if (id == 6) {
      isShuffle.value = true;
      isLoop.value = false;
      update();
    }
  }

  onLoopSong() async {
    isplaypause.value = true;
    markindex = atLoopIndex.value;
    songImage.value = storageList[atLoopIndex.value].id;
    update();
    songName.value = storageList[atLoopIndex.value].title;
    await player.setAudioSource(AudioSource.uri(
        Uri.parse((storageList[atLoopIndex.value].uri).toString())));
    await player.play();
  }

  @override
  void onInit() async {
    print("screens builded");
    await requestStorage();
    player.durationStream.listen((event) {
      isPlaying = event == player.playing;
      whenEnd = event;
    });
    player.positionStream.listen((event) {
      isPlaying = event == player.playing;
      if (event == whenEnd) {
        if (isShuffle == true) {
          superControl(id: 3);
          update();
        } else if (isShuffle == false) {
          onLoopSong();
          update();
        }
        update();
      } else {}
      print(event);
    });
    player.durationStream.listen((eventdur) {
      duration.value = eventdur!;
    });
    player.positionStream.listen((event) {
      position.value = event;
    });

    update();
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

class ObjectSong {}

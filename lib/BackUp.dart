import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicApp extends StatefulWidget {
  const MusicApp({Key? key}) : super(key: key);

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  bool play = false;
  Duration dur = Duration.zero;
  Duration pos = Duration.zero;

  players() async {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    requestStorage();
    super.initState();
  }

  final OnAudioQuery _audioQuery = OnAudioQuery();

  requestStorage() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }

    setState(() {});
  }

  String songName = 'title';

  // https://youtu.be/FUgFq4eDfQw?list=RDFUgFq4eDfQw
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // saveList(),
          Flexible(
            child: FutureBuilder<List<SongModel>>(
              future: _audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, item) {
                if (item.data == null) return const CircularProgressIndicator();
                if (item.data!.isEmpty) return const Text("Nothing found!");
                storageList = item.data!;
                return ListView.builder(
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) {
                    firstSong = item.data![0].uri;
                    getSong = item.data!;
                    return ListTile(
                      title: Text(item.data![index].title),
                      subtitle: Text(item.data![index].artist ?? "No Artist"),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) {
                          return {'Logout', 'Settings'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                      onTap: () async {
                        superControl(id: 4, songPath: item.data![index].uri);
                        nextsong = index;
                      },
                      leading: QueryArtworkWidget(
                        id: item.data![index].id,
                        type: ArtworkType.AUDIO,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Slider(
                  value: position.inMilliseconds.toDouble(),
                  max: duration.inMilliseconds.toDouble(),
                  thumbColor: Colors.orange,
                  inactiveColor: Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      value = value;
                    });
                    player.seek(position);
                  },
                ),
                Text('$duration'),
                Text("=>$songName"),
                StreamBuilder(

                    stream: player.currentIndexStream,
                    builder: (context, asyncSnapshot) {
                      final Duration duration = player.position;
                      return Text(duration.toString());
                    }),
                Text("=>$playTime"),
                Row(
                  children: [
                    Flexible(child: Text("=>$songName")),
                    IconButton(
                      onPressed: () async {
                        await superControl(id: 1);
                      },
                      icon: Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: () async {
                        await superControl(id: 2);
                        isplaypause = true;
                      },
                      icon: isplaypause == false
                          ? Icon(Icons.pause)
                          : Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () async {
                        await superControl(id: 3);
                      },
                      icon: Icon(Icons.skip_next),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool isplaypause = false;

  var playTime;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  var getSong;
  var song;
  AudioPlayer player = AudioPlayer();
  List markindex = [];

  var firstSong;
  List<ModelSong> recentList = [];

  initSong() {}

  List<SongModel> storageList = [];
  int addIndex = 0;

  int nextsong = 0;

  superControl({id, songPath}) async {
    if (id == 1) {
      nextsong--;
      await player.setAudioSource(
          AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
      await player.play();
    } else if (id == 2) {

      if (player.playing) {
        player.pause();
        isplaypause = false;
      } else {
        isplaypause = true;
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        await player.play();
      }
    } else if (id == 3) {
      nextsong++;
      await player.setAudioSource(
          AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
      await player.play();


    } else if (id == 4) {
      await player.setAudioSource(AudioSource.uri(Uri.parse(songPath)));
      await player.positionStream.listen((event) {
        playTime = event;
      });
      await player.play();
    }
    setState(() {});
  }

  var timer;

  saveList() {
    return FutureBuilder<List<SongModel>>(
      builder: (context, item) {
        return Flexible(
          child: ListView.builder(
            itemCount: recentList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("${recentList}"),
                subtitle: Text("item.data![index].artist ?? "),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) {
                    return {'Logout', 'Settings'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
                onTap: () async {
                  setState(() {
                    songName = item.data![index].title;
                    song = (item.data![index].uri);
                  });
                },
                // leading: QueryArtworkWidget(
                //   id: item.data![index].id,
                //   type: ArtworkType.AUDIO,
                // ),
              );
            },
          ),
        );
      },
    );
  }
}

class ModelSong {
  String title = '';
  String image = '';
  String artise = '';
}

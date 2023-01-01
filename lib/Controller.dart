import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControllerOperation {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();

  String songtitle = 'title';

  List<SongModel> glbStoreSong = [];

  startPlay({path, title}) async {
    await _player.setAudioSource(AudioSource.uri(Uri.parse(path.toString())));
    await _player.play();
    songtitle = title;
    print(path);
  }

  List<SongModel> playerList = [];
  final prefs = SharedPreferences.getInstance();

  nextTrack() {}

  pause() async {
    await _player.stop();
  }

  previousTrack() {}

  onItemTapped(int index) {
    if (index == 3) {
      pause();
    }
  }

  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    ));
  }

  void requestStoragePermission({var musicPath}) async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }
  }

  int addIndex = 0;
  double value = 0.0;

  int nextsong = 0;
  List<SongModel> storageList = [];
  AudioPlayer player = AudioPlayer();
  bool isplaypause = false;
  var playTime;

  superControl({id, songPath}) async {
    if (id == 1) {
      nextsong--;
      await player.setAudioSource(
          AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
      songtitle = storageList[nextsong].title.toString();
      await player.play();
    } else if (id == 2) {
      if (player.playing) {
        player.pause();
        isplaypause = false;
      } else {
        isplaypause = true;
        await player.setAudioSource(
            AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
        songtitle = storageList[nextsong].title.toString();

        await player.play();
      }
    } else if (id == 3) {
      nextsong++;
      await player.setAudioSource(
          AudioSource.uri(Uri.parse((storageList[nextsong].uri).toString())));
      songtitle = await storageList[nextsong].title.toString();

      await player.play();
    } else if (id == 4) {
      await player.setAudioSource(AudioSource.uri(Uri.parse(songPath)));
      await player.positionStream.listen((event) {
        playTime = event;
      });

      await player.play();
      songtitle = storageList[nextsong].title.toString();
    }
  }

  changed(s) {
    changed(s);
  }
}

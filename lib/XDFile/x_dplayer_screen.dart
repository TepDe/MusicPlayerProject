import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class XDplayer_screen extends StatelessWidget {
  final WidgetBuilder SongImage;
  final WidgetBuilder PlayPause;
  final WidgetBuilder Track;
  final WidgetBuilder Next;
  final WidgetBuilder Shuffle;
  final WidgetBuilder FavoritBtn;
  final WidgetBuilder SongTitle;
  final WidgetBuilder MoreBtn;
  final WidgetBuilder SongList;
  final WidgetBuilder BackwardBtn;
  final WidgetBuilder Loop;
  final WidgetBuilder Volume;
  final WidgetBuilder MoreBtnRight;
  final WidgetBuilder BackBtn;
  final String startTrack;
  final String totalTrack;
  XDplayer_screen({
    Key? key,
    required this.SongImage,
    required this.PlayPause,
    required this.Track,
    required this.Next,
    required this.Shuffle,
    required this.FavoritBtn,
    required this.SongTitle,
    required this.MoreBtn,
    required this.SongList,
    required this.BackwardBtn,
    required this.Loop,
    required this.Volume,
    required this.MoreBtnRight,
    required this.BackBtn,
    this.startTrack = '00:00',
    this.totalTrack = '00:00',
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0.0, -0.176),
            child: SizedBox(
              width: 250.0,
              height: 250.0,
              child: Stack(
                children: <Widget>[
                  SongImage(context),
                ],
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 80.0, middle: 0.5),
            Pin(size: 80.0, end: 99.0),
            child: Stack(
              children: <Widget>[
                PlayPause(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(start: 30.0, end: 30.0),
            Pin(size: 10.0, middle: 0.7581),
            child: Stack(
              children: <Widget>[
                Track(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 80.0, end: 30.0),
            Pin(size: 80.0, end: 99.0),
            child: Stack(
              children: <Widget>[
                Next(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 80.0, end: 30.0),
            Pin(size: 39.0, end: 40.0),
            child: Stack(
              children: <Widget>[
                Shuffle(context),
              ],
            ),
          ),
          Align(
            alignment: Alignment(0.003, 0.456),
            child: SizedBox(
              width: 39.0,
              height: 39.0,
              child: Stack(
                children: <Widget>[
                  FavoritBtn(context),
                ],
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 46.0, end: 46.0),
            Pin(size: 30.0, middle: 0.6086),
            child: Stack(
              children: <Widget>[
                SongTitle(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 39.0, end: 30.0),
            Pin(size: 39.0, middle: 0.7279),
            child: Stack(
              children: <Widget>[
                MoreBtn(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 39.0, start: 30.0),
            Pin(size: 39.0, middle: 0.7279),
            child:
                // Adobe XD layer: 'list' (group)
                Stack(
              children: <Widget>[
                SongList(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 80.0, start: 30.0),
            Pin(size: 80.0, end: 99.0),
            child:
                // Adobe XD layer: 'back' (group)
                Stack(
              children: <Widget>[
                BackwardBtn(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 80.0, start: 30.0),
            Pin(size: 39.0, end: 40.0),
            child:
                // Adobe XD layer: 'loop' (group)
                Stack(
              children: <Widget>[
                Loop(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 190.0, middle: 0.5),
            Pin(size: 39.0, end: 40.0),
            child:
                // Adobe XD layer: 'volumn' (group)
                Stack(
              children: <Widget>[
                Volume(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 46.0, end: 20.0),
            Pin(size: 46.0, start: 30.0),
            child:
                // Adobe XD layer: 'more' (group)
                Stack(
              children: <Widget>[
                MoreBtnRight(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 46.0, start: 20.0),
            Pin(size: 46.0, start: 30.0),
            child: Stack(
              children: <Widget>[
                BackBtn(context),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 47.0, start: 30.0),
            Pin(size: 27.0, middle: 0.789),
            child: Text(
              startTrack,
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 20,
                color: const Color(0xff707070),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 47.0, end: 30.0),
            Pin(size: 27.0, middle: 0.789),
            child: Text(
              totalTrack,
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 20,
                color: const Color(0xff707070),
              ),
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'XDFile/x_dplayer_screen.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return XDplayer_screen(
      BackBtn: (context) => backBtn() ,
      BackwardBtn:(context) => backBtn() ,
      FavoritBtn:(context) => backBtn() ,
      Loop: (context) => backBtn(),
      MoreBtn: (context) => backBtn(),
      MoreBtnRight:(context) => backBtn() ,
      Next: (context) => backBtn(),
      PlayPause:(context) => backBtn() ,
      Shuffle:(context) => backBtn() ,
      SongImage:(context) => backBtn() ,
      SongList: (context) => backBtn(),
      SongTitle: (context) => backBtn(),
      Track: (context) => backBtn(),
      Volume: (context) => backBtn(),

      startTrack:'(context) => backBtn()' ,
      totalTrack:'(context) => backBtn()' ,

    );
  }

  backBtn() {
    return IconButton(onPressed: () {}, icon: Icon(Icons.abc));
  }
}

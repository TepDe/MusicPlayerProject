import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'Controller.dart';
import 'WidgetRander.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    op.requestStoragePermission();
  }

  ControllerOperation op = ControllerOperation();
  var colorBlack = const Color.fromRGBO(0, 0, 0, 0);
  WidgetRender widgetRender = WidgetRender();
  var songtitle = 'title';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: InkWell(
            onTap: () {
              setState(() {
                op.requestStoragePermission();
              });
            },
            child: Icon(Icons.refresh)),
        title: const Text("Rhodium"),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widgetRender.playerList(context),
              widgetRender.playerList(context),
              widgetRender.playerList(context),
            ],
          ),
          Flexible(
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
                op.storageList = item.data!;

                return ListView.builder(
                    itemCount: item.data!.length,
                    itemBuilder: (context, index) {
                      op.glbStoreSong.add(item.data![index]);
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
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) {
                              return {'Add To Play List'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                          leading: QueryArtworkWidget(
                            id: item.data![index].id,
                            type: ArtworkType.AUDIO,
                          ),
                          onTap: () async {
                            //toast message showing he selected song title
                            // op.toast(context,
                            //     "You Selected:   " + item.data![index].title);
                            // await op.startPlay(
                            //     path: item.data![index].uri,
                            //     title: item.data![index].title.toString());
                            // op.songtitle = (item.data![index].title).toString();
                            // songtitle = item.data![index].title;
                            setState(() {
                              op.superControl(
                                  id: 4, songPath: item.data![index].uri);
                              op.nextsong = index;
                              songtitle = (op.storageList[op.nextsong].title)
                                  .toString();
                              //songtitle ='fjbsdgbugudgdb';
                            });
                          },
                        ),
                      );
                    });
              },
            ),
          ),
          Container(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Slider.adaptive(
                    thumbColor: Colors.orange,
                    value: op.value,
                    activeColor: Colors.grey,
                    inactiveColor: Colors.grey,
                    onChanged: (double s) => {
                      op.changed(s),
                      setState(() {
                        op.value = s;
                      })
                    },
                    divisions: 10,
                    min: 0.0,
                    max: 10.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          songtitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black),
                        ),
                        flex: 1,
                      ),
                      Flexible(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () async {
                                    await op.superControl(id: 1);
                                  },
                                  icon: Icon(
                                    Icons.skip_previous,
                                    size: 40,
                                  )),
                            ),
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () async {
                                    await op.superControl(id: 2);
                                    op.songtitle = op
                                        .storageList[op.nextsong].title
                                        .toString();
                                  },
                                  icon: Icon(Icons.pause, size: 40)),
                            ),
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () async {
                                    await op.superControl(id: 3);
                                    op.songtitle = op
                                        .storageList[op.nextsong].title
                                        .toString();
                                  },
                                  icon: Icon(Icons.skip_next, size: 40)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

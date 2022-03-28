import 'dart:ui';

import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/playback_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:provider/provider.dart';

class CameraRoll extends StatefulObserverWidget {
  final Function(DateTime) onTimeSelected;
  final Function(int) onSeek;

  const CameraRoll({
    Key key,
    @required this.onTimeSelected,
    @required this.onSeek,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CameraRollState();
  }
}

class CameraRollState extends State<CameraRoll> {
  final IndexedScrollController scrollController = IndexedScrollController();

  RollCameraStore _rollCameraStore;

  double lastOffset = 0;
  bool isPosFixed = false;
  String value;
  DateTime now;
  DateTime start;
  bool isSeekToCurrent = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _rollCameraStore = Provider.of(context);
    start = DateTime(
        _rollCameraStore.timeSelected.year,
        _rollCameraStore.timeSelected.month,
        _rollCameraStore.timeSelected.day,
        0);
    now = _rollCameraStore.timeSelected;
    int curIndex = (now.difference(start).inMinutes / 6).floor() -
        (MediaQuery.of(context).size.width / 20).floor();
    scrollController.jumpToIndex(curIndex);
  }

  @override
  Widget build(BuildContext context) {
    List<int> listIndex = [];
    for (final event in _rollCameraStore.events) {
      int startIndex = _getIndexFromTime(event.startTime);
      int endIndex = _getIndexFromTime(event.endTime);
      listIndex.addAll([for (var i = startIndex; i <= endIndex; i++) i]);
    }
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: _isPortrait()
          ? null
          : BoxDecoration(
              color: const Color.fromARGB(150, 42, 43, 49),
            ),
      child: Wrap(
        children: [
          PlaybackTime(start: _rollCameraStore.timeSelected),
          const SizedBox(height: 15),
          Container(
            height: 75,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: GestureDetector(
                    child: NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          DateTime timeSelected = now.add(Duration(
                              minutes: ((scrollController.offset / 10) * 6)
                                  .floor()));
                          widget.onTimeSelected(timeSelected);
                        }
                        return true;
                      },
                      child: IndexedListView.builder(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            alignment: Alignment.bottomCenter,
                            width: 10,
                            child: Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  width: 10,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  color: listIndex.contains(index)
                                      ? Color.fromARGB(255, 0, 67, 119)
                                      : _isPortrait()
                                          ? Color.fromARGB(255, 42, 43, 49)
                                          : null,
                                  child: Container(
                                    width: index % 10 == 0 ? 1 : 0.5,
                                    height: _getHeight(index),
                                    color: Colors.white,
                                  ),
                                ),
                                if (index % 10 == 0)
                                  Positioned(
                                    bottom: 0,
                                    width: 50,
                                    left: -23,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${((index / 10) % 24).floor()}:00",
                                        // "$index",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 7,
                  child:
                      IconAssets(width: 14, name: "maker", color: Colors.blue),
                ),
                Container(
                  height: 54,
                  child: Row(
                    children: [
                      IconButton(
                        icon: IconAssets(width: 22, name: "10s_pre"),
                        onPressed: () {
                          widget.onSeek(-10);
                        },
                      ),
                      Spacer(),
                      IconButton(
                        icon: IconAssets(width: 22, name: "10s_next"),
                        onPressed: () {
                          widget.onSeek(10);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  double _getHeight(int index) {
    if (index % 10 == 0) return 43;
    if (index % 5 == 0) return 30;
    return 12;
  }

  fixPosition(double curPos) {
    print('curPos: $curPos');
    double targetPos = double.parse(curPos.toStringAsFixed(0));
    print('targetPos: $targetPos');
    if (targetPos < 0) targetPos = 0;
    scrollController.jumpTo(targetPos);
  }

  setPositionByValue(num value) {
    num targetPos = value * 10;
    if (targetPos < 0) targetPos = 0;
    scrollController.jumpTo(targetPos.toDouble());
  }

  int _getIndexFromTime(String time) {
    return (DateTime.parse(time).difference(start).inMinutes / 6).floor();
  }

  bool _isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}

import 'dart:async';

import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PlaybackTime extends StatefulWidget {
  final DateTime start;

  PlaybackTime({Key key, this.start}) : super(key: key);

  @override
  _PlaybackTimeState createState() => _PlaybackTimeState();
}

class _PlaybackTimeState extends State<PlaybackTime> {
  final DateFormat _dateFormat = DateFormat("dd/MM/yyyy");
  final DateFormat _timeFormat = DateFormat("HH:mm:ss");

  Timer _timer;
  DateTime time;

  RollCameraStore _rollCameraStore;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        try {
          if (_rollCameraStore?.controller != null) {
            time = widget.start.add(_rollCameraStore.controller.value.position);
          }
        } catch (e) {
          print(e);
        }
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rollCameraStore = Provider.of(context);
    time = _rollCameraStore.timeSelected;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rollCameraStore.camera == null) return Row();
    return Row(
      children: [
        Expanded(
          child: Text(
            _timeFormat.format(time),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: _isPortrait() ? Colors.blue : Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "-",
          style: TextStyle(
            color: _isPortrait() ? Colors.blue : Colors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _dateFormat.format(time),
            style: TextStyle(
              color: _isPortrait() ? Colors.blue : Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  bool _isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}

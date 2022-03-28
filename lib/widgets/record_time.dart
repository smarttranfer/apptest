import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordTime extends StatefulWidget {
  final DateTime start;

  const RecordTime({Key key, @required this.start}) : super(key: key);

  @override
  _RecordTimeState createState() => _RecordTimeState();
}

class _RecordTimeState extends State<RecordTime> {
  DateFormat _dateFormat = DateFormat('HH:mm:ss');
  int second = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      setState(() {
        second = now.difference(widget.start).inSeconds;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: const Color.fromARGB(100, 44, 52, 62),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            size: 12,
            color: Colors.red,
          ),
          const SizedBox(width: 3),
          Text(
              _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                  second * 1000,
                  isUtc: true)),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

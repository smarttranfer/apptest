import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoDuration extends StatelessWidget {
  final DateFormat _dateFormat = DateFormat('HH:mm:ss');
  final int duration;

  VideoDuration({Key key, this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: const Color.fromARGB(100, 44, 52, 62),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Icons.play_arrow_outlined,
            size: 16,
            color: Colors.white,
          ),
          Text(
              _dateFormat.format(
                  DateTime.fromMillisecondsSinceEpoch(duration, isUtc: true)),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

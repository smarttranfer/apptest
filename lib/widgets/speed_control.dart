import 'package:flutter/material.dart';

import 'circle_button.dart';

class SpeedControl extends StatefulWidget {
  final double initSpeed;
  final Function(double) onSpeedChange;

  SpeedControl({
    Key key,
    this.initSpeed = 1,
    @required this.onSpeedChange,
  }) : super(key: key);

  @override
  _SpeedControlState createState() => _SpeedControlState();
}

class _SpeedControlState extends State<SpeedControl> {
  Speed speed;
  List<Speed> speeds = [
    Speed("1/4x", 1 / 4),
    Speed("1/2x", 1 / 2),
    Speed("1x", 1),
    Speed("2x", 2),
    Speed("4x", 4),
  ];

  @override
  void initState() {
    speed = speeds.firstWhere((e) => e.value == widget.initSpeed,
        orElse: () => speeds[2]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: const Color.fromARGB(200, 44, 52, 62),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleButton(
                text: "-",
                onTap: () {
                  int curIndex = speeds.indexOf(speed);
                  if (curIndex - 1 < 0) return;
                  setState(() {
                    speed = speeds[curIndex - 1];
                    widget.onSpeedChange(speed.value);
                  });
                },
              ),
            ),
            SizedBox(
              child: Text(
                speed.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              width: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleButton(
                text: "+",
                onTap: () {
                  int curIndex = speeds.indexOf(speed);
                  if (curIndex + 1 >= speeds.length) return;
                  setState(() {
                    speed = speeds[curIndex + 1];
                    widget.onSpeedChange(speed.value);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Speed {
  final String name;
  final double value;

  Speed(this.name, this.value);
}

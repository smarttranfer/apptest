import 'dart:async';
import 'dart:ui';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/video_photo/video_photo_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/circle_button.dart';
import 'package:boilerplate/widgets/dropdown_menu.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/main_control_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:save_in_gallery/save_in_gallery.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class VideoDetail extends StatefulWidget {
  VideoDetail({Key key}) : super(key: key);

  @override
  _VideoDetailState createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> {
  VideoPhotoStore _videoPhotoStore;
  String path = "";
  VlcPlayerController _controller;
  // final ImageSaver _imageSaver = ImageSaver();
  String playBackLabel = "1x";
  double positionSeek = 0;
  double playBackValue = 1.0;
  Timer _timer;
  bool isShowPlayBack = false;
  bool started = false;

  List<PlayBack> listPlayBack = [
    PlayBack(label: "1/16x", value: 0.0625),
    PlayBack(label: "1/8x", value: 0.125),
    PlayBack(label: "1/4x", value: 0.25),
    PlayBack(label: "1/2x", value: 0.5),
    PlayBack(label: "1x", value: 1),
    PlayBack(label: "2x", value: 2),
    PlayBack(label: "4x", value: 4),
    PlayBack(label: "8x", value: 8),
    PlayBack(label: "16x", value: 16),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoPhotoStore = Provider.of(context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isPortrait()
          ? AppBar(
              title: Text(
                Translate.getString("video_photo.video_detail", context),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              actions: [_buildMenuGroup()],
            )
          : null,
      body: FutureBuilder(
        future: _videoPhotoStore.medium.getFile(),
        builder: (context, snapshot) {
          path = snapshot.data?.path;
          if (_controller == null && snapshot.data != null) {
            _controller = VlcPlayerController.file(
              snapshot.data,
              hwAcc: HwAcc.FULL,
            );
            _controller.addListener(() async {
              if (await _controller.isPlaying() && !started) {
                started = true;
                startTimer();
              }
            });
          }
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (isShowPlayBack) {
                isShowPlayBack = false;
                _startVideo();
              }
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isPortrait()) const SizedBox(height: 80),
                    if (_isPortrait())
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          snapshot.data?.uri?.pathSegments?.last ?? "",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (_isPortrait()) SizedBox(height: 10),
                    if (snapshot.data != null)
                      _isPortrait()
                          ? Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    VlcPlayer(
                                      aspectRatio: 16 / 9,
                                      controller: _controller,
                                    ),
                                    Visibility(
                                      visible: isShowPlayBack,
                                      child: Positioned(
                                        bottom: 20,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Container(
                                            color:
                                                Color.fromARGB(200, 44, 52, 62),
                                            child: ButtonBar(
                                              children: <Widget>[
                                                CircleButton(
                                                  text: "-",
                                                  onTap: () {
                                                    if (listPlayBack.indexWhere(
                                                            (element) =>
                                                                element.label ==
                                                                playBackLabel) ==
                                                        0) return;
                                                    _onControlPlayBack(
                                                        'decrease');
                                                  },
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  playBackLabel,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(width: 10),
                                                CircleButton(
                                                  text: "+",
                                                  onTap: () {
                                                    if (listPlayBack.indexWhere(
                                                            (element) =>
                                                                element.label ==
                                                                playBackLabel) ==
                                                        8) return;
                                                    _onControlPlayBack(
                                                        'increase');
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                _buildVideoControlBar()
                              ],
                            )
                          : Theme(
                              data: ThemeData.light(),
                              child: VlcPlayer(
                                controller: _controller,
                                aspectRatio: 4 / 3,
                              ),
                            ),
                  ],
                ),
                if (!_isPortrait()) ...[
                  Container(
                    color: const Color.fromARGB(150, 42, 43, 49),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        snapshot.data?.uri?.pathSegments?.last ?? "",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.topRight, child: _buildMenuGroup()),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      color: const Color.fromARGB(150, 42, 43, 49),
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: _buildVideoControlBar(),
                    ),
                  ),
                ],
                if (_isPortrait())
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: MainControlButton(
                      icon: "screenshot",
                      iconColor: Colors.black,
                      height: 30,
                      width: 25,
                      maxRadius: 30,
                      onPressed: () async {
                        await takeScreenShot(context);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future takeScreenShot(BuildContext context) async {
    final uint8list = await _controller.takeSnapshot();
    String name = "${DateFormat("yyyyMMdd-HHmmSS").format(DateTime.now())}";
    // final success = await _imageSaver.saveImage(
    //   imageName: name,
    //   directoryName: Strings.appName,
    //   imageBytes: uint8list,
    // );
    // Toast.show(
    //   Translate.getString(
    //       "video_photo.${success ? "save_success" : "save_fail"}", context),
    //   context,
    //   duration: Toast.LENGTH_SHORT,
    //   gravity: Toast.BOTTOM,
    // );
    _videoPhotoStore.findAll();
  }

  Widget _buildMenuGroup() {
    return DropdownMenu(
        onChange: _onPopupMenuSelected,
        child: const Icon(Icons.more_vert, color: Colors.white),
        items: [
          _buildMenuItem("share", Icons.share, Colors.white,
              Translate.getString("video_photo.share", context)),
          _buildMenuItem("delete", Icons.delete, Colors.red,
              Translate.getString("video_photo.delete", context)),
        ]);
  }

  Widget _buildMenuItem(
      String value, IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: Colors.white))
      ],
    );
  }

  _onPopupMenuSelected(int index) {
    if (index == 0) {
      Share.shareFiles([path],
          text: Translate.getString("video_photo.share", context));
    } else {
      _onDelete();
    }
  }

  _onDelete() {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: CupertinoAlertDialog(
                    title: Text(Translate.getString(
                        "video_photo.delete_video", context)),
                    content: Text(Translate.getString(
                        "video_photo.delete_video_confirm", context)),
                    actions: [
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("video_photo.yes", context),
                              style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            await _videoPhotoStore.deleteMedium();
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.videoAndPhoto,
                                (Route<dynamic> route) => false);
                          }),
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("video_photo.no", context),
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () => Navigator.pop(context)),
                    ]),
              ),
            ));
  }

  bool _isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  void startTimer() {
    int duration = _controller.value.duration.inHours * 3600 +
        _controller.value.duration.inMinutes * 60 +
        _controller.value.duration.inSeconds;
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (positionSeek == duration.toDouble())
          _stopVideo();
        else {
          positionSeek = positionSeek + (1 * playBackValue);
          if (positionSeek > duration.toDouble())
            positionSeek = duration.toDouble();
          setState(() {});
        }
      },
    );
  }

  Widget _buildVideoControlBar() {
    int duration = _controller.value.duration.inHours * 3600 +
        _controller.value.duration.inMinutes * 60 +
        _controller.value.duration.inSeconds;
    int timeRemaining = duration - positionSeek.toInt();
    return Column(
      children: [
        SizedBox(height: _isPortrait() ? 5 : 10),
        if (!_isPortrait())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  convertDurationToTimeString(
                      Duration(seconds: positionSeek.toInt())),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Spacer(),
                Text(
                  "-${convertDurationToTimeString(Duration(seconds: timeRemaining))}",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        FlutterSlider(
          handlerHeight: _isPortrait() ? 15 : 10,
          values: [positionSeek],
          max: duration.toDouble(),
          min: 0,
          onDragStarted: (handlerIndex, lowerValue, upperValue) {
            _stopVideo();
          },
          onDragCompleted: (handlerIndex, lowerValue, upperValue) {
            positionSeek = double.parse(lowerValue.toString());
            _controller.seekTo(Duration(seconds: positionSeek.toInt()));
            _startVideo();
          },
          tooltip: FlutterSliderTooltip(
            disabled: true,
          ),
          handler: FlutterSliderHandler(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: IconAssets(
              name: 'adjust',
              width: 10,
            ),
          ),
          trackBar: FlutterSliderTrackBar(
            inactiveTrackBar: BoxDecoration(
              color: AppColors.hintColor,
            ),
          ),
        ),
        if (_isPortrait())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  convertDurationToTimeString(
                      Duration(seconds: positionSeek.toInt())),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Spacer(),
                Text(
                  "-${convertDurationToTimeString(Duration(seconds: timeRemaining))}",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        if (_isPortrait()) const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: IconAssets(
                name: 'volume',
                color: Colors.white,
                width: 25,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.volume == 0
                      ? _controller.setVolume(1)
                      : _controller.setVolume(0);
                });
              },
            ),
            IconButton(
              icon: IconAssets(
                name: 'previous_video',
                color: Colors.white,
                width: 20,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: IconAssets(
                name: 'play',
                color: Colors.white,
                width: 15,
              ),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _stopVideo();
                  } else {
                    _startVideo();
                  }
                });
              },
            ),
            IconButton(
              icon: IconAssets(
                name: 'next_video',
                color: Colors.white,
                width: 20,
              ),
              onPressed: () {},
            ),
            if (!_isPortrait())
              IconButton(
                icon: IconAssets(
                  name: 'screenshot',
                  color: Colors.white,
                  width: 25,
                ),
                onPressed: () async {
                  await takeScreenShot(context);
                },
              ),
            GestureDetector(
              onTap: () {
                _setPlaySpeed();
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 50,
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.5)),
                  child: Center(
                    child: Text(
                      playBackLabel,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  _stopVideo() {
    setState(() {
      _controller.pause();
      _timer.cancel();
    });
  }

  _startVideo() {
    setState(() {
      _controller.play();
      startTimer();
    });
  }

  _setPlaySpeed() {
    isShowPlayBack = true;
    _stopVideo();
  }

  String convertDurationToTimeString(Duration duration) {
    String twoDigits(int n) => n >= 10 ? "$n" : "0$n";
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  _onControlPlayBack(String type) {
    int itemIndex =
        listPlayBack.indexWhere((element) => element.label == playBackLabel);
    if (type == "decrease")
      itemIndex--;
    else
      itemIndex++;
    setState(() {
      playBackLabel = listPlayBack[itemIndex].label;
      playBackValue = listPlayBack[itemIndex].value;
      _controller.setPlaybackSpeed(playBackValue);
    });
  }
}

class PlayBack {
  final String label;
  final double value;

  PlayBack({this.label, this.value});
}

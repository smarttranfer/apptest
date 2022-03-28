import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:provider/provider.dart';

class PlayBackCameraPlayer extends StatefulWidget {
  final Camera camera;
  final String url;
  final Duration start;
  final Function onComplete;

  PlayBackCameraPlayer({
    Key key,
    this.onComplete,
    @required this.camera,
    this.url,
    this.start,
  }) : super(key: key);

  @override
  _PlayBackCameraPlayerState createState() => _PlayBackCameraPlayerState();
}

class _PlayBackCameraPlayerState extends State<PlayBackCameraPlayer> {
  VlcPlayerController _controller;
  RollCameraStore _rollCameraStore;

  @override
  void initState() {
    print("play video ${widget.url}");
    if (widget.url != null) _initPlayer();
    // _controller.addListener(_listener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rollCameraStore = Provider.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) {
      _controller = null;
      return Center(
          child: Text(
        Translate.getString("playback.no_video", context),
        style: const TextStyle(color: Colors.white),
      ));
    }
    if (widget.url != null && _controller == null) _initPlayer();
    if (_controller != null && _controller.dataSource != widget.url) {
      _controller.setMediaFromNetwork(widget.url);
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: VlcPlayer(
        controller: _controller,
        aspectRatio: 1,
        placeholder:  Center(
          child:  SpinKitRotatingCircle(color: Colors.white, size: 40),
        ),
      ),
    );
  }

  _listener() async {
    if (!mounted) return;
    final curPosition = await _controller.getPosition();
    if (widget.start != null && curPosition.compareTo(widget.start) < 0) {
      _controller.seekTo(widget.start);
    }
    if (_controller.value.isEnded && widget.onComplete != null) {
      widget.onComplete();
      _controller.dispose();
    }
  }

  _initPlayer() {
    _controller = VlcPlayerController.network(widget.url);
    _rollCameraStore?.setController(_controller);
  }
}

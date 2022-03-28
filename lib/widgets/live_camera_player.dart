import 'dart:async';

import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/widgets/reload.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:provider/provider.dart';

class LiveCameraPlayer extends StatefulWidget {
  final Camera camera;

  LiveCameraPlayer({Key key, this.camera}) : super(key: key);

  @override
  _LiveCameraPlayerState createState() => _LiveCameraPlayerState();
}

class _LiveCameraPlayerState extends State<LiveCameraPlayer> {
  VlcPlayerController _controller;
  GatewayStore _gatewayStore;
  List<String> links;
  Gateway gateway;
  Timer _timer;
  bool isError = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _gatewayStore = Provider.of(context);
    gateway = await _gatewayStore.findById(widget.camera.gatewayId);
    _play();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isError)
      return Reload(onReload: () {
        setState(() {
          isError = false;
          _play();
        });
      });
    return _controller != null
        ? VlcPlayer(
            controller: _controller,
            aspectRatio: 1,
            placeholder:  Center(
              child: SpinKitCircle(color: Colors.white, size: 40),
            ),
          )
        :  Center(
            child: SpinKitCircle(color: Colors.white, size: 40),
          );
  }

  _play() {
    links = [...widget.camera.links];
    _controller?.dispose();
    _controller = null;
    widget.camera.controller = null;
    final url = _getPlayUrl();
    _controller = VlcPlayerController.network(
      url,
      options: VlcPlayerOptions(
        extras: [
          "--network-caching=100m",
          if (url.startsWith("rtsp")) "--rtsp-tcp",
        ],
      ),
    );
    print("play link: ${_controller.dataSource}");
    _controller.addListener(() {
      if (_controller.value.hasError) {
        _controller.setMediaFromNetwork(_getPlayUrl());
        print("has error. play link: ${_controller.dataSource}");
      }
    });
    widget.camera.controller = _controller;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 20), () async {
      if (!await _controller.isPlaying()) {
        setState(() {
          isError = true;
        });
      }
    });
  }

  String _getPlayUrl() {
    try {
      return links.removeAt(0).replaceAll("%s", "token=${gateway.token}");
    } catch (e) {
      return null;
    }
  }
}

import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/camera_preview/camera_preview_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class CameraPreview extends StatefulWidget {
  final Device device;

  CameraPreview({Key key, this.device}) : super(key: key);

  @override
  _CameraPreviewState createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  CameraPreviewStore _cameraPreviewStore;
  List<String> links = [];
  Gateway gateway;
  GatewayStore _gatewayStore;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _cameraPreviewStore = Provider.of(context);
    _gatewayStore = Provider.of(context);
    gateway = await _gatewayStore.findById(widget.device.gatewayId);
    links = widget.device.links.where((e) => e.contains("mode=snap")).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return Container();
    return Positioned(
      bottom: 90,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: IconAssets(name: "close", width: 25),
            onPressed: () {
              _cameraPreviewStore.setDevice(null);
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 120,
              width: 200,
              color: Color.fromARGB(255, 44, 52, 62),
              child: CachedNetworkImage(
                imageUrl: links
                    .removeAt(0)
                    .replaceAll("%s", "token=${gateway.token}"),
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SpinKitCircle(color: Colors.white, size: 30.0),
                ),
                httpHeaders: {"Authorization": "Bearer ${gateway.token}"},
                errorWidget: (context, url, error) => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    height: 75,
                    width: 75,
                    child: Image.asset(
                      "assets/images/no_image.png",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

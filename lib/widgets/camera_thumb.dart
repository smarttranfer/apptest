import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class CameraThumb extends StatelessWidget {
  final List<Camera> listCamera;

  CameraThumb({
    this.listCamera,
  });

  @override
  Widget build(BuildContext context) {
    switch (listCamera.length) {
      case 0:
        return EmptyThumbItem();
      case 1:
        return CameraThumbItem(
          gatewayId: listCamera.first.gatewayId,
          link: listCamera.first.links,
        );
      case 2:
        return GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          children: [
            ...listCamera
                .map((e) =>
                    CameraThumbItem(gatewayId: e.gatewayId, link: e.links))
                .toList(),
            EmptyThumbItem(),
            EmptyThumbItem(),
          ],
        );
      case 3:
        return GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          children: [
            ...listCamera
                .map((e) =>
                    CameraThumbItem(gatewayId: e.gatewayId, link: e.links))
                .toList(),
            EmptyThumbItem(),
          ],
        );
      default:
        return GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          children: listCamera
              .take(4)
              .map(
                  (e) => CameraThumbItem(gatewayId: e.gatewayId, link: e.links))
              .toList(),
        );
    }
  }
}

class CameraThumbItem extends StatefulWidget {
  final int gatewayId;
  final List<String> link;

  CameraThumbItem({
    this.gatewayId,
    this.link,
  });

  @override
  _CameraThumbItemState createState() => _CameraThumbItemState();
}

class _CameraThumbItemState extends State<CameraThumbItem> {
  List<String> linkSnap = [];
  GatewayStore _gatewayStore;
  Gateway gateway;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _gatewayStore = Provider.of(context);
    gateway = await _gatewayStore.findById(widget.gatewayId);
    linkSnap = widget.link.where((e) => e.contains("mode=snap")).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: CachedNetworkImage(
          imageUrl: _getSnapLink(),
          placeholder: (context, url) => Padding(
            padding: const EdgeInsets.all(2.0),
            child: SpinKitCircle(color: Colors.white, size: 10.0),
          ),
          httpHeaders: {"Authorization": "Bearer ${gateway?.token}"},
        ),
      ),
    );
  }

  String _getSnapLink() {
    return linkSnap.isEmpty || gateway == null
        ? ""
        : linkSnap.removeAt(0).replaceAll("%s", "token=${gateway.token}");
  }
}

class EmptyThumbItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: IconAssets(
        name: "empty_thumb",
      ),
    );
  }
}

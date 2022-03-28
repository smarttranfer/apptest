import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/my_camera_tree_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class MyCamera extends StatefulWidget {
  final Function onSelected;

  const MyCamera({Key key, this.onSelected}) : super(key: key);

  @override
  _MyCameraState createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  DeviceStore _deviceStore;
  GatewayStore _gatewayStore;
  FavoriteStore _favoriteStore;

  bool hideListVms = false;
  bool hideListBkav = true;
  bool hideListFavorite = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deviceStore = Provider.of(context);
    _gatewayStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _gatewayStore.findAll();
    _deviceStore.findAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  child: Text(
                    Translate.getString("favorite.my_camera", context),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  width: DeviceUtils.getScaledWidth(context, 0.75)),
              GestureDetector(
                child: Container(
                  width: 25,
                  height: 25,
                  child: Icon(Icons.close, color: Colors.black, size: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    border: Border.all(width: 0.6, color: Colors.grey[300]),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
        if (_gatewayStore.listGateway.length > 0)
          Expanded(
            child: Observer(builder: (_) {
              /// Sort list Gateways
              _gatewayStore.listGateway
                  .sort((a, b) => a.name.compareTo(b.name));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: DeviceUtils.getScaledHeight(context, 0.85),
                  child: ListView(
                    children: [
                      Visibility(
                        visible: _gatewayStore.listGateway.length > 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "VMS Server",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                                splashColor: Colors.transparent,
                                icon: Icon(
                                  hideListVms
                                      ? Icons.keyboard_arrow_right
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hideListVms = !hideListVms;
                                  });
                                })
                          ],
                        ),
                      ),
                      if (!hideListVms)
                        ..._gatewayStore.listGateway
                            .map((gateway) => MyTreeCameraView(
                                  isExpanded: _isActiveExpanded(gateway),
                                  header: _header(gateway),
                                  items: _deviceStore.listDevice
                                      .where((element) =>
                                          element.gatewayId == gateway.id)
                                      .toList(),
                                  headerEdgeInsets: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                ))
                            .toList()
                      else
                        Container(),
                    ],
                  ),
                ),
              );
            }),
          )
        else
          Expanded(
            child: Center(
              child: Text(
                Translate.getString("favorite.no_data", context),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ButtonBottomSide(
          buttonText: Translate.getString("favorite.add_to_group", context),
          onTap: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  Widget _header(Gateway gateway) =>
      Text("${gateway.name} (${_getTotalCamera(gateway.id)})",
          style: TextStyle(
            color: _isActiveExpanded(gateway) ? Colors.blue : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ));

  _getTotalCamera(int id) {
    List<String> listAllDeviceStatusByGatewayId = _deviceStore.listDevice
        .where((element) => element.gatewayId == id)
        .map((e) => e.status)
        .toList();
    int countConnectedDevice = listAllDeviceStatusByGatewayId
        .where((element) => element == "Connected")
        .length;
    return "$countConnectedDevice/${listAllDeviceStatusByGatewayId.length}";
  }

  bool _isActiveExpanded(Gateway gateway) {
    List<int> listCamerasId =
        _favoriteStore.listCamera.map((e) => e?.gatewayId).toList();
    return listCamerasId.contains(gateway.id);
  }
}

import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/tree_camera_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class ListLiveCamera extends StatefulWidget {
  final Function onSelected;
  final int position;
  final bool isLiveMode;

  const ListLiveCamera({
    Key key,
    this.onSelected,
    this.position,
    this.isLiveMode = true,
  }) : super(key: key);

  @override
  _ListLiveCameraState createState() => _ListLiveCameraState();
}

class _ListLiveCameraState extends State<ListLiveCamera> {
  DeviceStore _deviceStore;
  GatewayStore _gatewayStore;

  bool hideListVms = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deviceStore = Provider.of(context);
    _gatewayStore = Provider.of(context);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                Translate.getString("live_view.list_camera", context),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
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
        if (_gatewayStore.listGateway.isNotEmpty)
          Observer(builder: (_) {
            /// Sort list Gateways
            _gatewayStore.listGateway.sort((a, b) => a.name.compareTo(b.name));
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  children: [
                    Visibility(
                      visible: _gatewayStore.listGateway.isNotEmpty,
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
                          .map((gateway) => TreeCameraView(
                                positionToAdd: widget.position,
                                isLiveMode: widget.isLiveMode,
                                isRadio: true,
                                isExpanded: false,
                                header: _header(gateway),
                                items: _deviceStore.listDevice
                                    .where((element) =>
                                        element.gatewayId == gateway.id)
                                    .toList(),
                                headerEdgeInsets: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                              ))
                          .toList(),
                  ],
                ),
              ),
            );
          })
        else
          Expanded(
            child: Center(
              child: Text(
                Translate.getString("live_view.no_data", context),
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  Widget _header(Gateway gateway) =>
      Text("${gateway.name} (${_getTotalCamera(gateway.id)})",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));

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
}

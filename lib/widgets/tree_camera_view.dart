import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/camera_preview/camera_preview_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class TreeCameraView extends StatefulWidget {
  final bool isExpanded;
  final bool isRadio;
  final Widget header;
  final List<Device> items;
  final EdgeInsets headerEdgeInsets;
  final Color headerBackgroundColor;
  final int positionToAdd;
  final bool isLiveMode;
  final Function onCheckAll;

  TreeCameraView({
    Key key,
    this.isExpanded = false,
    @required this.header,
    @required this.items,
    this.headerEdgeInsets,
    this.headerBackgroundColor,
    this.isRadio = false,
    this.positionToAdd,
    this.isLiveMode = true,
    this.onCheckAll,
  }) : super(key: key);

  @override
  _TreeCameraViewState createState() => _TreeCameraViewState();
}

class _TreeCameraViewState extends State<TreeCameraView> {
  CameraStore _cameraStore;
  CameraPreviewStore _cameraPreviewStore;
  RollCameraStore _rollCameraStore;
  bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _updateExpandState(widget.isExpanded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraStore = Provider.of(context);
    _cameraPreviewStore = Provider.of(context);
    _rollCameraStore = Provider.of(context);
  }

  void _updateExpandState(bool isExpanded) =>
      setState(() => _isExpanded = isExpanded);

  @override
  Widget build(BuildContext context) {
    return _isExpanded ? _buildListItems(context) : _wrapHeader();
  }

  Widget _wrapHeader() {
    List<Widget> children = [];
    children.add(Container(
      child: GestureDetector(
        onTap: () => _updateExpandState(!_isExpanded),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(37, 38, 43, 1),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          padding: widget.headerEdgeInsets != null
              ? widget.headerEdgeInsets
              : EdgeInsets.only(left: 0.0, right: 16.0),
          height: 60,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: isActiveExpanded() && !widget.isRadio
                        ? Colors.blue
                        : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  IconAssets(
                    name: "vms",
                    color: isActiveExpanded() && !widget.isRadio
                        ? Colors.blue
                        : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  widget.header,
                ],
              )),
              Visibility(
                visible: !widget.isRadio &&
                    widget.isLiveMode &&
                    widget.items.isNotEmpty,
                child: Observer(builder: (_) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor:
                          isActiveExpanded() ? Colors.blue : Colors.white,
                    ),
                    child: Checkbox(
                      value: _isCheckAll(),
                      onChanged: (value) {
                        if (widget.items.isEmpty) return;
                        int gatewayId = widget.items[0].gatewayId;
                        value
                            ? _cameraStore.addAllCamera(gatewayId)
                            : _cameraStore.removeCameraByGatewayId(gatewayId);
                        widget.onCheckAll();
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ));
    return Ink(
      color:
          widget.headerBackgroundColor ?? Theme.of(context).appBarTheme.color,
      child: Column(
        children: children,
      ),
    );
  }

  bool isActiveExpanded() {
    List<Camera> listCamera =
        widget.isLiveMode ? _cameraStore.listCameraSelected : [];
    List<int> listCamerasId = listCamera.map((e) => e?.gatewayId).toList();
    return widget.items.isNotEmpty &&
        listCamerasId.contains(widget.items[0].gatewayId);
  }

  Widget _buildListItems(BuildContext context) {
    return Column(
      children: [
        _wrapHeader(),
        Container(
          height: widget.items.length < 20
              ? (46 * widget.items.length).roundToDouble()
              : widget.isRadio
                  ? widget.isLiveMode
                      ? MediaQuery.of(context).size.height > 800
                          ? MediaQuery.of(context).size.height - 240
                          : MediaQuery.of(context).size.height - 215
                      : MediaQuery.of(context).size.height > 800
                          ? MediaQuery.of(context).size.height - 400
                          : MediaQuery.of(context).size.height - 410
                  : MediaQuery.of(context).size.height > 800
                      ? MediaQuery.of(context).size.height - 360
                      : MediaQuery.of(context).size.height - 340,
          child: ListView.builder(
              physics: widget.items.length < 20
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              itemExtent: 46,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                Device item = widget.items[index];
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 4.0, right: 4.0),
                                child: IconAssets(
                                  name: item.controllable == "1"
                                      ? "camera_ptz"
                                      : "camera",
                                  width: 30,
                                  color: item.status == "Connected"
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              Visibility(
                                visible: item.function == "Record",
                                child: Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Image(
                                    image: AssetImage(
                                        'assets/icons/ic_record.png'),
                                    width: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            width: DeviceUtils.getScaledWidth(context, 0.55),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: item.status == "Connected"
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      )),
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: Observer(builder: (_) {
                          List<Camera> listCamera =
                              _cameraStore.listCameraSelected;
                          bool conditionChecked = listCamera.any(
                            (e) => e?.id == item.id,
                          );
                          Device cameraSelected = widget.items.firstWhere(
                              (element) =>
                                  element.id ==
                                  _rollCameraStore.cameraSelected?.id,
                              orElse: () => null);
                          return widget.isRadio
                              ? Radio(
                                  value: item,
                                  groupValue: cameraSelected,
                                  onChanged: (Device device) {
                                    if (widget.isLiveMode) {
                                      Navigator.pop(context);
                                      _cameraStore.addCameraToDB(
                                          device, widget.positionToAdd);
                                    } else
                                      _rollCameraStore.addCamera(device);
                                  },
                                )
                              : Checkbox(
                                  value: conditionChecked,
                                  onChanged: (value) async {
                                    Device device = item;
                                    if (value) {
                                      _cameraStore
                                          .addCameraToListSelected(device);
                                      _cameraPreviewStore.setDevice(null);
                                      await Future.delayed(
                                          Duration(milliseconds: 50));
                                      _cameraPreviewStore.setDevice(device);
                                    } else {
                                      _cameraStore
                                          .removeCameraFromListSelected(device);
                                      _cameraPreviewStore.setDevice(null);
                                    }
                                  },
                                );
                        }),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  bool _isCheckAll() {
    List<Camera> listCamera = widget.isLiveMode
        ? _cameraStore.listCameraSelected
            .where((element) => element.name
                .toLowerCase()
                .contains(_cameraStore.cameraNameFilter.toLowerCase()))
            .toList()
        : [];
    return widget.items.isNotEmpty &&
        listCamera
                .where((e) =>
                    e != null && e.gatewayId == widget.items.last.gatewayId)
                .toList()
                .length ==
            widget.items.length;
  }
}

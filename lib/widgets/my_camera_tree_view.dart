import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class MyTreeCameraView extends StatefulWidget {
  final bool isExpanded;
  final Widget header;
  final List<Device> items;
  final EdgeInsets headerEdgeInsets;
  final Color headerBackgroundColor;
  final int positionToAdd;

  MyTreeCameraView(
      {Key key,
      this.isExpanded = false,
      @required this.header,
      @required this.items,
      this.headerEdgeInsets,
      this.headerBackgroundColor,
      this.positionToAdd})
      : super(key: key);

  @override
  _MyTreeCameraViewState createState() => _MyTreeCameraViewState();
}

class _MyTreeCameraViewState extends State<MyTreeCameraView> {
  FavoriteStore _favoriteStore;
  bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _updateExpandState(widget.isExpanded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoriteStore = Provider.of(context);
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
            color: Color.fromRGBO(37, 38, 43, 1),
          ),
          margin: EdgeInsets.only(bottom: 10),
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
                    color: isActiveExpanded() ? Colors.blue : Colors.white,
                  ),
                  SizedBox(width: 10),
                  IconAssets(
                    name: "vms",
                    color: isActiveExpanded() ? Colors.blue : Colors.white,
                  ),
                  SizedBox(width: 10),
                  widget.header,
                ],
              )),
              Observer(
                builder: (_) => Theme(
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
                          ? _favoriteStore.addAllCamera(gatewayId)
                          : _favoriteStore.removeCameraByGatewayId(gatewayId);
                      setState(() {});
                    },
                  ),
                ),
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

  Widget _buildListItems(BuildContext context) {
    return Column(
      children: [
        _wrapHeader(),
        Container(
          height: widget.items.length < 20
              ? (46 * widget.items.length).roundToDouble()
              : MediaQuery.of(context).size.height > 800
                  ? MediaQuery.of(context).size.height - 310
                  : MediaQuery.of(context).size.height - 280,
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
                                      : AppColors.hintColor,
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
                          SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            width: DeviceUtils.getScaledWidth(context, 0.55),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: item.status == "Connected"
                                    ? Colors.white
                                    : AppColors.hintColor,
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
                          bool conditionChecked = _favoriteStore.listCamera.any(
                            (e) => e?.id == item.id,
                          );
                          return Checkbox(
                            value: conditionChecked,
                            onChanged: (value) {
                              Device device = item;
                              if (value) {
                                _favoriteStore.addCamera(device);
                              } else {
                                _favoriteStore.removeCamera(device.id);
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

  bool isActiveExpanded() {
    List<int> listCamerasId =
        _favoriteStore.listCamera.map((e) => e?.gatewayId).toList();
    return widget.items.isNotEmpty &&
        listCamerasId.contains(widget.items[0].gatewayId);
  }

  bool _isCheckAll() {
    return widget.items.isNotEmpty &&
        _favoriteStore.listCamera
                .where((e) =>
                    e != null && e.gatewayId == widget.items.last.gatewayId)
                .toList()
                .length ==
            widget.items.length;
  }
}

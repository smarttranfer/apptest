import 'dart:ui';

import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/camera_preview/camera_preview_store.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/stores/language/language_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/camera_preview.dart';
import 'package:boilerplate/widgets/form_textfield_widget.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/widgets/tree_camera_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DevicesScreen extends StatefulWidget {
  DevicesScreen({Key key}) : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  DeviceStore _deviceStore;
  GatewayStore _gatewayStore;
  CameraPreviewStore _cameraPreviewStore;
  RollCameraStore _rollCameraStore;
  CameraStore _cameraStore;
  GridCameraStore _gridCameraStore;
  FavoriteStore _favoriteStore;
  LanguageStore _languageStore;

  bool hideListVms = false;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _timeFormat = DateFormat("HH:mm");
  final _dateFormat = DateFormat("dd/MM/yyyy");

  final defaultTime = DateTime.now().subtract(Duration(days: 1));

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deviceStore = Provider.of(context);
    _gatewayStore = Provider.of(context);
    _cameraStore = Provider.of(context);
    _gridCameraStore = Provider.of(context);
    _cameraPreviewStore = Provider.of(context);
    _rollCameraStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _languageStore = Provider.of(context);
    _timeController.text =
        _timeFormat.format(_rollCameraStore.timeSelected ?? defaultTime);
    _dateController.text =
        _dateFormat.format(_rollCameraStore.timeSelected ?? defaultTime);
    if (_rollCameraStore.camera != null)
      _rollCameraStore.cameraSelected = Camera.clone(_rollCameraStore.camera);
  }

  @override
  Widget build(BuildContext context) {
    final isLiveMode =
        ModalRoute.of(context).settings.arguments != "roll_camera";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 30,
              child: IconButton(
                alignment: Alignment.centerLeft,
                iconSize: 20,
                icon: Icon(
                  CupertinoIcons.left_chevron,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              Translate.getString(
                isLiveMode ? "live_view.list_camera" : "playback.list_camera",
                context,
              ),
            )
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size(40, isLiveMode ? 50 : 120),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: Wrap(
              runSpacing: 10.0,
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoTextField(
                    cursorColor: Colors.blue,
                    onChanged: (value) => _onSearchCamera(value),
                    keyboardType: TextInputType.text,
                    placeholder: Translate.getString(
                        "manage_device.search_camera", context),
                    placeholderStyle: TextStyle(
                        color: Color.fromRGBO(104, 113, 122, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    prefix: Padding(
                      padding: const EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                      child: Icon(
                        CupertinoIcons.search,
                        color: Color(0xffC4C6CC),
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Color.fromRGBO(37, 38, 43, 1),
                    ),
                  ),
                ),
                Visibility(
                  visible: !isLiveMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translate.getString("live_view.time", context),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: FormTextFieldWidget(
                              controller: _timeController,
                              enabled: false,
                              onChanged: (value) {},
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(15),
                                child: IconAssets(name: "time"),
                              ),
                              onTap: () {
                                DatePicker.showTimePicker(
                                  context,
                                  showTitleActions: true,
                                  showSecondsColumn: false,
                                  onConfirm: (time) {
                                    final currentTime =
                                        _rollCameraStore.timeSelected ??
                                            defaultTime;
                                    final selectedTime = DateTime(
                                      currentTime.year,
                                      currentTime.month,
                                      currentTime.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    _rollCameraStore
                                        .setTimeSelected(selectedTime);
                                    _timeController.text =
                                        _timeFormat.format(selectedTime);
                                  },
                                  currentTime: _rollCameraStore.timeSelected,
                                  locale: _languageStore.currentLocale == 'vi'
                                      ? LocaleType.vi
                                      : LocaleType.en,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: FormTextFieldWidget(
                                controller: _dateController,
                                onChanged: (value) {},
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: IconAssets(name: "date"),
                                ),
                                enabled: false,
                                onTap: () {
                                  DatePicker.showDatePicker(
                                    context,
                                    showTitleActions: true,
                                    onConfirm: (time) {
                                      final currentTime =
                                          _rollCameraStore.timeSelected ??
                                              defaultTime;
                                      final selectedTime = DateTime(
                                        time.year,
                                        time.month,
                                        time.day,
                                        currentTime.hour,
                                        currentTime.minute,
                                      );
                                      _rollCameraStore
                                          .setTimeSelected(selectedTime);
                                      _dateController.text =
                                          _dateFormat.format(selectedTime);
                                    },
                                    currentTime: _rollCameraStore.timeSelected,
                                    locale: _languageStore.currentLocale == 'vi'
                                        ? LocaleType.vi
                                        : LocaleType.en,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Observer(
        builder: (_) {
          /// Sort list Gateways
          // _gatewayStore.listGateway.sort((a, b) => a.name.compareTo(b.name));
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SmartRefresher(
                      physics: const BouncingScrollPhysics(),
                      enablePullDown: true,
                      enablePullUp: false,
                      header: WaterDropHeader(
                        complete: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.done,
                                color: AppColors.accentColor),
                            const SizedBox(width: 15.0),
                            Text(
                              Translate.getString(
                                  "manage_device.update_success", context),
                              style: TextStyle(color: AppColors.accentColor),
                            )
                          ],
                        ),
                        failed: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.error_outline,
                                color: AppColors.accentColor),
                            const SizedBox(width: 15.0),
                            Text(
                              Translate.getString(
                                  "manage_device.update_failed", context),
                              style: TextStyle(color: AppColors.accentColor),
                            )
                          ],
                        ),
                        waterDropColor: AppColors.accentColor,
                      ),
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: _gatewayStore.listGateway.length > 0
                          ? ListView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              children: [
                                Visibility(
                                  visible: _gatewayStore.listGateway.length > 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            isLiveMode: isLiveMode,
                                            isRadio: !isLiveMode,
                                            isExpanded: false,
                                            header: _header(gateway),
                                            onCheckAll: () {
                                              setState(() {});
                                            },
                                            items: _deviceStore.listDevice
                                                .where((element) =>
                                                    element.gatewayId ==
                                                        gateway.id &&
                                                    element.name
                                                        .toLowerCase()
                                                        .contains(_cameraStore
                                                            .cameraNameFilter
                                                            .toLowerCase()))
                                                .toList(),
                                            headerEdgeInsets:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8),
                                          ))
                                      .toList(),
                              ],
                            )
                          : Center(
                              child: Text(
                                Translate.getString(
                                    "live_view.no_data", context),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                  Visibility(
                    visible: _gatewayStore.listGateway.length > 0,
                    child: ButtonBottomSide(
                      buttonText: Translate.getString(
                          isLiveMode
                              ? "manage_device.start_live_view"
                              : "manage_device.start_playback",
                          context),
                      onTap: () async {
                        if (isLiveMode) {
                          Loader.show(context,
                              progressIndicator:
                                  CustomProgressIndicatorWidget());
                          await _cameraStore.showListCameraSelected();
                          Loader.hide();
                          _gridCameraStore.setPage(0);
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.liveCamera,
                              (Route<dynamic> route) => false);
                        } else {
                          if (_rollCameraStore.cameraSelected == null)
                            _showErrorMessage(Translate.getString(
                                "playback.not_select_camera", context));
                          else {
                            Loader.show(context,
                                progressIndicator:
                                    CustomProgressIndicatorWidget());
                            await _rollCameraStore.getEventsPLayBack(context);
                            Loader.hide();
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
              Visibility(
                visible: _cameraPreviewStore.device != null,
                child: CameraPreview(device: _cameraPreviewStore.device),
              ),
            ],
          );
        },
      ),
    );
  }

  _showErrorMessage(String message) {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: CupertinoAlertDialog(
                    title: Text(
                        Translate.getString("manage_device.warning", context)),
                    content: Text(Translate.getString(message, context)),
                    actions: [
                      CupertinoDialogAction(
                          child:
                              Text(Translate.getString("home.cancel", context)),
                          onPressed: () async {
                            _resetStore();
                            await Future.wait([
                              appComponent.getCameraRepository().deleteAll(),
                              appComponent.getDeviceRepository().deleteAll(),
                              appComponent.getFavoriteRepository().deleteAll(),
                            ]);
                            Navigator.pop(context);
                          }),
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("home.try_again", context)),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _fetchListDevice();
                          })
                    ]),
              ),
            ));
  }

  _resetStore() {
    _rollCameraStore.dispose();
    _gridCameraStore.dispose();
    _favoriteStore.dispose();
    _cameraStore.dispose();
    _deviceStore.dispose();
  }

  void _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    await _fetchListDevice();
    if (_deviceStore.success)
      _refreshController.refreshCompleted();
    else
      _refreshController.refreshFailed();
  }

  void _onLoading() async {
    await Future.delayed(Duration(seconds: 1));
    await _fetchListDevice();
    if (_deviceStore.success)
      _refreshController.refreshCompleted();
    else
      _refreshController.refreshFailed();
  }

  _onSearchCamera(String value) async {
    await Future.delayed(Duration(milliseconds: 500));
    _cameraStore.setDeviceNameFilter(value);
  }

  @override
  void dispose() {
    super.dispose();
    _cameraStore.setDeviceNameFilter("");
    _cameraPreviewStore.setDevice(null);
  }

  Widget _header(Gateway gateway) {
    return Text("${gateway.name} (${_getTotalCamera(gateway.id)})",
        style: TextStyle(
            color: _isActiveExpanded(gateway) ? Colors.blue : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold));
  }

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
    final isLiveMode =
        ModalRoute.of(context).settings.arguments != "roll_camera";
    List<Camera> listCamera = isLiveMode ? _cameraStore.listCameraSelected : [];
    List<int> listCamerasId = listCamera.map((e) => e?.gatewayId).toList();
    return listCamerasId.contains(gateway.id);
  }

  _fetchListDevice() async {
    List<Device> listDevicesFromApi = [];
    try {
      final response = await _deviceStore.fetchData(_gatewayStore.gateway, context);
      if (_deviceStore.success) {
        for (var item in response) {
          Gateway gateway = Gateway.fromApi(item["target"]);
          Gateway gatewayExistedInDb = _gatewayStore.listGateway.firstWhere(
              (element) =>
                  element.domainName == gateway.domainName &&
                  element.port == gateway.port,
              orElse: () => null);
          List<Device> listDevices = item["data"]
              .map<Device>((list) => Device.fromJson(list))
              .toList();
          if (gatewayExistedInDb == null) return;
          listDevices.forEach((device) {
            device.gatewayId = gatewayExistedInDb.id;
          });
          listDevicesFromApi.addAll(listDevices);
        }
        await _handleSyncDevices(listDevicesFromApi);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future _handleSyncDevices(List<Device> listDevicesFromApi) async {
    List<Device> listDeviceInsert = listDevicesFromApi
        .where((element) => !_deviceStore.listDevice.contains(element))
        .toList();
    List<Device> listDeviceRemove = _deviceStore.listDevice
        .where((element) => !listDevicesFromApi.contains(element))
        .toList();
    listDeviceRemove.forEach(
        (Device device) async => await _deviceStore.deleteByFilter(device));
    await _deviceStore.insertListDevicesToDB(listDeviceInsert);
  }
}

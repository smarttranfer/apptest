import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/ui/setup_app/verify_app.dart';
import 'package:boilerplate/widgets/app_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GatewayStore _gatewayStore;
  CameraStore _cameraStore;
  FavoriteStore _favoriteStore;
  ProfileStore _profileStore;
  DeviceStore _deviceStore;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _gatewayStore = Provider.of(context);
    _cameraStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _profileStore = Provider.of(context);
    _deviceStore = Provider.of(context);
    await _gatewayStore.findAll();
    await Future.wait([
      _deviceStore.findAll(),
      _cameraStore.findAll(),
      _favoriteStore.findAll(),
    ]);
    // getStaticData();
    navigate();
  }

  void getStaticData() {
    _profileStore.getAllContinents();
    _profileStore.getAllCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIconWidget(image: 'assets/icons/ic_launcher.png'),
          const SizedBox(height: 20),
          SpinKitFadingCube(
            color: AppColors.accentColor,
            size: 24,
          )
        ],
      ),
    );
  }

  navigate() async {
    if (await appComponent.getSharedPreferenceHelper().currentRegion) {
      if (await appComponent.getSharedPreferenceHelper().isExistedPinCode)
        showMaterialModalBottomSheet(
            context: context,
            isDismissible: true,
            enableDrag: false,
            expand: true,
            builder: (_) {
              return VerifyApp(isFirstTimeOpenApp: true);
            });
      else {
        if (await appComponent.getSharedPreferenceHelper().isLoggedIn)
          Navigator.of(context).pushReplacementNamed(Routes.liveCamera);
        else
          Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.selectRegion);
    }
  }
}

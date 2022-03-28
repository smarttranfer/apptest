List<MainMenu> mainMenuList = [
  MainMenu(
    title: 'setting.security',
    path: '/securityScreen',
    iconName: 'security',
  ),
  MainMenu(
    title: 'setting.region',
    path: '/region',
    iconName: 'region',
  ),
  MainMenu(
    title: 'setting.language',
    path: '/language',
    iconName: 'language',
  ),
  MainMenu(
    title: 'setting.tablet',
    path: '/tabletMode',
    iconName: 'tablet_mode',
  ),
  MainMenu(
    title: 'setting.help',
    path: '/helpScreen',
    iconName: 'help',
  ),
  MainMenu(
    title: 'setting.app_info',
    path: '/appInfo',
    iconName: 'app_info',
  ),
];

List<MainMenu> helpMenuList = [
  MainMenu(
    title: 'setting.general',
    path: '/',
    iconName: 'ai',
  ),
  MainMenu(
    title: 'setting.live_view',
    path: '/',
    iconName: 'camera',
  ),
  MainMenu(
    title: 'setting.playback',
    path: '/',
    iconName: 'rewatch',
  ),
  MainMenu(
    title: 'setting.manage_notification',
    path: '/',
    iconName: 'notifications',
  ),
  MainMenu(
    title: 'setting.manage_device',
    path: '/',
    iconName: 'device_manage',
  ),
  MainMenu(
    title: 'setting.list_favorite',
    path: '/',
    iconName: 'favorite',
  ),
  MainMenu(
    title: 'setting.video_photo',
    path: '/',
    iconName: 'video_photo',
  ),
  MainMenu(
    title: 'setting.setting',
    path: '/',
    iconName: 'settings',
  ),
];

class MainMenu {
  String title;
  String path;
  String iconName;

  MainMenu({this.iconName, this.title, this.path});
}
